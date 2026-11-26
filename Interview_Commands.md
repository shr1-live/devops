# Interview Commands: easy to medium

Every command from the lab (http://localhost:7000/ssh-lab.html), in the same order, with what it does. One short command at a time, no tricks.

- **Level 1 Basic**: the commands you must know without thinking.
- **Level 2 Next level**: searching, permissions, processes, ports.
- **Level 3 Medium**: the next step up, built one piece at a time.
- **Interview Q&A**: the question as it is asked, and the short answer.

Where a step says `~/lab` it is a practice folder, so nothing important is touched. Sample files come from `/scripts/lab-files`.

> The Docker topic (5) was written against Docker Desktop but not yet run end to end, because the Docker engine was not responding when this was generated.

---

## 1 · Linux

The commands every Linux interview starts with: files and folders first, then searching, permissions, disk and processes, then users, links and archives.

### Level 1 · Basic

```bash
mkdir -p ~/lab                                # Make a practice folder
cd ~/lab                                      # Go into it
pwd                                           # Where am I?
whoami                                        # Who am I?
touch a.txt                                   # Create an empty file
ls                                            # List the files
echo hello > a.txt                            # Write a line into the file
cat a.txt                                     # Read the file
cp a.txt b.txt                                # Copy it
mkdir notes                                   # Make a folder
mv b.txt notes                                # Move the copy into it
ls -l                                         # List with details
rm a.txt                                      # Delete a file
rm -r notes                                   # Delete a folder
date                                          # Date and time
```

What each one means:

1. `mkdir -p ~/lab`  
   mkdir makes a folder. -p means no error if it already exists. ~ is your home folder. All practice stays inside ~/lab, so nothing else is touched.
2. `cd ~/lab`  
   cd = change directory. cd alone goes home, cd .. goes up one level, cd - goes back to the previous folder.
3. `pwd`  
   pwd = print working directory: the full path of the folder you are in. Interview: 'how do you know where you are?'
4. `whoami`  
   Prints your user name. root is the all-powerful admin. On real servers you are a normal user and put sudo in front of admin commands.
5. `touch a.txt`  
   touch makes an empty file. If the file already exists it only updates its time.
6. `ls`  
   ls lists the folder. Common versions: ls -l (details), ls -a (also hidden files that start with a dot), ls -lh (sizes in KB/MB).
7. `echo hello > a.txt`  
   echo prints text. > sends it into a file and REPLACES what was there. >> adds to the end instead. Interview: 'difference between > and >>'.
8. `cat a.txt`  
   cat prints the whole file. For long files use less (scroll, q to quit), head (first lines) or tail (last lines).
9. `cp a.txt b.txt`  
   cp source destination. Add -r to copy a whole folder.
10. `mkdir notes`  
   mkdir NAME makes one folder. With -p it also makes parent folders: mkdir -p a/b/c.
11. `mv b.txt notes`  
   mv moves AND renames. mv old.txt new.txt renames. There is no separate rename command.
12. `ls -l`  
   -l = long format: permissions, owner, group, size, date, name. First letter d = folder, - = file, l = link.
13. `rm a.txt`  
   rm deletes for good, there is no recycle bin. Interview: 'what does rm -rf / do?' It wipes the system. Never run it.
14. `rm -r notes`  
   -r = recursive, needed for folders and everything inside. rmdir only removes EMPTY folders.
15. `date`  
   Prints the current date and time of the machine. Logs use this clock, so a wrong clock confuses debugging.

### Level 2 · Next level

```bash
cp /scripts/lab-files/access.log .            # Copy a sample web log here
head -3 access.log                            # First lines of a file
tail -2 access.log                            # Last lines of a file
wc -l access.log                              # Count lines
grep 500 access.log                           # Search inside a file
grep -c 200 access.log                        # Count the matches
find . -name '*.log'                          # Find a file by name
chmod 600 access.log                          # Make the file private
ls -l access.log                              # Check the permissions
df -h                                         # Disk space of the machine
du -sh .                                      # Disk space of this folder
free -m                                       # Memory
ps aux                                        # List all processes
sleep 300 &                                   # Start a background process
pgrep sleep                                   # Find its PID
pkill sleep                                   # Stop it
```

What each one means:

1. `cp /scripts/lab-files/access.log .`  
   The dot means 'this folder'. The log has 8 lines: client IP, method, page, status code.
2. `head -3 access.log`  
   head shows the first lines (10 by default). The number after the dash sets how many.
3. `tail -2 access.log`  
   tail shows the last lines. tail -f FILE follows a log live as it grows, Ctrl+C stops. Interview: 'how do you watch a log in real time?'
4. `wc -l access.log`  
   wc = word count. -l counts lines, -w words, -c bytes. Quick way to count requests or users.
5. `grep 500 access.log`  
   grep prints the lines containing the text. Useful flags: -i ignore case, -v lines that do NOT match, -n show line numbers, -r search a whole folder.
6. `grep -c 200 access.log`  
   -c prints how many lines matched: here 5 successful requests.
7. `find . -name '*.log'`  
   find WHERE -name PATTERN. Quotes stop the shell from expanding the *. Interview: find a file anywhere: find / -name nginx.conf
8. `chmod 600 access.log`  
   chmod changes permissions. Each digit is one group: owner, group, others. r=4, w=2, x=1, add them up. 6 = read+write, 0 = nothing.
9. `ls -l access.log`  
   -rw------- = only the owner can read and write. Common values: 755 (programs, folders), 644 (normal files), 600 (private files), 700 (private folders).
10. `df -h`  
   df = disk free for each disk. -h = human sizes. Check Use% and 'Mounted on'. Interview: 'the disk is full, what is your first command?'
11. `du -sh .`  
   du = disk usage of files. -s = one total, -h = human sizes. df tells you WHICH disk is full, du tells you WHICH folder is eating it.
12. `free -m`  
   free shows RAM in MB. Read the 'available' column, not 'free': Linux uses spare RAM as cache, so 'free' always looks small on a healthy machine.
13. `ps aux`  
   ps aux = every running process with user, PID (process id), CPU%, memory% and command. You need the PID to stop a process.
14. `sleep 300 &`  
   & runs the command in the background and gives your prompt back. It prints [job number] and the PID. sleep 300 simply waits 5 minutes.
15. `pgrep sleep`  
   pgrep prints the PIDs of processes with that name. Same idea as ps aux | grep sleep, but shorter.
16. `pkill sleep`  
   pkill sends a polite stop signal (SIGTERM) by name. kill PID does it by number. kill -9 PID (SIGKILL) forces it when the polite one is ignored.

### Level 3 · Medium

```bash
cp /scripts/lab-files/access.log .            # Copy the log again
useradd dev1                                  # Create a user
id dev1                                       # Check the user
grep dev1 /etc/passwd                         # See the account line
usermod -aG sudo dev1                         # Give admin rights
groups dev1                                   # Check the groups
ln -s /etc/hostname mylink                    # Make a shortcut (soft link)
ls -l mylink                                  # Check the link
tar czf logs.tgz access.log                   # Pack a file into an archive
tar tzf logs.tgz                              # Look inside the archive
echo $PATH                                    # Where does the shell look for programs?
export APP=demo                               # Set an environment variable
env | grep APP                                # Check it
dpkg -l curl                                  # Is a package installed?
which ls                                      # Where is a command stored?
uptime                                        # Is the machine busy?
userdel dev1                                  # Remove the user
```

What each one means:

1. `cp /scripts/lab-files/access.log .`  
   Every level starts from fresh files, so you can do the levels in any order.
2. `useradd dev1`  
   useradd makes an account. Real use: useradd -m -s /bin/bash NAME (-m makes a home folder, -s sets the shell). Accounts are stored in /etc/passwd.
3. `id dev1`  
   id shows the user id (uid), main group (gid) and every group the user is in.
4. `grep dev1 /etc/passwd`  
   Colon separated: name, x (the password hash is in /etc/shadow), uid, gid, comment, home folder, shell.
5. `usermod -aG sudo dev1`  
   usermod changes a user. -aG = ADD to a group. Forgetting the -a REPLACES all their groups, a classic mistake. Members of the sudo group may run admin commands.
6. `groups dev1`  
   groups lists the groups of a user. dev1 now shows sudo.
7. `ln -s /etc/hostname mylink`  
   ln -s makes a symbolic link: a small file that points to another path. Without -s you get a hard link: a second name for the same data.
8. `ls -l mylink`  
   The arrow shows the target and the first letter l means link. Delete the target and a soft link breaks, a hard link keeps working.
9. `tar czf logs.tgz access.log`  
   tar c = create, z = gzip compress, f = archive file name. Keep the letters together, then the archive name, then the files.
10. `tar tzf logs.tgz`  
   t = list the contents without unpacking. To unpack: tar xzf logs.tgz (x = extract).
11. `echo $PATH`  
   $PATH is a list of folders separated by colons. When you type ls the shell searches them in order. 'command not found' means the program is in none of them.
12. `export APP=demo`  
   export makes a variable visible to programs you start. Without export it stays inside your shell. To keep it after logout, add the line to ~/.bashrc.
13. `env | grep APP`  
   env lists all environment variables. The pipe | sends env's output into grep, which keeps only the lines that match.
14. `dpkg -l curl`  
   dpkg -l NAME shows the package (ii = installed). Install with apt-get install NAME, remove with apt-get remove NAME.
15. `which ls`  
   which shows the full path of the program that would run. Useful when two versions are installed.
16. `uptime`  
   Shows how long the machine is up and the load average for 1, 5 and 15 minutes. If the load is higher than the number of CPU cores, the machine is overloaded.
17. `userdel dev1`  
   userdel deletes the account (add -r to delete the home folder too).

### On a real server (copy only)

Containers have no systemd, so these are copy-only. Run them on a real Linux server or a KodeKloud playground.

```bash
systemctl status nginx                        # Is a service running?
systemctl restart nginx                       # Start, stop, restart
systemctl enable nginx                        # Start at boot
journalctl -u nginx -n 30                     # Why did it fail? Read its logs
systemctl --failed                            # List failed services
crontab -e                                    # Edit the schedule (cron)
visudo                                        # Edit sudo rules safely
```

1. `systemctl status nginx`  
   Shows active (running) or failed, plus the last log lines. First thing to check when a site is down.
2. `systemctl restart nginx`  
   start / stop / restart / reload. reload re-reads the config without dropping connections.
3. `systemctl enable nginx`  
   enable = start automatically after a reboot. disable turns it off. enable --now does both enable and start.
4. `journalctl -u nginx -n 30`  
   journalctl reads the system journal. -u = one service, -n 30 = last 30 lines, -f = follow live.
5. `systemctl --failed`  
   Shows every service that crashed. Quick health check after a reboot.
6. `crontab -e`  
   Opens your cron table. A line looks like: */5 * * * * /home/me/backup.sh (minute hour day month weekday command).
7. `visudo`  
   Always edit /etc/sudoers with visudo. It checks the syntax before saving, a typo cannot lock you out.

### Interview Q&A

**1. The disk is full. How do you find out why?**

- Step 1: df -h shows which disk is full.
- Step 2: du -sh /var/* shows which folder is the biggest. Repeat one level deeper until you find it.
- Also check: df -i. A disk with free space can still be 'full' if all inodes (file slots) are used by millions of tiny files.

**2. A process uses too much CPU. What do you do?**

- Find it: top (press P to sort by CPU) or ps aux --sort=-%cpu | head.
- Stop it: kill PID first (polite). If it ignores that: kill -9 PID.
- Then: Find out WHY: check its logs, do not just keep killing it.

**3. How do you find a file, and text inside files?**

- File by name: find / -name nginx.conf
- Text inside files: grep -r 'error' /var/log
- Tip: Add 2>/dev/null to hide 'Permission denied' noise.

**4. What do 755, 644 and 600 mean?**

- 755: rwxr-xr-x: owner full, everyone else read and run. For programs and folders.
- 644: rw-r--r--: owner read and write, everyone else read. Normal files.
- 600: rw-------: only the owner. Private keys (ssh refuses keys that are more open).

**5. Hard link vs soft (symbolic) link?**

- Soft: ln -s target link. A pointer to a PATH. Breaks if the target is deleted. Can cross disks.
- Hard: ln target link. Another NAME for the same data. Survives deleting the original name.

**6. What is the difference between >, >> and |?**

- >: Sends output to a file and REPLACES it.
- >>: Sends output to a file and ADDS to the end.
- |: Sends the output of one command into the next command.

**7. How do you check CPU, memory and load?**

- CPU and processes: top
- Memory: free -m (read 'available')
- Load: uptime (compare with the number of cores: nproc)

---

## 2 · Bash scripting

From running a script and reading its exit code, to if and loops, to the log-analysis one-liners interviewers love. Pipes are built up one piece at a time.

### Level 1 · Basic

```bash
mkdir -p ~/lab                                # Make a practice folder
cd ~/lab                                      # Go into it
cp /scripts/lab-files/hello.sh .              # Copy a ready-made script
cat hello.sh                                  # Read the script
ls -l hello.sh                                # Look at its permissions
chmod +x hello.sh                             # Make it executable
./hello.sh                                    # Run it
./hello.sh Asha                               # Run it with an argument
bash hello.sh Ravi                            # Run it with bash directly
echo $?                                       # Exit code of the last command
name=Meera                                    # Set a variable
echo $name                                    # Use the variable
echo "Hello $name"                            # Quotes: double expands, single does not
```

What each one means:

1. `mkdir -p ~/lab`  
   All script practice happens in ~/lab.
2. `cd ~/lab`  
   cd = change directory.
3. `cp /scripts/lab-files/hello.sh .`  
   The script has 3 lines. You will read it next.
4. `cat hello.sh`  
   Line 1 #!/bin/bash (the shebang) says which program runs the file. Line 2 sets name to the first argument ($1), or 'world' if none. Line 3 prints it.
5. `ls -l hello.sh`  
   The x in -rwxr-xr-x means 'may be executed'. A script without x cannot be started with ./script.sh.
6. `chmod +x hello.sh`  
   +x adds the execute permission for everyone. Interview: 'I wrote a script and get Permission denied, why?' You forgot chmod +x.
7. `./hello.sh`  
   ./ means 'in this folder'. Without it the shell only searches $PATH and says command not found.
8. `./hello.sh Asha`  
   Words after the script name are arguments. Inside the script the first is $1, the second $2, how many is $#, all of them is $@.
9. `bash hello.sh Ravi`  
   bash FILE runs the script without needing +x. Handy for a quick test.
10. `echo $?`  
   $? holds the exit code of the previous command. 0 = success, anything else = failure. Scripts and CI pipelines decide pass or fail from this number.
11. `name=Meera`  
   NO spaces around =. name = Meera fails, because the shell thinks name is a command.
12. `echo $name`  
   $name gives the value. Use quotes when it may contain spaces: echo "$name".
13. `echo "Hello $name"`  
   Double quotes expand variables. Single quotes print the text exactly as typed: echo 'Hello $name' prints Hello $name.

### Level 2 · Next level

```bash
cp /scripts/lab-files/check.sh .              # Copy a script with an if
cp /scripts/lab-files/loop.sh .               # Copy a script with a loop
cat check.sh                                  # Read the if script
bash check.sh hello.sh                        # Test: the file exists
bash check.sh nothing.txt                     # Test: the file is missing
echo $?                                       # Read the exit code
bash loop.sh                                  # Run the loop
cp /scripts/lab-files/access.log .            # Copy a sample log
cut -d' ' -f1 access.log                      # Pick one column
grep -c GET access.log                        # Count the GET requests
grep -v 200 access.log                        # Lines that are NOT 200
wc -l access.log                              # Count all lines
```

What each one means:

1. `cp /scripts/lab-files/check.sh .`  
   check.sh tests whether the file given as the first argument exists.
2. `cp /scripts/lab-files/loop.sh .`  
   loop.sh repeats a command three times.
3. `cat check.sh`  
   if [ -f FILE ] is true when the file exists. Other tests: -d folder, -z empty text, -eq number equal. Spaces inside [ ] are required.
4. `bash check.sh hello.sh`  
   The if branch runs and prints found.
5. `bash check.sh nothing.txt`  
   The else branch runs, and the script ends with exit 1 to tell the caller it failed.
6. `echo $?`  
   1 = the script failed on purpose. Without a final exit the script returns the exit code of its last command.
7. `bash loop.sh`  
   for i in 1 2 3 repeats the body once per value. Also common: while read line, and for f in *.log.
8. `cp /scripts/lab-files/access.log .`  
   Columns: IP, method, page, status.
9. `cut -d' ' -f1 access.log`  
   cut -d' ' sets the separator to a space, -f1 picks field 1 (the IP). Try -f4 for the status code.
10. `grep -c GET access.log`  
   grep -c counts matching lines.
11. `grep -v 200 access.log`  
   -v inverts the match: shows everything except 200. First thing to do when looking for failed requests.
12. `wc -l access.log`  
   Total requests = number of lines.

### Level 3 · Medium

```bash
cp /scripts/lab-files/access.log .            # Copy the log again
cut -d' ' -f1 access.log > ips.txt            # Save the IP column to a file
sort ips.txt                                  # Piece 1: sort
sort ips.txt | uniq -c                        # Piece 2: count the repeats
sort ips.txt | uniq -c | sort -rn             # Piece 3: biggest first
awk '{print $4}' access.log                   # awk: print the status column
awk '$4 == 500' access.log                    # awk: filter rows
sed 's/GET/get/' access.log                   # sed: replace text
cp /scripts/lab-files/loose.sh .              # Copy the strict and loose scripts
cp /scripts/lab-files/strict.sh .             # Copy the strict script
bash loose.sh                                 # Run the loose script
bash strict.sh                                # Run the strict script
cp /scripts/lab-files/func.sh .               # Copy a script with a function
bash func.sh                                  # Run it
bash -n hello.sh                              # Check syntax without running
```

What each one means:

1. `cp /scripts/lab-files/access.log .`  
   Fresh start for this level.
2. `cut -d' ' -f1 access.log > ips.txt`  
   > saves output into a file. Now ips.txt has one IP per line. Next we turn it into a 'top clients' list, one piece at a time.
3. `sort ips.txt`  
   sort puts identical lines next to each other. uniq only merges NEIGHBOURING lines, so you must sort first.
4. `sort ips.txt | uniq -c`  
   uniq -c puts a count in front of each distinct line. 10.0.0.1 appears 4 times.
5. `sort ips.txt | uniq -c | sort -rn`  
   sort -rn = numeric, reverse. Add | head -3 for the top 3. This exact pipeline is a very common interview question.
6. `awk '{print $4}' access.log`  
   awk splits each line into fields: $1 first column, $4 fourth, $NF last. print shows them.
7. `awk '$4 == 500' access.log`  
   Only the lines where column 4 equals 500. Server errors. Use $4 >= 500 for all 5xx.
8. `sed 's/GET/get/' access.log`  
   sed 's/old/new/' replaces the first match on every line and prints the result. The file is NOT changed. Add -i to edit in place.
9. `cp /scripts/lab-files/loose.sh .`  
   loose.sh prints start, tries to read a missing file, then prints never printed.
10. `cp /scripts/lab-files/strict.sh .`  
   strict.sh is the same script with one extra line: set -euo pipefail.
11. `bash loose.sh`  
   By default bash keeps going after an error, so 'never printed' IS printed. Dangerous in deploy scripts.
12. `bash strict.sh`  
   set -e stops at the first error, -u stops on an unset variable, -o pipefail fails a pipe if any part fails. Interview: 'what does set -euo pipefail do?'
13. `cp /scripts/lab-files/func.sh .`  
   A function groups commands so you can reuse them.
14. `bash func.sh`  
   greet Asha calls the function and Asha becomes $1 inside it.
15. `bash -n hello.sh`  
   -n reads the script and reports syntax errors but runs nothing. No output means no syntax errors.

### Cron and background jobs (copy only)

Needs cron on a real server. Copy-only.

```bash
crontab -l                                    # List your scheduled jobs
crontab -e                                    # Edit the schedule
0 2 * * * /home/me/backup.sh >> /var/log/backup.log 2>&1# Log the output of a cron job
nohup ./job.sh &                              # Keep a script running after logout
bash -x script.sh                             # Debug a script
```

1. `crontab -l`  
   Shows the cron table of the current user.
2. `crontab -e`  
   Line format: minute hour day-of-month month day-of-week command. */5 * * * * = every 5 minutes. 0 2 * * * = every day at 02:00.
3. `0 2 * * * /home/me/backup.sh >> /var/log/backup.log 2>&1`  
   >> appends the output. 2>&1 sends errors into the same file. Without this, cron output is lost.
4. `nohup ./job.sh &`  
   nohup ignores the hangup signal when you close the terminal. & puts it in the background.
5. `bash -x script.sh`  
   -x prints every command before it runs. Best way to see where a script goes wrong.

### Interview Q&A

**1. What does set -euo pipefail do?**

- -e: Stop at the first command that fails.
- -u: Treat an unset variable as an error.
- -o pipefail: A pipeline fails if ANY command in it fails, not only the last.

**2. What is an exit code?**

- Meaning: A number every command returns. 0 = success, non-zero = failure.
- Read it: echo $? right after the command.
- Use it: if command; then ... fi, or command || exit 1.

**3. Single quotes vs double quotes?**

- Double: Variables and $(commands) are expanded.
- Single: Everything is literal text.

**4. How do you pass and read arguments?**

- Read: $1 $2 ... are the arguments, $# how many, $@ all of them, $0 the script name.

**5. Find the IPs that hit the server most**

- Answer: cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head
- Why sort first?: uniq only merges neighbouring lines.

**6. Read the cron schedule */15 9-17 * * 1-5**

- Meaning: Every 15 minutes, between 09:00 and 17:59, Monday to Friday.
- Order: minute, hour, day of month, month, day of week.

**7. Difference between ; && and ||?**

- ;: Run the next command always.
- &&: Run the next command only if the first SUCCEEDED.
- ||: Run the next command only if the first FAILED.

---

## 3 · Networking

From 'what is my IP' and ping, to DNS and open ports, to who is listening on a port. Everything in Levels 1-3 works offline. The last tab needs internet.

### Level 1 · Basic

```bash
apt-get update -qq                            # Setup: refresh the package list
apt-get install -y -qq iputils-ping dnsutils netcat-openbsd traceroute net-tools# Setup: install the network tools
mkdir -p ~/lab                                # Make a practice folder
hostname                                      # Name of this machine
ip addr                                       # Show IP addresses
ip route                                      # Show the routes
cat /etc/hosts                                # Local name list
cat /etc/resolv.conf                          # Which DNS server is used?
ping -c 2 127.0.0.1                           # Ping this machine
curl --version                                # Is curl there?
```

What each one means:

1. `apt-get update -qq`  
   Downloads the list of available packages. -qq = quiet. Needs internet the first time. Skip it if the tools below are already installed.
2. `apt-get install -y -qq iputils-ping dnsutils netcat-openbsd traceroute net-tools`  
   ping, dig/nslookup, nc, traceroute and netstat are not in a minimal Ubuntu. -y answers yes for you.
3. `mkdir -p ~/lab`  
   Keeps the practice in one place.
4. `hostname`  
   The machine name. In scripts and logs it tells you which server you are on.
5. `ip addr`  
   ip addr (short: ip a) lists every network interface with its IP. lo = loopback (127.0.0.1, this machine itself), eth0 = the real network card. Older name: ifconfig.
6. `ip route`  
   The routing table. 'default via X' = where packets go when no other rule matches: your gateway (router).
7. `cat /etc/hosts`  
   /etc/hosts maps names to IPs on this machine only. It is checked before DNS, so it is a quick way to override a name.
8. `cat /etc/resolv.conf`  
   Lists the DNS servers this machine asks to turn names into IPs.
9. `ping -c 2 127.0.0.1`  
   ping sends small test packets and times the answer. -c 2 = only two (otherwise it never stops, Ctrl+C ends it). 0% packet loss = reachable.
10. `curl --version`  
   curl is the tool for talking HTTP from the terminal. You will use it a lot: -I headers only, -s silent, -v details, -L follow redirects, -o save to a file.

### Level 2 · Next level

```bash
nslookup example.com                          # DNS lookup (easy output)
dig example.com +short                        # DNS lookup (short answer)
getent hosts localhost                        # Name to IP on this machine
ss -tln                                       # Which ports are listening?
nc -l 9000 &                                  # Start a listener on port 9000
ss -tln                                       # Is it listening?
nc -zv 127.0.0.1 9000                         # Test the port
pkill nc                                      # Stop the listener
```

What each one means:

1. `nslookup example.com`  
   nslookup asks DNS for the IP of a name. The first Address is the DNS server, the next ones are the answer.
2. `dig example.com +short`  
   dig is the admin's DNS tool. +short prints only the answer. Try dig example.com MX for mail servers and NS for name servers.
3. `getent hosts localhost`  
   getent uses the same lookup order as programs do: /etc/hosts first, then DNS.
4. `ss -tln`  
   ss lists sockets. -t TCP, -l listening only, -n numbers (do not resolve names). Add -p to see the process. This replaces the older netstat.
5. `nc -l 9000 &`  
   nc (netcat) is the network Swiss army knife. -l waits for a connection. & keeps it in the background. We now have a tiny 'server' to test against.
6. `ss -tln`  
   Port 9000 is in the list. This is how you prove a service is up.
7. `nc -zv 127.0.0.1 9000`  
   -z = just connect, -v = tell me the result. 'succeeded' = open. 'refused' = nothing listens. A hang = a firewall drops the packets.
8. `pkill nc`  
   Clean up the background process.

### Level 3 · Medium

```bash
ip -br addr                                   # Compact address list
ip link                                       # Interface details
ss -s                                         # Socket summary
nc -l 9000 &                                  # Start a listener again
ss -tlnp                                      # Who owns the port?
nc -zv 127.0.0.1 9000                         # Connect to it
pkill nc                                      # Stop the listener
traceroute -m 3 127.0.0.1                     # Trace the path
```

What each one means:

1. `ip -br addr`  
   -br = brief, one line per interface with its state. Easy to read when there are many interfaces.
2. `ip link`  
   Shows state (UP/DOWN), MTU and MAC address. A DOWN interface is the first thing to check when 'the network is dead'.
3. `ss -s`  
   How many TCP connections exist and in which state. Many TIME-WAIT or SYN-RECV entries can point to a problem.
4. `nc -l 9000 &`  
   A small server on port 9000.
5. `ss -tlnp`  
   -p adds the process that owns each port. Interview: 'what is using port 80?' Answer: ss -tlnp | grep :80 (or lsof -i :80).
6. `nc -zv 127.0.0.1 9000`  
   A successful port test. The same command against a real server tells you whether a firewall blocks the port.
7. `pkill nc`  
   Clean up.
8. `traceroute -m 3 127.0.0.1`  
   traceroute shows every router (hop) on the way to a target. -m 3 stops after 3 hops. Stars (* * *) mean a hop does not answer, not necessarily a failure. Here the target is this machine: one hop.

### Needs internet (optional) (optional)

```bash
netstat -tln                                  # Older command for open ports (needs net-tools)
ping -c 2 8.8.8.8                             # Ping the internet
ping -c 2 example.com                         # Ping by name
curl -I https://example.com                   # Fetch only the header
curl -s https://example.com                   # Download the page
nc -zv example.com 443                        # Is a remote port open?
curl -sv https://example.com -o /dev/null     # See the TLS handshake
dig -x 8.8.8.8 +short                         # Reverse DNS
traceroute -m 5 8.8.8.8                       # Trace the path to the internet
```

What each one means:

1. `netstat -tln`  
   netstat shows the same list as ss. Interviewers still ask for it, so know both. It comes from the net-tools package installed in the setup step.
2. `ping -c 2 8.8.8.8`  
   8.8.8.8 is Google's DNS. Works = you have internet by IP. Interview: 'ping works by IP but not by name' means DNS is broken.
3. `ping -c 2 example.com`  
   Needs DNS first, then the ping.
4. `curl -I https://example.com`  
   -I shows the response headers. 200 = OK, 301/302 = redirect, 404 = not found, 500 = server error.
5. `curl -s https://example.com`  
   -s = silent, no progress bar. Add -L to follow redirects.
6. `nc -zv example.com 443`  
   Port 443 = HTTPS. 'succeeded' = reachable.
7. `curl -sv https://example.com -o /dev/null`  
   -v shows DNS, TCP connect, TLS version and certificate. This is how you debug HTTPS problems. -o /dev/null throws the page away.
8. `dig -x 8.8.8.8 +short`  
   -x turns an IP back into a name.
9. `traceroute -m 5 8.8.8.8`  
   Each line is a router on the way.

### Firewall and packet capture (copy only)

Needs a real server with root access. Copy-only.

```bash
ufw status                                    # Firewall status (Ubuntu)
ufw allow 22/tcp                              # Allow SSH
iptables -L -n                                # Low-level firewall rules
tcpdump -i any port 80 -c 10                  # Capture packets on port 80
ssh -L 8080:localhost:80 user@server          # SSH tunnel to a remote port
```

1. `ufw status`  
   ufw is the simple firewall front end. Shows allowed ports.
2. `ufw allow 22/tcp`  
   Always allow SSH BEFORE you enable the firewall, or you lock yourself out. Then ufw allow 443/tcp and ufw enable.
3. `iptables -L -n`  
   Lists the real rules ufw writes. -n = numbers only (faster).
4. `tcpdump -i any port 80 -c 10`  
   Shows 10 packets live. Used when you must prove whether traffic arrives at all.
5. `ssh -L 8080:localhost:80 user@server`  
   Makes the server's port 80 appear as localhost:8080 on your machine.

### Interview Q&A

**1. A website does not open. What do you check, in order?**

- 1 Network: ping the IP (8.8.8.8) - do I have internet?
- 2 DNS: nslookup the name - does it give an IP?
- 3 Port: nc -zv host 443 - is the port open?
- 4 App: curl -I https://host - what HTTP code comes back?

**2. What happens when you type a URL in the browser?**

- Short answer: DNS finds the IP, TCP connects (3-way handshake), TLS sets up encryption for HTTPS, the browser sends an HTTP request, the server answers, the browser renders it.

**3. Explain the TCP 3-way handshake**

- Steps: SYN (client asks), SYN-ACK (server agrees), ACK (client confirms). Then data flows.

**4. What does /24 mean (192.168.1.0/24)?**

- Meaning: The first 24 bits are the network, the last 8 are hosts: 256 addresses (254 usable). /16 = 65,536, /32 = one address.

**5. TCP vs UDP?**

- TCP: Reliable, ordered, connection first. Web, SSH, databases.
- UDP: Fast, no guarantee. DNS lookups, video, games.

**6. Connection refused vs timed out?**

- Refused: The machine answered: nothing listens on that port (service down).
- Timed out: No answer at all: firewall or wrong route.

**7. Which process uses port 80?**

- Answer: ss -tlnp | grep :80 (or lsof -i :80).

---

## 4 · NGINX

Install and start NGINX, serve a page, then reverse proxy, load balance and debug a 502. Config files are ready-made, so you only copy, test and reload. Uses its own ports (8000-8083).

### Level 1 · Basic

```bash
apt-get update -qq                            # Setup: refresh the package list
apt-get install -y -qq nginx                  # Setup: install NGINX
nginx -v                                      # Which version?
cp /scripts/lab-files/site.conf /etc/nginx/conf.d/site.conf# Copy a small site config
mkdir -p /var/www/lab                         # Make the web folder
echo 'My first site' > /var/www/lab/index.html# Create a home page
nginx -t                                      # Test the config
nginx                                         # Start NGINX
curl localhost:8000                           # Open the page
curl -I localhost:8000                        # Look at the response header
ls /etc/nginx                                 # Where is the config?
ls /var/log/nginx                             # Where are the logs?
tail -2 /var/log/nginx/access.log             # Read the last request
```

What each one means:

1. `apt-get update -qq`  
   Refreshes the list of packages. Needs internet the first time. Skip it if NGINX is already installed.
2. `apt-get install -y -qq nginx`  
   On a real server: sudo apt install nginx. It installs the program, the config in /etc/nginx and the logs in /var/log/nginx.
3. `nginx -v`  
   Prints the version. -V (capital) also prints the build options and modules.
4. `cp /scripts/lab-files/site.conf /etc/nginx/conf.d/site.conf`  
   site.conf says: listen on port 8000 and serve the files in /var/www/lab. Read it with cat. Every file in conf.d/ is included automatically.
5. `mkdir -p /var/www/lab`  
   The 'web root': the folder NGINX serves files from.
6. `echo 'My first site' > /var/www/lab/index.html`  
   index.html is what NGINX shows for the path /.
7. `nginx -t`  
   ALWAYS run this before starting or reloading. It checks the syntax and does not touch the running server.
8. `nginx`  
   Starts the server in the background. On a real server you use systemctl start nginx (a container has no systemd). If you see 'Address already in use', NGINX is already running: use nginx -s reload.
9. `curl localhost:8000`  
   curl is the quickest way to test a web server from the terminal. Your page came from /var/www/lab.
10. `curl -I localhost:8000`  
   200 OK. Other codes: 301 redirect, 403 no permission, 404 file not found, 502 backend problem.
11. `ls /etc/nginx`  
   nginx.conf is the main file. conf.d/ holds extra files that are included automatically. sites-enabled/ holds site configs on Ubuntu.
12. `ls /var/log/nginx`  
   access.log = every request. error.log = problems. When something breaks, read error.log first.
13. `tail -2 /var/log/nginx/access.log`  
   Each line: client IP, time, request, status code, bytes, browser. Your curl commands are in there.

### Level 2 · Next level

```bash
echo 'Version 2' > /var/www/lab/index.html    # Change the page
curl localhost:8000                           # See the change
cp /scripts/lab-files/proxy.conf /etc/nginx/conf.d/lab.conf# Copy a reverse proxy config
nginx -t                                      # Test the config
nginx -s reload                               # Reload without downtime
curl localhost:9000                           # Call the backend directly
curl localhost:8080                           # Call it through the proxy
tail -3 /var/log/nginx/access.log             # See the requests in the log
```

What each one means:

1. `echo 'Version 2' > /var/www/lab/index.html`  
   Changing a FILE needs no reload. Only config changes do.
2. `curl localhost:8000`  
   NGINX reads the file on every request.
3. `cp /scripts/lab-files/proxy.conf /etc/nginx/conf.d/lab.conf`  
   proxy.conf has 2 servers: a 'backend' on port 9000 and a proxy on port 8080 that forwards to it. Read it with cat.
4. `nginx -t`  
   Syntax ok = safe to reload.
5. `nginx -s reload`  
   -s reload applies the new config and keeps existing connections alive. On a real server: systemctl reload nginx. Restart drops connections, reload does not.
6. `curl localhost:9000`  
   This is the application server (the 'upstream'). Normally users never reach it directly.
7. `curl localhost:8080`  
   Same answer, but NGINX forwarded the request with proxy_pass. A reverse proxy sits in front of apps and gives you TLS, caching, load balancing and one public entry point.
8. `tail -3 /var/log/nginx/access.log`  
   Every request through NGINX is logged. First place to look when users report errors.

### Level 3 · Medium

```bash
cp /scripts/lab-files/lb.conf /etc/nginx/conf.d/lb.conf# Copy a load balancer config
nginx -t                                      # Test the config
nginx -s reload                               # Reload
curl localhost:8081                           # Request 1
curl localhost:8081                           # Request 2
curl localhost:8081                           # Request 3
cp /scripts/lab-files/bad.conf /etc/nginx/conf.d/bad.conf# Copy a broken proxy config
nginx -s reload                               # Reload
curl -I localhost:8082                        # See the error code
tail -2 /var/log/nginx/error.log              # Find the reason in the error log
cp /scripts/lab-files/routes.conf /etc/nginx/conf.d/routes.conf# Copy a routing config
nginx -s reload                               # Reload
curl localhost:8083/health                    # Test the health route
curl localhost:8083/api/users                 # Test the api route
nginx -s stop                                 # Stop NGINX
```

What each one means:

1. `cp /scripts/lab-files/lb.conf /etc/nginx/conf.d/lb.conf`  
   lb.conf defines an upstream pool with 2 backends (ports 9001 and 9002) and a front server on port 8081.
2. `nginx -t`  
   Always test before reload.
3. `nginx -s reload`  
   Applies lb.conf.
4. `curl localhost:8081`  
   The answer says which backend served you.
5. `curl localhost:8081`  
   It should be the OTHER backend: the default method is round robin (take turns). Others: least_conn (fewest active connections), ip_hash (same client, same backend).
6. `curl localhost:8081`  
   Back to the first backend. If one backend dies, NGINX stops sending traffic to it.
7. `cp /scripts/lab-files/bad.conf /etc/nginx/conf.d/bad.conf`  
   bad.conf forwards to port 9999, where nothing is running. We create a 502 on purpose.
8. `nginx -s reload`  
   Applies bad.conf.
9. `curl -I localhost:8082`  
   502 = NGINX is fine but could not get a valid answer from the backend. 504 = the backend answered too slowly (timeout).
10. `tail -2 /var/log/nginx/error.log`  
   connect() failed (111: Connection refused) = nothing listens on that port. Fix the backend or the port number. Interview: '502, what do you check?' error.log first, then is the backend running.
11. `cp /scripts/lab-files/routes.conf /etc/nginx/conf.d/routes.conf`  
   routes.conf shows location blocks: a prefix /api/, an exact /health and a default /.
12. `nginx -s reload`  
   Applies routes.conf.
13. `curl localhost:8083/health`  
   location = /health is an EXACT match. Health checks use a route like this.
14. `curl localhost:8083/api/users`  
   location /api/ is a prefix match: anything that starts with /api/ lands here.
15. `nginx -s stop`  
   Fast shutdown. -s quit finishes current requests first.

### On a real server (TLS, limits) (copy only)

Needs a certificate and systemd. Copy-only.

```bash
systemctl reload nginx                        # Start, reload, restart as a service
listen 443 ssl; ssl_certificate /etc/ssl/site.crt; ssl_certificate_key /etc/ssl/site.key;# TLS termination (inside a server block)
return 301 https://$host$request_uri;         # Redirect http to https
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;# Rate limiting (http block)
proxy_set_header X-Real-IP $remote_addr;      # Pass the real client IP to the app
```

1. `systemctl reload nginx`  
   Use reload for config changes, restart only when needed.
2. `listen 443 ssl; ssl_certificate /etc/ssl/site.crt; ssl_certificate_key /etc/ssl/site.key;`  
   NGINX handles HTTPS and talks plain HTTP to the backend. Put these lines in the server block.
3. `return 301 https://$host$request_uri;`  
   Put this in a server block that listens on port 80.
4. `limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;`  
   Defines a zone: max 10 requests per second per client IP. Then limit_req zone=one; inside a location. Extra requests get 503.
5. `proxy_set_header X-Real-IP $remote_addr;`  
   Without it the backend only sees NGINX's address.

### Interview Q&A

**1. What is a reverse proxy?**

- Answer: A server in front of your apps. Clients talk to it, it forwards to the real servers. Gives TLS, caching, load balancing and one entry point.
- Forward proxy: Sits in front of CLIENTS (like a company proxy for outgoing traffic). Opposite direction.

**2. 502 vs 504?**

- 502 Bad Gateway: The backend is down, refused the connection or sent garbage. Check error.log and whether the backend runs.
- 504 Gateway Timeout: The backend is up but too slow. Check backend load or raise proxy_read_timeout.

**3. Reload vs restart?**

- Reload: Re-reads the config, workers finish old requests, no downtime.
- Restart: Stops everything and starts again: brief downtime.

**4. Name the load balancing methods**

- Default: Round robin (take turns).
- Others: least_conn, ip_hash (sticky by client), weights.

**5. How do you check a config change safely?**

- Answer: nginx -t, then nginx -s reload. Never reload without testing.

**6. Where do you look when a site is broken?**

- Logs: /var/log/nginx/error.log and access.log.
- Also: Is NGINX running? Is the port listening (ss -tln)? Does the backend answer (curl localhost:PORT)?

**7. What does location / vs location = /health mean?**

- Prefix: location /api/ matches everything that starts with /api/.
- Exact: location = /health matches only that one path.

---

## 5 · Docker (Week 2)

Images and containers first, then inspecting and debugging running containers, then your own image, volumes and networks. Runs in the toolbox terminal that talks to Docker Desktop.

### Level 1 · Basic

```bash
docker --version                              # Is Docker there?
docker pull alpine                            # Download an image
docker images                                 # List images
docker run --name lab-hi alpine echo hello    # Run a container
docker ps                                     # List running containers
docker ps -a                                  # List all containers
docker rm lab-hi                              # Remove it
docker run -d --name lab-web -p 8097:80 nginx:1.27-alpine# Run a web server in the background
docker ps                                     # Is it running?
docker logs lab-web                           # Read its logs
docker stop lab-web                           # Stop it
docker rm lab-web                             # Delete it
```

What each one means:

1. `docker --version`  
   Prints the client version. If later commands hang, the Docker engine (Docker Desktop) is not running.
2. `docker pull alpine`  
   An IMAGE is a read-only package: an app and its files. pull downloads it from Docker Hub. alpine is a tiny 5 MB Linux. No tag means :latest.
3. `docker images`  
   Shows repository, tag, id and size of every image on this machine.
4. `docker run --name lab-hi alpine echo hello`  
   A CONTAINER is a running copy of an image. run = create + start. The container ran echo, then ended because its command finished.
5. `docker ps`  
   Only RUNNING containers. lab-hi is not listed because it already exited.
6. `docker ps -a`  
   -a includes stopped containers. Status 'Exited (0)' = finished normally. Interview: 'container exits immediately, why?' Its main command finished or crashed: look at the exit code and docker logs.
7. `docker rm lab-hi`  
   Deletes a stopped container. The image stays.
8. `docker run -d --name lab-web -p 8097:80 nginx:1.27-alpine`  
   -d = detached (background). --name gives it a name. -p 8097:80 = host port 8097 to container port 80. Prints the container id.
9. `docker ps`  
   Now you see it with its ports and status 'Up'.
10. `docker logs lab-web`  
   logs shows what the container printed on stdout and stderr. -f follows live, --tail 20 shows the last 20 lines. First step when a container misbehaves.
11. `docker stop lab-web`  
   Sends SIGTERM (polite), waits 10 seconds, then SIGKILL. docker start lab-web brings the same container back.
12. `docker rm lab-web`  
   Removes the stopped container. docker rm -f does stop and remove in one go.

### Level 2 · Next level

```bash
docker run -d --name lab-web -p 8097:80 nginx:1.27-alpine# Start a web server again
docker exec lab-web nginx -v                  # Run one command inside it
docker exec lab-web ls /etc/nginx             # Look around inside
docker logs --tail 3 lab-web                  # Last log lines
docker inspect lab-web --format '{{.State.Status}}'# Ask for one fact
docker port lab-web                           # Check the port mapping
docker stats --no-stream                      # CPU and memory
docker top lab-web                            # Processes inside
docker restart lab-web                        # Restart it
docker rm -f lab-web                          # Stop and remove in one go
```

What each one means:

1. `docker run -d --name lab-web -p 8097:80 nginx:1.27-alpine`  
   Same command as before. This level inspects a running container.
2. `docker exec lab-web nginx -v`  
   exec runs a command inside a RUNNING container. For a shell use docker exec -it lab-web sh (-i keep input open, -t terminal). Type exit to leave.
3. `docker exec lab-web ls /etc/nginx`  
   The container has its own file system, taken from the image.
4. `docker logs --tail 3 lab-web`  
   --tail N limits the output. Use it on chatty containers.
5. `docker inspect lab-web --format '{{.State.Status}}'`  
   inspect prints all the details as JSON: ip, mounts, env, restart policy. --format picks one field.
6. `docker port lab-web`  
   Shows which host port maps to which container port.
7. `docker stats --no-stream`  
   Live usage per container. --no-stream prints once.
8. `docker top lab-web`  
   Like ps for one container.
9. `docker restart lab-web`  
   stop + start. Used after changing something the container reads only at startup.
10. `docker rm -f lab-web`  
   -f forces removal of a running container.

### Level 3 · Medium

```bash
cat Dockerfile                                # Read the sample Dockerfile
docker build -t lab-hello .                   # Build your image
docker run --rm lab-hello                     # Run your image
docker build -t lab-hello .                   # Build again
docker history lab-hello                      # See the layers
docker volume create lab-vol                  # Create a volume
docker run --rm -v lab-vol:/data alpine touch /data/f.txt# Write a file into the volume
docker run --rm -v lab-vol:/data alpine ls /data# Read it from a NEW container
docker network create lab-net                 # Create a network
docker run -d --name lab-web --network lab-net nginx:1.27-alpine# Start a web container on it
docker run --rm --network lab-net alpine ping -c 1 lab-web# Reach it by name from another container
docker rm -f lab-web                          # Clean up the container
docker rmi lab-hello                          # Clean up the image
docker volume rm lab-vol                      # Clean up the volume and network
docker network rm lab-net                     # Remove the network
```

What each one means:

1. `cat Dockerfile`  
   FROM = base image. RUN = a command executed while BUILDING (saved as a layer). CMD = the default command when a container STARTS. Mixing up RUN and CMD is the most common beginner mistake.
2. `docker build -t lab-hello .`  
   build reads the Dockerfile in the folder (the dot = build context). -t names the image.
3. `docker run --rm lab-hello`  
   --rm deletes the container when it exits, so nothing piles up.
4. `docker build -t lab-hello .`  
   Nothing changed, so every layer comes from the cache. If you change one line, that layer and all layers AFTER it rebuild: put rarely changing steps first.
5. `docker history lab-hello`  
   Every Dockerfile instruction is one layer. Smaller and fewer layers = smaller image.
6. `docker volume create lab-vol`  
   A volume keeps data OUTSIDE the container, so it survives container deletion. Files written inside a container are lost when it is removed.
7. `docker run --rm -v lab-vol:/data alpine touch /data/f.txt`  
   -v lab-vol:/data mounts the volume at /data. The container is deleted afterwards.
8. `docker run --rm -v lab-vol:/data alpine ls /data`  
   The file is still there: that is persistence. Databases must always use a volume.
9. `docker network create lab-net`  
   A user-defined network gives containers DNS: they can reach each other by NAME.
10. `docker run -d --name lab-web --network lab-net nginx:1.27-alpine`  
   No -p needed: other containers on the same network reach it directly.
11. `docker run --rm --network lab-net alpine ping -c 1 lab-web`  
   The name lab-web resolved by itself. This is how Compose services find each other (api talks to db by name).
12. `docker rm -f lab-web`  
   Remove the running container.
13. `docker rmi lab-hello`  
   rmi removes an image. docker system prune removes all unused things (ask first!).
14. `docker volume rm lab-vol`  
   Volumes are never deleted automatically.
15. `docker network rm lab-net`  
   Everything created by this topic is now gone.

### Interactive and more (copy only)

These need a live terminal session. Copy and run them in the terminal on the right.

```bash
docker exec -it lab-web sh                    # Open a shell inside a container
docker run -it --rm alpine sh                 # Run a throwaway container with a shell
docker system prune                           # Free disk space
docker system df                              # See disk used by Docker
```

1. `docker exec -it lab-web sh`  
   -it = interactive terminal. Type exit to leave. The container keeps running.
2. `docker run -it --rm alpine sh`  
   --rm deletes it on exit. Perfect for trying commands safely.
3. `docker system prune`  
   Removes stopped containers, unused networks and dangling images. It asks first.
4. `docker system df`  
   Images, containers, volumes and build cache, and how much can be reclaimed.

### Interview Q&A

**1. Image vs container?**

- Image: Read-only package: app + files. Built once.
- Container: A running (or stopped) instance of an image. You can start many from one image.

**2. A container exits immediately. Why?**

- Reason: Its main process (PID 1) ended or crashed. A web server stays up because it never ends.
- Check: docker ps -a (exit code), then docker logs NAME.

**3. CMD vs ENTRYPOINT?**

- ENTRYPOINT: The fixed program.
- CMD: The default arguments. docker run IMAGE args replaces CMD, not ENTRYPOINT.

**4. COPY vs ADD?**

- Rule: Use COPY. ADD can also download URLs and unpack archives, which surprises people.

**5. Volume vs bind mount?**

- Volume: Managed by Docker, best for databases and persistent data.
- Bind mount: A host folder mapped into the container, good for source code in development.

**6. EXPOSE vs -p?**

- EXPOSE: Documentation only: the image uses this port.
- -p 8080:80: Actually publishes the port on the host.

**7. How do you make an image smaller?**

- Ideas: Small base (alpine), multi-stage builds, fewer layers, .dockerignore, no build tools in the final image.

**8. How do two containers talk to each other?**

- Answer: Put them on the same user-defined network and use the container name as the host name (Docker's built-in DNS).
