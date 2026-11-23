# Paths in Linux

A path tells the shell where a file or directory is. There are two types:

1. Absolute path
2. Relative path

Commands that use paths: [[02_Basic_linux_commands]].

## Special Path Symbols

| Symbol | Meaning                                                |
| ------ | ------------------------------------------------------ |
| `/`    | Root directory (top of the file system)                |
| `~`    | Home directory of the current user (`/home/fiftyfive`) |
| `.`    | Current directory                                      |
| `..`   | Parent directory (one level up)                        |

## 01 Absolute Path

- Full path starting from the root `/`.
- Works the same no matter which directory you are in.

```bash
cd /home/fiftyfive/Asia
cd ~/Asia        # same as above, ~ expands to /home/fiftyfive
```

## 02 Relative Path

- Path starting from the **current directory** (does not start with `/`).
- Result depends on where you are right now (check with `pwd`).

```bash
# Current directory: /home/fiftyfive
cd Asia          # goes to /home/fiftyfive/Asia
cd ../Europe     # from Asia: go up one level, then into Europe
```
