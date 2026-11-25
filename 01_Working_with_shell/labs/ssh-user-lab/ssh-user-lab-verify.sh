#!/usr/bin/env bash
# Proves the restrictions from ssh-user-lab.sh by logging in over real SSH as each user.
#   sudo bash /lab/scripts/ssh-user-lab-verify.sh [port]
set -uo pipefail
PORT=${1:-22} KEYDIR=/root/ssh-user-lab-keys
SSH=(ssh -p "$PORT" -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
pass=0 fail=0
# A "deny" test must fail because of permissions, not because sshd is down - so check sshd first.
for _ in $(seq 20); do (exec 3<>/dev/tcp/127.0.0.1/$PORT) 2>/dev/null && break; sleep 0.5; done
(exec 3<>/dev/tcp/127.0.0.1/$PORT) 2>/dev/null || { echo "sshd is not listening on port $PORT" >&2; exit 2; }
check() {  # check "<description>" <expect: ok|deny> <command...>
  local desc=$1 expect=$2; shift 2
  local out; out=$("$@" 2>&1); local rc=$?
  if { [[ $expect == ok ]] && (( rc == 0 )); } || { [[ $expect == deny ]] && (( rc != 0 )); }; then
    printf 'PASS  %-55s %s\n' "$desc" "$(head -1 <<<"$out")"; ((pass++))
  else
    printf 'FAIL  %-55s rc=%s %s\n' "$desc" "$rc" "$(head -1 <<<"$out")"; ((fail++))
  fi
}
G=("${SSH[@]}" -i $KEYDIR/guest_ed25519 guest@localhost)

echo "== guest over SSH (key) =="
check "guest can log in with key"                  ok   "${G[@]}" 'id'
check "guest can NOT log in with password"         deny ssh -p "$PORT" -o BatchMode=yes -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR guest@localhost true
check "guest can NOT list /home/madhav"            deny "${G[@]}" 'ls /home/madhav'
check "guest can NOT list ~madhav/secret"          deny "${G[@]}" 'ls /home/madhav/secret'
check "guest can NOT read secret/private.txt"      deny "${G[@]}" 'cat /home/madhav/secret/private.txt'
check "guest CAN read the one ACL-shared file"     ok   "${G[@]}" 'cat /home/madhav/secret/for-guest.txt'
check "guest can NOT write into madhav's home"     deny "${G[@]}" 'touch /home/madhav/hack'
check "guest CAN read /srv/share (team group)"     ok   "${G[@]}" 'cat /srv/share/runbook.md'
check "guest can NOT write /srv/share (2750)"      deny "${G[@]}" 'touch /srv/share/x'
check "guest can NOT read /etc/shadow"             deny "${G[@]}" 'cat /etc/shadow'
check "guest can NOT use sudo"                     deny "${G[@]}" 'sudo -n true'

echo "== guestsftp (SFTP only, chroot) =="
S=(sftp -P "$PORT" -b - -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -i $KEYDIR/sftp_ed25519 guestsftp@localhost)
check "guestsftp can NOT get a shell"              deny "${SSH[@]}" -i $KEYDIR/sftp_ed25519 guestsftp@localhost 'id; echo SHELL_OK' 
check "guestsftp CAN upload into /upload"          ok   bash -c "echo put /etc/hostname | ${S[*]}"
check "guestsftp sees only its jail as /"          ok   bash -c "echo 'ls /' | ${S[*]} | grep -v '^sftp>' | tr -d ' ' | grep -qx '/upload'"
check "guestsftp can NOT reach /home/madhav"       deny bash -c "echo 'ls /home/madhav' | ${S[*]}"

echo
echo "Result: $pass passed, $fail failed"
(( fail == 0 ))
