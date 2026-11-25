#!/usr/bin/env bash
# SSH user lab (idempotent). Run as root / with sudo inside the Linux box:
#   sudo bash /lab/scripts/ssh-user-lab.sh          (D:\Devops linux-lab box)
#   sudo bash ~/devops/01_Working_with_shell/labs/ssh-user-lab/ssh-user-lab.sh   (repo container)
#
# What it builds
#   shivanshu      : the owner. Private home (700) + private folder ~/secret (700), umask 077.
#   team        : group for people I share with.
#   /srv/share  : shivanshu:team 2750  -> team can READ, nobody else can see it.
#   guest       : SSH user given to another person. Key-only login, member of team.
#                 Can read /srv/share, CANNOT read /home/shivanshu, cannot use sudo.
#   guestsftp   : SFTP-only user, chrooted to /sftp/guestsftp. No shell, sees only its jail.
#   ACL demo    : guest gets read on ONE file (~/secret/for-guest.txt) without opening the folder.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo bash $0" >&2; exit 1; }

OWNER=shivanshu GUEST=guest SFTP_USER=guestsftp GROUP=team
KEYDIR=/root/ssh-user-lab-keys          # in real life the other person creates the key and sends you only the .pub

need=()
command -v setfacl >/dev/null || need+=(acl)
[[ -x /usr/sbin/sshd ]]      || need+=(openssh-server)
command -v sftp >/dev/null   || need+=(openssh-client)
if (( ${#need[@]} )); then apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${need[@]}" >/dev/null; fi

echo "== 1. Group and users =="
getent group "$GROUP" >/dev/null || groupadd "$GROUP"
id "$OWNER" &>/dev/null || useradd -m -s /bin/bash "$OWNER"
id "$GUEST" &>/dev/null || useradd -m -s /bin/bash -G "$GROUP" "$GUEST"
usermod -aG "$GROUP" "$OWNER"
usermod -aG "$GROUP" "$GUEST"
passwd -l "$GUEST" >/dev/null           # no password at all -> key-only
id "$SFTP_USER" &>/dev/null || useradd -M -d / -s /usr/sbin/nologin "$SFTP_USER"
passwd -l "$SFTP_USER" >/dev/null

echo "== 2. Lock down the owner's folders =="
chmod 700 "/home/$OWNER"                # rwx------  only shivanshu (and root) can enter
install -d -m 700 -o "$OWNER" -g "$OWNER" "/home/$OWNER/secret"
echo "salary sheet, tokens, private notes" > "/home/$OWNER/secret/private.txt"
echo "hello guest, you may read only this file" > "/home/$OWNER/secret/for-guest.txt"
chown "$OWNER:$OWNER" /home/$OWNER/secret/*.txt
chmod 600 /home/$OWNER/secret/*.txt
grep -q '^umask 077' "/home/$OWNER/.bashrc" || echo 'umask 077   # new files 600, new dirs 700' >> "/home/$OWNER/.bashrc"
chmod 750 "/home/$GUEST"                # guest's home private too

echo "== 3. Shared folder for the team (read-only for members) =="
install -d -m 2750 -o "$OWNER" -g "$GROUP" /srv/share   # setgid: new files inherit group team
echo "team runbook v1" > /srv/share/runbook.md
chown "$OWNER:$GROUP" /srv/share/runbook.md; chmod 640 /srv/share/runbook.md

echo "== 4. ACL: give guest ONE file, not the whole folder =="
setfacl -m u:$GUEST:--x "/home/$OWNER"               # traverse only, cannot list
setfacl -m u:$GUEST:--x "/home/$OWNER/secret"        # traverse only, cannot list
setfacl -m u:$GUEST:r-- "/home/$OWNER/secret/for-guest.txt"

echo "== 5. SSH key for guest =="
install -d -m 700 "$KEYDIR"
[[ -f $KEYDIR/guest_ed25519 ]] || ssh-keygen -q -t ed25519 -N '' -C "guest@lab" -f "$KEYDIR/guest_ed25519"
install -d -m 700 -o "$GUEST" -g "$GUEST" "/home/$GUEST/.ssh"
install -m 600 -o "$GUEST" -g "$GUEST" "$KEYDIR/guest_ed25519.pub" "/home/$GUEST/.ssh/authorized_keys"
[[ -f $KEYDIR/sftp_ed25519 ]] || ssh-keygen -q -t ed25519 -N '' -C "guestsftp@lab" -f "$KEYDIR/sftp_ed25519"

echo "== 6. SFTP-only chroot jail =="
# ChrootDirectory and every parent must be owned by root and NOT writable by group/others.
install -d -m 755 -o root -g root /sftp "/sftp/$SFTP_USER"
install -d -m 700 -o "$SFTP_USER" -g "$SFTP_USER" "/sftp/$SFTP_USER/upload"
install -d -m 755 -o root -g root /etc/ssh/authorized_keys
install -m 644 -o root -g root "$KEYDIR/sftp_ed25519.pub" "/etc/ssh/authorized_keys/$SFTP_USER"

echo "== 7. sshd config =="
cat > /etc/ssh/sshd_config.d/50-ssh-user-lab.conf <<CONF
# ssh-user-lab: per-user rules
Match User $GUEST
    PasswordAuthentication no
    AllowTcpForwarding no
    X11Forwarding no
    PermitTTY yes

Match User $SFTP_USER
    AuthorizedKeysFile /etc/ssh/authorized_keys/%u
    ChrootDirectory /sftp/%u
    ForceCommand internal-sftp -d /upload
    PasswordAuthentication no
    AllowTcpForwarding no
    X11Forwarding no
    PermitTTY no
CONF
# Lab 6's harden-ssh.sh sets "AllowUsers dev"; add our users so they are not shut out.
h=/etc/ssh/sshd_config.d/99-hardening.conf
if [[ -f $h ]] && grep -q '^AllowUsers' "$h"; then
  for u in "$GUEST" "$SFTP_USER"; do grep -qE "^AllowUsers.*\b$u\b" "$h" || sed -i "s/^AllowUsers.*/& $u/" "$h"; done
fi
mkdir -p /run/sshd
sshd -t                                  # validate before reload - never lock yourself out
if pidof systemd >/dev/null 2>&1 && systemctl is-active -q ssh; then systemctl reload ssh
elif pgrep -x sshd >/dev/null; then pkill -HUP -x sshd
else /usr/sbin/sshd; fi
for _ in $(seq 20); do (exec 3<>/dev/tcp/127.0.0.1/22) 2>/dev/null && break; sleep 0.5; done   # wait until sshd is back

echo
echo "Done. Keys are in $KEYDIR. Next: sudo bash $(dirname "$0")/ssh-user-lab-verify.sh"
