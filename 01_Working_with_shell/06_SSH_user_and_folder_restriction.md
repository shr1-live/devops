# SSH User and Folder Restriction

Plan: [[00_Learning_Plan]] (Week 1: users, permissions, SSH hardening). Builds on [[05_Filesystem_and_permissions]].

**Task:** create an SSH user on a local Linux box, give it to another person, and make sure that person cannot see or touch *my* folders. Then prove it.

Lab scripts: `01_Working_with_shell/labs/ssh-user-lab/` (`ssh-user-lab.sh` builds everything, `ssh-user-lab-verify.sh` logs in over real SSH and checks each rule). Done on 2026-11-25, result **15 passed, 0 failed**.

## 01 The core idea

Linux decides every access with one question: **who are you (UID, groups) and what do the permission bits / ACL on this file say for you?**
SSH only gets the person *in*. What they can do after login is controlled by:

| Layer | Tool | What it stops |
| ----- | ---- | ------------- |
| Identity | `useradd`, separate UID, no `sudo` group | Being "me" or root |
| Login method | `authorized_keys`, `passwd -l`, `sshd_config` `Match User` | Password guessing, port forwarding |
| Files / folders | `chmod`, `chown`, `umask` | Reading or listing my home |
| Exceptions | `setfacl` (ACL) | Sharing one file without opening the folder |
| Teams | group + setgid dir (`2750`/`2770`) | Sharing a folder with only some users |
| Jail | `ChrootDirectory` + `internal-sftp` | Seeing the rest of the filesystem at all |

## 02 Directory permissions are the real lock

| Bit on a **directory** | Means |
| ---------------------- | ----- |
| `r` | list the names inside (`ls`) |
| `w` | create / delete / rename inside (needs `x` too) |
| `x` | *traverse*: `cd` into it or open a file whose name you already know |

- `chmod 700 /home/shivanshu` → only shivanshu (and root) can enter. Everything below is safe, whatever the file modes are.
- `x` without `r` = "you can walk through but can't look around". The ACL trick below uses this.
- Root ignores all of this. Never give the other person `sudo` or the `sudo` group.

## 03 Lab: what I built

```text
shivanshu (owner)    /home/shivanshu          700 + ACL guest:--x
                     /home/shivanshu/secret   700 + ACL guest:--x
                       private.txt            600
                       for-guest.txt          600 + ACL guest:r--
team (group)         /srv/share               shivanshu:team 2750  (setgid, team = read only)
guest (SSH user)     key login only, member of team, no sudo
guestsftp            SFTP only, chroot /sftp/guestsftp, can write /upload
```

### Step 1: users and group

```bash
sudo groupadd team
sudo useradd -m -s /bin/bash shivanshu
sudo useradd -m -s /bin/bash -G team guest     # the account I hand over
sudo passwd -l guest                           # lock password -> key-only login
id guest      # uid=...(guest) gid=...(guest) groups=...(guest),...(team)
```

### Step 2: lock my folders

```bash
sudo chmod 700 /home/shivanshu
sudo install -d -m 700 -o shivanshu -g shivanshu /home/shivanshu/secret
chmod 600 /home/shivanshu/secret/*.txt
echo 'umask 077' >> /home/shivanshu/.bashrc   # new files 600, new dirs 700 from now on
```

`umask` is subtracted from the default `666` (files) / `777` (dirs). `022` → `644`/`755` (others can read). `077` → `600`/`700` (nobody else). Ubuntu 24.04 already creates homes as `750`, but group members could still read; `700` closes that.

### Step 3: a shared folder for the team only

```bash
sudo install -d -m 2750 -o shivanshu -g team /srv/share
```

`2` = **setgid** on a directory: new files inherit group `team` instead of the creator's group. `750` = owner full, team read+enter, others nothing. Use `2770` if the team must write too, and add the sticky bit (`3770`) so people can't delete each other's files.

### Step 4: ACL, share ONE file without opening the folder

```bash
setfacl -m u:guest:--x /home/shivanshu              # traverse only, no listing
setfacl -m u:guest:--x /home/shivanshu/secret
setfacl -m u:guest:r-- /home/shivanshu/secret/for-guest.txt
getfacl /home/shivanshu/secret/for-guest.txt
```

```text
# file: home/shivanshu/secret/for-guest.txt
user::rw-
user:guest:r--
group::---
mask::r--          <- the maximum any ACL entry can give; chmod g-r would silently kill guest's access
other::---
```

`ls -l` shows a `+` at the end of the mode (`-rw-r-----+`) when a file has an ACL. Remove it with `setfacl -x u:guest file`, or all ACLs with `setfacl -b file`.

### Step 5: SSH key for the other person

In real life the other person runs `ssh-keygen -t ed25519` on **their** machine and sends me only the `.pub` file. The private key never leaves them.

```bash
sudo install -d -m 700 -o guest -g guest /home/guest/.ssh
sudo install -m 600 -o guest -g guest guest_ed25519.pub /home/guest/.ssh/authorized_keys
```

`sshd` has `StrictModes yes` by default: if `~/.ssh` or `authorized_keys` is writable by anyone else, key login is **refused** without a clear error. `700` / `600` is required.

### Step 6: per-user sshd rules

`/etc/ssh/sshd_config.d/50-ssh-user-lab.conf`:

```text
Match User guest
    PasswordAuthentication no
    AllowTcpForwarding no
    X11Forwarding no

Match User guestsftp
    AuthorizedKeysFile /etc/ssh/authorized_keys/%u
    ChrootDirectory /sftp/%u
    ForceCommand internal-sftp -d /upload
    PasswordAuthentication no
    AllowTcpForwarding no
    PermitTTY no
```

```bash
sudo sshd -t && sudo systemctl reload ssh    # always test before reload, or you can lock yourself out
```

If `AllowUsers` is set (Lab 6 `harden-ssh.sh` sets `AllowUsers dev`), the new users must be added to it or they cannot log in at all.

### Step 7: SFTP-only chroot jail (strongest option)

For someone who only needs to drop files, don't give a shell at all.

```bash
sudo useradd -M -d / -s /usr/sbin/nologin guestsftp
sudo install -d -m 755 -o root -g root /sftp /sftp/guestsftp          # jail: root-owned, not writable
sudo install -d -m 700 -o guestsftp -g guestsftp /sftp/guestsftp/upload
```

Chroot rule: the `ChrootDirectory` **and every parent** must be owned by root and not writable by group/others, otherwise sshd drops the connection (`bad ownership or modes for chroot directory` in `journalctl -u ssh`). That's why the user writes into a subfolder `upload/`.

## 04 Proof (real output of `ssh-user-lab-verify.sh`)

```text
== guest over SSH (key) ==
PASS  guest can log in with key              uid=30034(guest) gid=30034(guest) groups=30034(guest),30002(team)
PASS  guest can NOT log in with password     Permission denied (publickey)
PASS  guest can NOT list /home/shivanshu        ls: cannot open directory '/home/shivanshu': Permission denied
PASS  guest can NOT list ~shivanshu/secret      ls: cannot open directory '/home/shivanshu/secret': Permission denied
PASS  guest can NOT read secret/private.txt  cat: /home/shivanshu/secret/private.txt: Permission denied
PASS  guest CAN read the one ACL-shared file hello guest, you may read only this file
PASS  guest can NOT write into shivanshu's home touch: cannot touch '/home/shivanshu/hack': Permission denied
PASS  guest CAN read /srv/share (team group) team runbook v1
PASS  guest can NOT write /srv/share (2750)  touch: cannot touch '/srv/share/x': Permission denied
PASS  guest can NOT read /etc/shadow         cat: /etc/shadow: Permission denied
PASS  guest can NOT use sudo                 sudo: a password is required
== guestsftp (SFTP only, chroot) ==
PASS  guestsftp can NOT get a shell          This service allows sftp connections only.
PASS  guestsftp CAN upload into /upload      sftp> put /etc/hostname
PASS  guestsftp sees only its jail as /      (ls / shows only /upload)
PASS  guestsftp can NOT reach /home/shivanshu   sftp> ls /home/shivanshu

Result: 15 passed, 0 failed
```

## 05 Run it yourself

```bash
# repo container (this repo's compose.yaml)
docker compose up -d && docker compose exec -u root ubuntu bash
bash ~/devops/01_Working_with_shell/labs/ssh-user-lab/ssh-user-lab.sh
bash ~/devops/01_Working_with_shell/labs/ssh-user-lab/ssh-user-lab-verify.sh

# D:\Devops linux-lab box (http://localhost:7681)
sudo bash /lab/scripts/ssh-user-lab.sh && sudo bash /lab/scripts/ssh-user-lab-verify.sh
```

Then do it again **by hand** without the script.

Cleanup: `sudo userdel -r guest; sudo userdel guestsftp; sudo userdel -r shivanshu; sudo groupdel team; sudo rm -rf /srv/share /sftp /etc/ssh/authorized_keys /etc/ssh/sshd_config.d/50-ssh-user-lab.conf /root/ssh-user-lab-keys; sudo systemctl reload ssh`

## 06 Things that went wrong / gotchas

- A "deny" test passed while sshd was restarting (connection refused also looks like a failure). Fixed by waiting for port 22 before testing. Lesson: a negative test must fail **for the right reason**.
- `chmod 700` on home + ACL `x` on the dir: guest can open a file only if they already know the exact path. They still cannot `ls`.
- `chmod g-r` on a file with an ACL changes the **mask**, not the group entry, and silently removes the ACL user's read.
- `passwd -l` locks only the password. Key login still works (that's what we want). To block a user fully: `usermod -L -e 1 user` or `-s /usr/sbin/nologin`.

## 07 Interview questions

1. *Other user can `cd` into your folder but not `ls` it. What permissions?* → `--x` (traverse without read), e.g. `711` or ACL `u:x:--x`.
2. *Why `700` on `~/.ssh` and `600` on `authorized_keys`?* → `StrictModes`; sshd refuses keys anyone else could edit.
3. *Difference between `chmod 2770` and `1777`?* → setgid dir (group inheritance) vs sticky bit (only the owner can delete own files, like `/tmp`).
4. *Give a contractor upload-only access?* → SFTP-only user, `ForceCommand internal-sftp`, `ChrootDirectory` owned by root, writable `upload/` inside.
5. *Can root read your `700` folder?* → Yes. Protection from root needs encryption, not permissions.

Next: [[05_Filesystem_and_permissions]] quick check, then processes and systemd.
