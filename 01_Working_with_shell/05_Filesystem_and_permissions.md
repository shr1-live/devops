# Filesystem Hierarchy, Users and Permissions

Plan: [[00_Learning_Plan]] (Week 1). Builds on [[03_Paths]] and [[04_Shell]].

## 01 Filesystem Hierarchy Standard (FHS)

Everything in Linux hangs off one root `/`. There are no drive letters.

| Directory | What lives there |
| --------- | ---------------- |
| `/etc`    | System-wide configuration files (text). Example: `/etc/nginx/`, `/etc/passwd`, `/etc/ssh/sshd_config` |
| `/var`    | Data that changes while the system runs: logs (`/var/log`), caches, spools, web roots (`/var/www`) |
| `/home`   | Home directory of each normal user |
| `/root`   | Home directory of the `root` user |
| `/bin`, `/usr/bin` | Commands for everyone (on Ubuntu `/bin` is a link to `/usr/bin`) |
| `/sbin`, `/usr/sbin` | Admin commands (`useradd`, `sshd`) |
| `/tmp`    | Temporary files, cleared on reboot |
| `/proc`   | Virtual files showing live kernel and process info (no real disk). `/proc/cpuinfo`, `/proc/<pid>/` |
| `/sys`    | Virtual files for devices and kernel settings |
| `/dev`    | Device files (`/dev/null`, `/dev/sda`) |

```bash
ls /
cat /proc/cpuinfo | head
cat /proc/meminfo | head -3
ls /var/log
```

Everything is a file: even processes (`/proc`) and devices (`/dev`) are read like files.

## 02 Users and groups

- Each user has a numeric **UID**, each group a **GID**. `root` is UID 0 and can do anything.
- Accounts are stored in `/etc/passwd` (name, UID, GID, home, login shell). Password hashes are in `/etc/shadow`, readable only by root.
- Groups are in `/etc/group`.

```bash
id                    # my UID, GID and groups
whoami
getent passwd dev     # one user's line from /etc/passwd
sudo useradd -m -s /bin/bash alice
sudo usermod -aG sudo alice     # add alice to the sudo group (-a keeps her other groups)
sudo passwd alice
```

## 03 Permissions

`ls -l` shows the permissions:

```text
-rwxr-xr--  1 dev  staff  120 Nov 23 10:00 deploy.sh
│└┬┘└┬┘└┬┘
│ │  │  └─ others
│ │  └──── group
│ └─────── owner (user)
└───────── type: - file, d directory, l link
```

| Letter | On a file | On a directory |
| ------ | --------- | -------------- |
| `r` (4) | read contents | list names inside |
| `w` (2) | change contents | create / delete / rename files inside |
| `x` (1) | run it as a program | enter it with `cd` |

Add the numbers per class: `rwx` = 7, `r-x` = 5, `r--` = 4. So `rwxr-xr--` is `754`.

```bash
chmod 754 deploy.sh        # numeric
chmod u+x deploy.sh        # symbolic: add execute for the owner
chmod go-w file            # remove write for group and others
chown alice file           # change owner (needs sudo)
chown alice:staff file     # owner and group
chmod -R 750 mydir         # recursive
```

Common values: `644` files (owner writes, all read), `755` scripts and directories, `600` private files (SSH private key), `700` private directories.

> [!tip]
> A directory needs `x` to be entered. A directory with `r` but no `x` lets you list names but not open anything inside.

## 04 sudo and sudoers

- `sudo cmd` runs one command as root, after checking the **sudoers** rules.
- Rules live in `/etc/sudoers` and `/etc/sudoers.d/`. **Always edit with `sudo visudo`**, which checks syntax. A broken sudoers file can lock you out.
- Members of the `sudo` group get full sudo on Ubuntu.

```text
# who  host=(run-as)  commands
alice  ALL=(ALL)  ALL                         # everything, asks for password
bob    ALL=(ALL)  NOPASSWD: /usr/bin/systemctl restart nginx   # only this command, no password
```

This repo's practice container uses `dev ALL=(ALL) NOPASSWD:ALL` (see the Dockerfile). That is fine for a lab and wrong for a real server. Give the least access needed.

## Quick check (do it in the container)

1. Create `~/perm_test/secret.txt`, set it so only you can read and write it. Show the result with `ls -l`.
2. Remove your `x` permission from `~/perm_test` and try `cd ~/perm_test`. What error do you get? Restore it.
3. Find the shell and home directory of `root` without opening an editor.
4. Create user `alice` without sudo, then try `sudo -u alice cat ~/perm_test/secret.txt`. Why does it fail?

Answers: `chmod 600`; `Permission denied`; `getent passwd root`; alice is "others", and the file has no permission for others.

Next in Week 1: processes and systemd (`systemctl`, `journalctl`), `apt`, then resource tools.
