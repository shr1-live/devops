# Introduction to Shell in Linux

- A **shell** is a program that takes the commands you type and asks the Linux kernel to run them.
- Also called a **command-line interpreter**.
- Most common shell on Linux: **Bash** (`/bin/bash`).

## Types of Shell Commands

1. Built-in commands
2. External commands

## 01 Built-in Commands

- Built into the shell program itself (part of Bash, not of the Linux distribution).
- The shell runs them directly without starting a separate program, so they are fast.

Examples:

| Command | Use                                   |
| ------- | ------------------------------------- |
| `echo`  | Print text in the shell               |
| `cd`    | Change the working directory          |
| `pwd`   | Print the present working directory   |
| `type`  | Show whether a command is built-in    |

## 02 External Commands

- Not part of the shell. Each one is a separate program (an executable file) stored on disk.
- Usually stored in `/bin` or `/usr/bin`.
- The shell finds them by searching the directories listed in the `PATH` variable.
- Most come pre-installed (for example in the `coreutils` package). Others are installed with a package manager such as `apt` or `yum`.

Examples:

| Command  | Use                                                    |
| -------- | ------------------------------------------------------ |
| `mv`     | Move or rename a file or directory                     |
| `cp`     | Copy a file or directory                               |
| `date`   | Print the current local date and time                  |
| `uptime` | Show how long the system has been running since boot   |

## Check the Type of a Command

```bash
type echo     # echo is a shell builtin
type mv       # mv is /usr/bin/mv
echo $PATH    # directories the shell searches for external commands
```

Next: [[02_Basic_linux_commands]], [[03_Paths]]
