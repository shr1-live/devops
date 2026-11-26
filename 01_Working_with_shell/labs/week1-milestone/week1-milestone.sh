#!/usr/bin/env bash
# Week 1 milestone: baseline SSH hardening, a sample backend under systemd,
# NGINX as a TLS-terminating reverse proxy, and an idempotent health-check / log-rotation script.
#
# Made for the KodeKloud Ubuntu Playground (Ubuntu with systemd). Run as root or with sudo.
#   sudo bash week1-milestone.sh all        # do everything (safe to run again: second run = 0 changes)
#   sudo bash week1-milestone.sh harden     # step 1  SSH hardening
#   sudo bash week1-milestone.sh backend    # step 2  backend + systemd unit
#   sudo bash week1-milestone.sh nginx      # step 3  NGINX + TLS reverse proxy
#   sudo bash week1-milestone.sh maintenance# step 4  health-check + log-rotation script (+ cron)
#   sudo bash week1-milestone.sh verify     # prove it: PASS / FAIL for every requirement
#   sudo bash week1-milestone.sh status     # quick look
#
# Idempotent = running it again changes nothing when nothing needs changing.
# Every file is rewritten only if its content differs; services are restarted only after a real change.
set -euo pipefail

[[ ${EUID} -eq 0 ]] || exec sudo -E bash "$0" "$@"

export DEBIAN_FRONTEND=noninteractive
CHANGES=0
LAST_CHANGED=0
BACKEND_PORT=5001
HAVE_SYSTEMD=0
[[ -d /run/systemd/system ]] && HAVE_SYSTEMD=1

say()  { printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    WARNING: %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

apt_need() {              # apt_need <command> <package>   install the package only if the command is missing
  have "$1" && return 0
  info "installing $2"
  apt-get update -qq >/dev/null
  apt-get install -y -qq "$2" >/dev/null
  CHANGES=$((CHANGES + 1))
}

# write_file <path> <mode> <owner:group>   (content on stdin). Rewrites only when the content differs.
write_file() {
  local path=$1 mode=$2 owner=${3:-root:root} tmp
  tmp=$(mktemp); cat >"$tmp"
  mkdir -p "$(dirname "$path")"
  if [[ -f $path ]] && cmp -s "$tmp" "$path"; then
    LAST_CHANGED=0; info "unchanged  $path"
  else
    install -m "$mode" -o "${owner%%:*}" -g "${owner##*:}" "$tmp" "$path"
    LAST_CHANGED=1; CHANGES=$((CHANGES + 1)); info "WROTE      $path"
  fi
  chmod "$mode" "$path"; chown "$owner" "$path"; rm -f "$tmp"
}

wait_for_http() {         # wait_for_http <url> [curl flags]  up to ~10 s
  local url=$1; shift
  for _ in $(seq 20); do curl -fsS --max-time 2 "$@" -o /dev/null "$url" 2>/dev/null && return 0; sleep 0.5; done
  return 1
}

# ---------------------------------------------------------------- 1. SSH hardening
step_harden() {
  say "1/4  SSH baseline hardening"
  apt_need sshd openssh-server
  mkdir -p /run/sshd; ssh-keygen -A >/dev/null 2>&1 || true

  # sshd_config must read the drop-in folder (Ubuntu does by default; add the line if a custom file lacks it)
  if ! grep -qE '^\s*Include\s+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config; then
    sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config; CHANGES=$((CHANGES + 1))
    info "added the Include line to /etc/ssh/sshd_config"
  fi

  # Turn password login off only when someone already has a key, otherwise we would lock ourselves out.
  local keys=0 f pw=yes
  for f in /root/.ssh/authorized_keys /home/*/.ssh/authorized_keys; do [[ -s $f ]] && keys=1; done
  if [[ $keys -eq 1 || ${SSH_DISABLE_PASSWORD:-0} == 1 ]]; then pw=no
  else warn "no SSH public key found for any user: leaving PasswordAuthentication ON so you cannot lock yourself out."
       warn "add your key to ~/.ssh/authorized_keys, then run: sudo bash $0 harden"; fi

  # 00- sorts first. sshd keeps the FIRST value it reads, and cloud images ship 50-cloud-init.conf with
  # "PasswordAuthentication yes", so a 99- file would be silently ignored.
  write_file /etc/ssh/sshd_config.d/00-hardening.conf 644 root:root <<CONF
# managed by week1-milestone.sh (baseline hardening)
PermitRootLogin no
PasswordAuthentication ${pw}
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
MaxAuthTries 3
MaxSessions 4
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no
CONF

  sshd -t                                              # validate BEFORE reloading: a broken config would lock you out
  info "sshd -t: configuration is valid"
  if [[ $LAST_CHANGED -eq 1 ]]; then
    if (( HAVE_SYSTEMD )); then systemctl reload ssh 2>/dev/null || systemctl reload sshd 2>/dev/null || systemctl restart ssh
    elif pgrep -x sshd >/dev/null; then pkill -HUP -x sshd
    fi
    info "sshd reloaded (existing sessions stay connected)"
  fi
}

# ---------------------------------------------------------------- 2. backend + systemd
step_backend() {
  say "2/4  Sample backend managed by systemd"
  apt_need python3 python3-minimal
  id labapp >/dev/null 2>&1 || { useradd --system --no-create-home --shell /usr/sbin/nologin labapp; CHANGES=$((CHANGES + 1)); info "created system user labapp (no login, no home)"; }
  install -d -m 755 -o labapp -g labapp /var/log/lab
  install -d -m 755 /opt/lab-backend

  write_file /opt/lab-backend/app.py 644 root:root <<'PY'
#!/usr/bin/env python3
"""Tiny JSON backend. Listens on 127.0.0.1 only: the outside world reaches it through NGINX."""
import json, logging, os, socket, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST = os.environ.get("BIND", "127.0.0.1")
PORT = int(os.environ.get("PORT", "5001"))
logging.basicConfig(filename=os.environ.get("LOG_FILE", "/var/log/lab/backend.log"),
                    level=logging.INFO, format="%(asctime)s %(message)s")
START = time.time()

class Handler(BaseHTTPRequestHandler):
    server_version = "LabBackend/1.0"

    def _send(self, code, obj):
        body = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/healthz":
            return self._send(200, {"status": "ok", "uptime_s": int(time.time() - START)})
        self._send(200, {"service": "lab-backend", "host": socket.gethostname(), "path": self.path,
                         "time": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
                         "x_forwarded_proto": self.headers.get("X-Forwarded-Proto"),
                         "x_real_ip": self.headers.get("X-Real-IP")})

    def log_message(self, fmt, *args):
        logging.info("%s %s", self.client_address[0], fmt % args)

if __name__ == "__main__":
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
PY
  local app_changed=$LAST_CHANGED

  if (( HAVE_SYSTEMD )); then
    write_file /etc/systemd/system/lab-backend.service 644 root:root <<UNIT
[Unit]
Description=Lab sample backend (Python)
After=network.target

[Service]
User=labapp
Group=labapp
Environment=PORT=${BACKEND_PORT} BIND=127.0.0.1 LOG_FILE=/var/log/lab/backend.log
ExecStart=/usr/bin/python3 /opt/lab-backend/app.py
Restart=always
RestartSec=2
# sandboxing: the service can only write to its log folder
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/var/log/lab

[Install]
WantedBy=multi-user.target
UNIT
    local unit_changed=$LAST_CHANGED
    (( unit_changed )) && systemctl daemon-reload
    systemctl is-enabled --quiet lab-backend 2>/dev/null || { systemctl enable lab-backend >/dev/null 2>&1; CHANGES=$((CHANGES + 1)); info "enabled lab-backend at boot"; }
    if ! systemctl is-active --quiet lab-backend; then systemctl start lab-backend; CHANGES=$((CHANGES + 1)); info "started lab-backend"
    elif (( app_changed || unit_changed )); then systemctl restart lab-backend; info "restarted lab-backend (its files changed)"; fi
  else
    warn "no systemd here (a plain container). Starting the backend directly instead; on a real systemd machine the unit is used."
    if ! pgrep -f '^/usr/bin/python3 /opt/lab-backend/app.py$' >/dev/null || (( app_changed )); then
      pkill -f '^/usr/bin/python3 /opt/lab-backend/app.py$' 2>/dev/null || true
      PORT=${BACKEND_PORT} BIND=127.0.0.1 LOG_FILE=/var/log/lab/backend.log \
        setsid nohup runuser -u labapp -- /usr/bin/python3 /opt/lab-backend/app.py >/dev/null 2>&1 &
      CHANGES=$((CHANGES + 1)); info "started backend process"
    fi
  fi
  wait_for_http "http://127.0.0.1:${BACKEND_PORT}/healthz" && info "backend answers on 127.0.0.1:${BACKEND_PORT}" || { echo "backend did not start"; exit 1; }
}

# ---------------------------------------------------------------- 3. NGINX TLS reverse proxy
step_nginx() {
  say "3/4  NGINX: TLS termination + reverse proxy"
  apt_need nginx nginx
  apt_need openssl openssl

  if [[ ! -s /etc/ssl/lab/lab.crt || ! -s /etc/ssl/lab/lab.key ]]; then
    install -d -m 755 /etc/ssl/lab
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 -keyout /etc/ssl/lab/lab.key -out /etc/ssl/lab/lab.crt \
      -subj "/CN=lab.local" -addext "subjectAltName=DNS:lab.local,DNS:localhost,IP:127.0.0.1" >/dev/null 2>&1
    chmod 600 /etc/ssl/lab/lab.key; chmod 644 /etc/ssl/lab/lab.crt
    CHANGES=$((CHANGES + 1)); info "created self-signed certificate (valid 365 days)"
  else info "unchanged  /etc/ssl/lab/lab.crt (already exists)"; fi

  write_file /etc/nginx/conf.d/lab-hardening.conf 644 root:root <<'CONF'
server_tokens off;   # do not advertise the nginx version
CONF
  local c1=$LAST_CHANGED
  write_file /etc/nginx/sites-available/lab 644 root:root <<CONF
# port 80: only redirect to HTTPS
server {
    listen 80 default_server;
    server_name _;
    return 301 https://\$host\$request_uri;
}

# port 443: terminate TLS here, talk plain HTTP to the backend on localhost
server {
    listen 443 ssl http2 default_server;
    server_name _;

    ssl_certificate     /etc/ssl/lab/lab.crt;
    ssl_certificate_key /etc/ssl/lab/lab.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_session_cache   shared:SSL:5m;
    ssl_session_timeout 10m;

    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options nosniff always;

    location / {
        proxy_pass         http://127.0.0.1:${BACKEND_PORT};
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout    30s;
    }
}
CONF
  local c2=$LAST_CHANGED
  [[ -L /etc/nginx/sites-enabled/lab ]] || { ln -sf /etc/nginx/sites-available/lab /etc/nginx/sites-enabled/lab; CHANGES=$((CHANGES + 1)); c2=1; info "enabled site: lab"; }
  [[ -e /etc/nginx/sites-enabled/default ]] && { rm -f /etc/nginx/sites-enabled/default; CHANGES=$((CHANGES + 1)); c2=1; info "disabled the default nginx site"; }

  nginx -t 2>&1 | sed 's/^/    /'                   # validate BEFORE reloading
  local running=0
  if (( HAVE_SYSTEMD )); then systemctl is-active --quiet nginx && running=1; else pgrep -x nginx >/dev/null && running=1; fi
  if (( ! running )); then
    if (( HAVE_SYSTEMD )); then systemctl enable --now nginx >/dev/null 2>&1; else nginx; fi
    CHANGES=$((CHANGES + 1)); info "started nginx"
  elif (( c1 || c2 )); then
    if (( HAVE_SYSTEMD )); then systemctl reload nginx; else nginx -s reload; fi
    info "reloaded nginx"
  fi
  wait_for_http https://127.0.0.1/healthz -k && info "https://localhost/ is proxied to the backend" || { echo "nginx is not proxying"; exit 1; }
}

# ---------------------------------------------------------------- 4. health-check + log rotation script
step_maintenance() {
  say "4/4  Health-check and log-rotation script (idempotent)"
  write_file /usr/local/bin/lab-maintenance.sh 755 root:root <<'MAINT'
#!/usr/bin/env bash
# lab-maintenance.sh: health checks + log rotation. Safe to run any number of times.
#   lab-maintenance.sh check            health checks, exit 0 = all OK, 1 = something failed
#   lab-maintenance.sh check --heal     same, but restart a failed service once and re-check
#   lab-maintenance.sh rotate [--force] rotate /var/log/lab/*.log when bigger than MAX_BYTES
#   lab-maintenance.sh all              check, then rotate (what cron runs)
set -euo pipefail

LOG_DIR=${LOG_DIR:-/var/log/lab}
MAX_BYTES=${MAX_BYTES:-1048576}     # rotate a log once it reaches 1 MiB
RETAIN=${RETAIN:-5}                 # keep this many old copies
BACKEND_URL=${BACKEND_URL:-http://127.0.0.1:5001/healthz}
PROXY_URL=${PROXY_URL:-https://127.0.0.1/healthz}
HEALTH_LOG=$LOG_DIR/health.log
LOCK=/run/lab-maintenance.lock

mkdir -p "$LOG_DIR"
exec 9>"$LOCK"
flock -n 9 || { echo "another run is in progress, skipping"; exit 0; }   # never run two copies at once

stamp() { date '+%Y-%m-%dT%H:%M:%S%z'; }
FAILED=()
result() {  # result OK|FAIL <name> <detail>
  printf '%s %-4s %-18s %s\n' "$(stamp)" "$1" "$2" "$3" | tee -a "$HEALTH_LOG"
  [[ $1 == OK ]] || FAILED+=("$2")
}

has_systemd() { [[ -d /run/systemd/system ]]; }

run_checks() {
  FAILED=()
  if has_systemd; then
    systemctl is-active --quiet lab-backend && result OK  backend-service "systemd: active" || result FAIL backend-service "systemd: not active"
    systemctl is-active --quiet nginx       && result OK  nginx-service   "systemd: active" || result FAIL nginx-service   "systemd: not active"
  else
    pgrep -f '^/usr/bin/python3 /opt/lab-backend/app.py$' >/dev/null && result OK backend-service "process running" || result FAIL backend-service "process not running"
    pgrep -x nginx >/dev/null                   && result OK nginx-service   "process running" || result FAIL nginx-service   "process not running"
  fi
  body=$(curl -fsS --max-time 3 "$BACKEND_URL" 2>/dev/null || true)      # capture first, so a pipe cannot fail by SIGPIPE
  grep -q '"ok"' <<<"$body" \
    && result OK backend-http "$BACKEND_URL answers ok" || result FAIL backend-http "$BACKEND_URL did not answer"
  code=$(curl -ks --max-time 3 -o /dev/null -w '%{http_code}' "$PROXY_URL" || true)
  [[ $code == 200 ]] && result OK proxy-https "$PROXY_URL -> 200" || result FAIL proxy-https "$PROXY_URL -> ${code:-no answer}"
  used=$(df --output=pcent / | tail -1 | tr -dc '0-9')
  (( used < 90 )) && result OK disk "/ is ${used}% full" || result FAIL disk "/ is ${used}% full (limit 90)"
  if [[ -r /etc/ssl/lab/lab.crt ]]; then
    openssl x509 -checkend 604800 -noout -in /etc/ssl/lab/lab.crt >/dev/null \
      && result OK cert-expiry "certificate valid for more than 7 days" || result FAIL cert-expiry "certificate expires within 7 days"
  fi
}

heal() {
  for svc in "$@"; do
    echo "healing: restarting $svc" | tee -a "$HEALTH_LOG"
    if has_systemd; then systemctl restart "$svc" || true; fi
  done
  sleep 2
}

do_check() {
  run_checks
  if [[ ${1:-} == --heal && ${#FAILED[@]} -gt 0 ]]; then
    to_fix=()
    for n in "${FAILED[@]}"; do case $n in backend-*) to_fix+=(lab-backend);; nginx-*|proxy-*) to_fix+=(nginx);; esac; done
    if (( ${#to_fix[@]} )); then
      mapfile -t to_fix < <(printf '%s\n' "${to_fix[@]}" | sort -u)
      heal "${to_fix[@]}"; run_checks
    fi
  fi
  if (( ${#FAILED[@]} )); then echo "UNHEALTHY: ${FAILED[*]}"; return 1; fi
  echo "HEALTHY"
}

rotate_one() {  # rotate_one <file>   copytruncate: the program keeps its open file, we copy then empty it
  local f=$1 size i
  [[ -f $f ]] || return 0
  size=$(stat -c %s "$f")
  if (( size < MAX_BYTES )) && [[ ${FORCE:-0} != 1 ]]; then return 0; fi   # nothing to do: this is what makes it idempotent
  [[ $size -eq 0 ]] && return 0
  rm -f "$f.$RETAIN.gz"
  for ((i = RETAIN - 1; i >= 1; i--)); do [[ -f $f.$i.gz ]] && mv -f "$f.$i.gz" "$f.$((i + 1)).gz"; done
  cp -p "$f" "$f.1" && : > "$f" && gzip -f "$f.1"
  echo "$(stamp) ROTATE $f (${size} bytes) -> $f.1.gz" | tee -a "$HEALTH_LOG"
}

do_rotate() {
  [[ ${1:-} == --force ]] && FORCE=1
  local n=0 f
  shopt -s nullglob
  for f in "$LOG_DIR"/*.log; do rotate_one "$f"; n=$((n + 1)); done
  echo "rotation checked $n log file(s)"
}

case ${1:-all} in
  check)  shift; do_check "${1:-}" ;;
  rotate) shift; do_rotate "${1:-}" ;;
  all)    rc=0; do_check "${2:-}" || rc=$?; do_rotate; exit "$rc" ;;
  *)      sed -n '2,6p' "$0"; exit 2 ;;
esac
MAINT
  write_file /etc/cron.d/lab-maintenance 644 root:root <<'CRON'
# run the health check and log rotation every 5 minutes
*/5 * * * * root /usr/local/bin/lab-maintenance.sh all >/dev/null 2>&1
CRON
  have flock || apt_need flock util-linux
}

# ---------------------------------------------------------------- verify
PASS=0; FAILS=0; WARNS=0
t() {   # t "<what is checked>" <command...>
  local d=$1; shift
  if "$@" >/dev/null 2>&1; then printf '  PASS  %s\n' "$d"; PASS=$((PASS + 1)); else printf '  FAIL  %s\n' "$d"; FAILS=$((FAILS + 1)); fi
}
# capture first: "sshd -T | grep -q" can die of SIGPIPE under pipefail and give a random FAIL
sshv() { local out; out=$(sshd -T 2>/dev/null); grep -qix "$1" <<<"$out"; }

step_verify() {
  say "Verifying the milestone"
  apt_need ss iproute2; apt_need curl curl
  echo "SSH hardening"
  t "sshd configuration is valid (sshd -t)"            sshd -t
  t "root login is disabled"                           sshv "permitrootlogin no"
  t "MaxAuthTries is 3"                                sshv "maxauthtries 3"
  t "X11 forwarding is off"                            sshv "x11forwarding no"
  t "empty passwords are refused"                      sshv "permitemptypasswords no"
  if sshv "passwordauthentication no"; then printf '  PASS  %s\n' "password login is disabled (key only)"; PASS=$((PASS + 1))
  else printf '  WARN  %s\n' "password login is still ON: add an SSH key, then run: harden"; WARNS=$((WARNS + 1)); fi

  echo "Backend + systemd"
  if (( HAVE_SYSTEMD )); then t "lab-backend.service is active under systemd" systemctl is-active --quiet lab-backend
                              t "lab-backend.service starts at boot (enabled)" systemctl is-enabled --quiet lab-backend
  else printf '  SKIP  %s\n' "systemd checks (this machine has no systemd; run on the KodeKloud Playground)"; fi
  t "backend answers on 127.0.0.1:${BACKEND_PORT}"     curl -fsS --max-time 3 "http://127.0.0.1:${BACKEND_PORT}/healthz"
  t "backend listens on localhost only (not 0.0.0.0)"  bash -c "! ss -ltn | grep -qE '(0\\.0\\.0\\.0|\\*):${BACKEND_PORT} '"
  t "backend runs as the unprivileged user labapp"     bash -c "ps -o user= -C python3 | grep -qx labapp || ps -eo user,args | grep '[a]pp.py' | grep -q '^labapp'"

  echo "NGINX + TLS"
  t "nginx configuration is valid (nginx -t)"          nginx -t
  t "HTTPS reaches the backend through nginx"          bash -c "curl -ks --max-time 3 https://127.0.0.1/ | grep -q lab-backend"
  t "backend sees X-Forwarded-Proto: https"            bash -c "curl -ks --max-time 3 https://127.0.0.1/ | grep -q '\"x_forwarded_proto\": \"https\"'"
  t "HTTP on port 80 redirects to HTTPS (301)"         bash -c "[ \"\$(curl -s --max-time 3 -o /dev/null -w '%{http_code}' http://127.0.0.1/)\" = 301 ]"
  t "old TLS 1.1 is refused"                           bash -c "! curl -ks --max-time 3 --tlsv1.1 --tls-max 1.1 -o /dev/null https://127.0.0.1/"
  t "TLS 1.2 or newer works"                           curl -ks --max-time 3 --tlsv1.2 -o /dev/null https://127.0.0.1/
  t "nginx does not reveal its version"                bash -c "! curl -ksI --max-time 3 https://127.0.0.1/ | grep -qi 'nginx/'"

  echo "Health-check + log rotation script"
  t "lab-maintenance.sh is installed and executable"   test -x /usr/local/bin/lab-maintenance.sh
  t "health check reports HEALTHY (exit 0)"            /usr/local/bin/lab-maintenance.sh check
  t "cron runs it every 5 minutes"                     grep -q 'lab-maintenance.sh all' /etc/cron.d/lab-maintenance
  # test rotation on a throw-away folder so the real logs are not touched
  local pdir probe; pdir=$(mktemp -d); probe=$pdir/probe.log
  head -c 4096 /dev/zero | tr '\0' 'x' > "$probe"
  t "a big log is rotated to .1.gz and emptied"        bash -c "LOG_DIR=$pdir MAX_BYTES=1000 /usr/local/bin/lab-maintenance.sh rotate && [ -f $probe.1.gz ] && [ ! -s $probe ]"
  t "rotating again does nothing (small file untouched)" bash -c "echo small > $probe; LOG_DIR=$pdir MAX_BYTES=1000 /usr/local/bin/lab-maintenance.sh rotate; [ \"\$(cat $probe)\" = small ]"
  rm -rf "$pdir"

  echo "Idempotency"
  local out; out=$(bash "$0" all 2>&1 | tail -3)
  t "running 'all' a second time makes 0 changes"      bash -c "grep -q ' 0 change' <<<\"$out\""

  echo
  echo "Result: $PASS passed, $FAILS failed, $WARNS warning(s)"
  (( FAILS == 0 ))
}

step_status() {
  say "Status"
  if (( HAVE_SYSTEMD )); then systemctl --no-pager --lines=0 status lab-backend nginx 2>&1 | grep -E 'Loaded|Active|●' || true
  else pgrep -fa 'app.py|nginx: master' || true; fi
  curl -ks --max-time 3 https://127.0.0.1/ || true; echo
  tail -n 5 /var/log/lab/health.log 2>/dev/null || true
}

case ${1:-help} in
  harden)      step_harden ;;
  backend)     step_backend ;;
  nginx)       step_nginx ;;
  maintenance) step_maintenance ;;
  all)         step_harden; step_backend; step_nginx; step_maintenance
               say "Done: ${CHANGES} change(s) made"
               info "run it again: it should say 0 changes.   Then: sudo bash $0 verify" ;;
  verify)      step_verify ;;
  status)      step_status ;;
  *)           sed -n '2,15p' "$0"; exit 2 ;;
esac
[[ ${1:-} =~ ^(harden|backend|nginx|maintenance)$ ]] && { say "${CHANGES} change(s) made"; }
exit 0
