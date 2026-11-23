# Basic Linux Commands

Paths used below (absolute vs relative) are explained in [[03_Paths]].

## pwd

Prints the **present working directory** (where you are right now).

```bash
pwd   # /home/fiftyfive
```

## ls

Lists the contents of a directory (the current one if no path is given).

```bash
ls             # list files and directories
ls -l          # long format: permissions, owner, size, modified time
ls -a          # include hidden files (names starting with .)
ls -lt         # sort by modified time, newest first
ls -ltr        # sort by modified time, oldest first (-r = reverse)
ls -la Asia    # long format + hidden files, inside Asia
```

## mkdir

Creates one or more directories.

```bash
mkdir Asia                    # create Asia
mkdir Europe Africa America   # create 3 directories at once
mkdir China/Shanghai          # ERROR if China does not exist
mkdir -p China/Shanghai       # -p creates missing parent directories too
```

## cd

Changes the current directory.

```bash
cd Asia      # go into Asia → /home/fiftyfive/Asia (check with pwd)
cd ..        # go up one level → /home/fiftyfive
cd           # go to home directory (same as cd ~)
cd -         # go back to the previous directory
```

## pushd and popd

Used to **jump to a directory and come back later** without remembering or retyping the path.

The shell keeps a list called the **directory stack**. Think of it as a stack of plates:

- `pushd <dir>`: puts the current directory on top of the stack, then goes to `<dir>`.
- `popd`: takes the top directory off the stack and goes back to it.
- `dirs -v`: shows the stack (top entry is listed first, numbered 0).

Both commands print the stack after they run. The first entry is always the directory you are in now.

### Example

```bash
pwd                          # /home/fiftyfive

pushd /etc                   # save /home/fiftyfive, go to /etc
# /etc ~

pushd /var/log               # save /etc, go to /var/log
# /var/log /etc ~

popd                         # remove /var/log, go back to /etc
# /etc ~

popd                         # remove /etc, go back to home
# ~
```

Step by step:

| Command          | You are now in    | Stack (left = top) |
| ---------------- | ----------------- | ------------------ |
| start            | `/home/fiftyfive` | `~`                |
| `pushd /etc`     | `/etc`            | `/etc ~`           |
| `pushd /var/log` | `/var/log`        | `/var/log /etc ~`  |
| `popd`           | `/etc`            | `/etc ~`           |
| `popd`           | `/home/fiftyfive` | `~`                |

### Why use it instead of cd?

- `cd -` only remembers **one** previous directory.
- `pushd`/`popd` remember **many**, in order (last in, first out).
- Handy in scripts: `pushd` into a folder, do some work, `popd` to return exactly where you started.

> Note: `pushd`, `popd` and `dirs` are Bash built-in commands.

## mv

Moves or renames a file or directory. Works with absolute or relative paths.

- 1st argument: source (what to move)
- 2nd argument: destination (where to move it / new name)

### Move

```bash
mv source_path destination_path
mv Europe/Morocco Africa/       # move Morocco into Africa
```

### Rename

Renaming = moving to the same place with a new name.

```bash
mv old_name new_name
mv India/Munbai India/Mumbai    # fix the typo in the name
```

> If the destination file already exists, `mv` overwrites it without asking. Use `mv -i` to get a prompt.

## cp

Copies a file or directory. Works with absolute or relative paths.

- 1st argument: source (what to copy)
- 2nd argument: destination (where to copy it)
- `-r` (recursive) is **required** to copy a directory and everything inside it.

```bash
cp source_path destination_path
cp India/Mumbai/city.txt Egypt/Cairo/   # copy a file
cp -r Europe/Morocco Africa/            # copy a directory
```

## rm

Deletes a file or directory. **There is no recycle bin**, deleted is gone.

```bash
rm India/Mumbai/city.txt   # delete file city.txt
rm -r Egypt/Cairo          # delete directory Cairo and everything inside
rm -i file.txt             # ask for confirmation before deleting
rm -rf Egypt/Cairo         # force delete: no prompts, no error if it doesn't exist
rmdir Asia                 # delete a directory only if it is empty
```

- `-r`: recursive, deletes the directory and everything inside it.
- `-f`: force, never asks for confirmation (even for write-protected files) and ignores missing files.

> **Be careful with `rm -rf`.** It deletes everything silently and can't be undone. Run `pwd` and `ls` first to check what you're deleting. Never run it on `/` or `~`.

## cat

Prints the contents of a file. Can also be used to write to a file.

```bash
cat India/Mumbai/city.txt            # print the file
cat > Africa/Egypt/city.txt          # type text, then Ctrl + D to save and exit (overwrites the file)
cat >> Africa/Egypt/city.txt         # same, but appends to the end of the file
```

## touch

Creates an empty file. If the file already exists, it only updates its modified time.

```bash
touch Asia/China/country.txt
```

## more

Shows a file one screen at a time (read-only).

```bash
more Asia/China/country.txt
```

| Key     | Action                    |
| ------- | ------------------------- |
| `Space` | Next screen               |
| `Enter` | Next line                 |
| `b`     | Previous screen (go back) |
| `/text` | Search for `text`         |
| `q`     | Quit                      |

## less

Like `more`, but with more features: scroll in both directions and it doesn't load the whole file first, so it's better for large files.

```bash
less Asia/China/country.txt
```

| Key                 | Action                    |
| ------------------- | ------------------------- |
| `Up` / `Down` arrow | Scroll one line           |
| `Space` / `b`       | Next / previous screen    |
| `/text`             | Search for `text`         |
| `n` / `N`           | Next / previous match     |
| `g` / `G`           | Go to start / end of file |
| `q`                 | Quit                      |

## Getting Help

Use these when you forget what a command does or which options it has.

| Command          | Use when you want...                                 |
| ---------------- | ---------------------------------------------------- |
| `whatis cmd`     | a one-line description of a command                  |
| `cmd --help`     | a quick list of options                              |
| `help cmd`       | help for a **built-in** command (`cd`, `pushd`)      |
| `man cmd`        | the full manual                                      |
| `apropos word`   | to find a command when you don't know its name       |

### whatis

Shows a one-line description of a command (taken from its man page).

```bash
whatis date
# date (1)             - print or set the system date and time
```

> The `(1)` is the man page section. See `man` below.

### --help

Most external commands print a short summary of their usage and options with `--help`.

```bash
date --help
ls --help | less     # long output? pipe it into less to scroll
```

Built-in commands (see [[01_Intro_to_shell]]) usually don't support `--help`. Use `help` instead:

```bash
help cd
help pushd
```

### man

Opens the full **manual page** of a command: description, all options, examples.

```bash
man ls
man 5 passwd     # open section 5 (file format) instead of section 1
```

- Scroll and search with the same keys as `less` (`Space`, `b`, `/text`, `n`, `q`).
- Common sections:

| Section | Contains                              |
| ------- | ------------------------------------- |
| 1       | User commands (`ls`, `date`)          |
| 5       | File formats (`/etc/passwd`)          |
| 8       | Admin / root commands (`mount`)       |

### apropos

Searches the names and descriptions of all man pages for a keyword. Use it when you know **what you want to do** but not the command name.

```bash
apropos "copy files"     # finds cp, and other commands about copying
apropos directory        # lists commands related to directories
man -k directory         # same as apropos
```

> If `whatis` or `apropos` prints `nothing appropriate`, the search database may be missing. Build it with `sudo mandb`.
