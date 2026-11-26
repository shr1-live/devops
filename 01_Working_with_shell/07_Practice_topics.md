# Practice topics (runnable in the lab page)

Open `ssh-lab-ui/index.html` (or http://localhost:7000/ssh-lab.html) with the lab running. Each topic has a Practice tab (steps that run one by one, each with a short note), a "What the commands mean" tab, and some have a KodeKloud tab for commands that need real systemd, Docker or a cluster.

| # | Topic | Covers |
|---|---|---|
| 1 | Linux (Ubuntu) | filesystem layout, users, chmod/chown, sudoers, processes, apt, df/free/vmstat/iostat, sshd settings |
| 2 | Bash scripting | `set -euo pipefail`, exit codes, redirection, grep/awk/sed/jq, cron |
| 3 | Networking | ip/ss/nc, curl -v, ping/traceroute/tcpdump, dig, TLS, CIDR |
| 4 | NGINX | reverse proxy, load balancing, TLS, rate limiting, 502/504 debugging |
| 5 | Interview must-knows | log analysis, find/xargs/tar, links and inodes, signals, lsof/fuser, git, plus 16 short Q&A |
| 6 | Docker basics (Week 2, Day 1) | images vs containers, run/ps/exec/logs/inspect, ports, layers, first Dockerfile and build cache. Runs in the **toolbox** terminal (port 7682), notes in `02_Docker/01_Docker_fundamentals.md` |

The Week 1 milestone script is in `labs/week1-milestone/week1-milestone.sh` (`sudo bash week1-milestone.sh all`, then `verify`).
