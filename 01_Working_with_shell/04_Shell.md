# Shell

A **shell** is a program that sits between you and the operating system kernel. It reads the commands you type, interprets them, and asks the kernel to run them, then shows you the output.

- It is both a **command interpreter** (interactive use in a terminal) and a **scripting language** (you can save commands in a file and run them as a script).
- The **terminal** is just the window that displays text; the **shell** is the program running inside it that understands commands.

```bash
echo $SHELL   # your default (login) shell, e.g. /bin/bash
echo $0       # the shell you are running right now
```

## Bash Environment Variables

Variables store values the shell and programs can read. **Environment variables** are passed down to every program/child process started from the shell.

Common ones:

1. `$HOME` – your home directory (e.g. `/home/fiftyfive`)
2. `$SHELL` – your default login shell (e.g. `/bin/bash`)
3. `$USER` – current username (e.g. `fiftyfive`)
4. `$PWD` – present working directory (e.g. `/home/fiftyfive`)
5. `$PATH` – list of directories searched for commands (see below)

Useful commands:

```bash
env                                  # list all environment variables
echo $HOME                           # print one variable
export NEW_VAR=some_value            # set an ENVIRONMENT variable (visible to child processes)
NEW_VAR=some_value                   # set a SHELL variable (only in the current shell, NOT passed to child programs)
unset NEW_VAR                        # remove a variable
```

> [!note] `export` vs no `export`
> `NEW_VAR=value` creates a plain shell variable. It will **not** show up in `env` and programs you start can't see it. Add `export` to turn it into an environment variable.
> Either way the variable only lasts for the current terminal session. To make it permanent, put the `export` line in a startup file like `~/.profile` or `~/.bashrc`.

### `~/.profile` and `~/.pam_environment`

- **`~/.profile`** – a shell script that runs **once when you log in** (login shell). Used to set environment variables like `PATH` that should apply to your whole session.
  - Bash reads `~/.bash_profile` (or `~/.bash_login`) first if it exists; only if neither exists does it read `~/.profile`.
  - `~/.bashrc` runs for every new **interactive, non‑login** shell (e.g. each new terminal tab) – good place for aliases and the prompt (`PS1`).
  - After editing, apply changes without logging out: `source ~/.profile`
- **`~/.pam_environment`** – not a script, just simple `KEY=value` lines read by PAM (the login/authentication system) at login, so it applies to all programs, not just shells.
  - It is **deprecated**: newer PAM versions ignore it by default. Prefer `~/.profile` (or `/etc/environment` for system‑wide variables).

### PATH Variable

`PATH` is a colon (`:`) separated list of directories. When you type a command, the shell searches these directories **from left to right** and runs the first matching executable it finds.

```bash
[~]$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Example: a program installed somewhere that is **not** in `PATH`:

```bash
[~]$ which obs-studio            # prints nothing -> not found in any PATH directory
[~]$ obs-studio
obs-studio: command not found    # shell can't find it, even though it's installed in /opt/obs/bin

[~]$ export PATH=$PATH:/opt/obs/bin   # append /opt/obs/bin to the existing PATH

[~]$ which obs-studio
/opt/obs/bin/obs-studio          # now the shell finds it
```

What happened step by step:

1. `echo $PATH` – show the directories the shell searches.
2. `which obs-studio` – `which` shows the full path of the command the shell would run. No output means it's not in any `PATH` directory.
3. Running `obs-studio` fails with _command not found_ because `/opt/obs/bin` isn't in `PATH`.
4. `export PATH=$PATH:/opt/obs/bin` – keeps the old value (`$PATH`) and **appends** the new directory. Never do `export PATH=/opt/obs/bin` alone, that would replace PATH and break commands like `ls`.
5. `which obs-studio` now finds it at `/opt/obs/bin/obs-studio`.

> [!tip]
> This change only lasts for the current terminal. To make it permanent, add `export PATH=$PATH:/opt/obs/bin` to `~/.profile` (or `~/.bashrc`).
> Without changing PATH you can always run a program by its full path: `/opt/obs/bin/obs-studio`.

## Different types of shells

1. Bourne Shell (`sh`) – the original Unix shell
2. C Shell (`csh` or `tcsh`) – C‑like syntax
3. Korn Shell (`ksh`) – adds features on top of `sh`
4. Z Shell (`zsh`) – highly customizable, default on macOS
5. Bourne Again Shell (`bash`) – default on most Linux distributions

## Features of Bash Shell

1. Auto completion of commands and file names using the `Tab` key
2. Alias for a command: `alias dt=date`, then you can type `dt` instead of `date`
3. Command history using the `history` command (use `↑`/`↓` keys or `!n` to rerun command number `n`)

## Change shell

```bash
cat /etc/shells          # list shells installed / allowed on the system
echo $SHELL              # current default shell
chsh -s /bin/zsh         # change YOUR default login shell to zsh (asks for your password)
```

- The change takes effect the **next time you log in** (log out and back in, or open a new login session).
- To just try another shell temporarily, run it directly: `zsh` (type `exit` to come back to bash).

## Bash Prompt

The **prompt** is the text bash shows before your cursor, waiting for a command, e.g.

```text
[~]$
[michael@prod-server]$
```

- `~` is shorthand for your **home directory**. The prompt shows your present working directory, and when you're in your home directory it is displayed as `~`.
- `$` means you are a normal user; `#` means you are `root`.
- Showing `user@hostname` in the prompt is useful so you always know **which user you are and which server you're on** (e.g. not accidentally running commands on `prod-server`).

The prompt is controlled by the `PS1` variable:

```bash
echo $PS1                # see the current prompt format
PS1="[\w]$ "             # -> [~]$
PS1="[\u@\h]$ "          # -> [michael@prod-server]$
PS1="[\u@\h \W]\$ "      # -> [michael@prod-server ~]$
```

Common escape sequences:

| Code | Meaning                                       |
| ---- | --------------------------------------------- |
| `\u` | username                                      |
| `\h` | hostname (up to the first `.`)                |
| `\w` | full current working directory (`~` for home) |
| `\W` | only the last folder of the current directory |
| `\d` | date (e.g. `Thu Nov 19`)                      |
| `\t` | time in 24h `HH:MM:SS`                        |
| `\$` | `$` for normal user, `#` for root             |

Colors can be added with ANSI codes, e.g. green username and blue directory:

```bash
PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "
```

> [!tip]
> Setting `PS1` in the terminal only lasts for that session. To keep it, add the `PS1=...` line to `~/.bashrc`, then run `source ~/.bashrc`.
