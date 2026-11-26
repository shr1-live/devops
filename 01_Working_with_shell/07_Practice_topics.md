# Practice topics (runnable in the lab page)

Open `ssh-lab-ui/index.html` (or http://localhost:7000/ssh-lab.html) with the lab running. Each topic has three levels, easiest first, plus interview questions:

- **Level 1 Basic**: the commands you must know without thinking.
- **Level 2 Next level**: searching, permissions, processes, ports.
- **Level 3 Medium**: the next step up, built one piece at a time.
- **Interview Q&A**: the question as it is asked and a short answer.
- **On a real server** (copy only): things that need systemd, cron, a firewall or TLS.

Every step is one short command with a plain-English note under it. A step turns green only when its output is correct. All commands are also listed in [[../Interview_Commands]].

| # | Topic | Level 1 | Level 2 | Level 3 | Terminal |
|---|---|---|---|---|---|
| 1 | Linux | pwd, ls, cd, mkdir, touch, cat, cp, mv, rm | head, tail, grep, find, chmod, df, du, free, ps, kill | useradd, usermod, ln, tar, PATH, env, dpkg, uptime | Ubuntu box (7683) |
| 2 | Bash scripting | run a script, chmod +x, arguments, `$?`, variables | if, for, exit codes, cut, grep -c, grep -v | sort / uniq -c, awk, sed, `set -euo pipefail`, functions | Ubuntu box (7683) |
| 3 | Networking | ip addr, ip route, /etc/hosts, resolv.conf, ping | nslookup, dig, ss, nc, listeners | ip link, ss -s, ss -tlnp, traceroute; optional internet tab | Ubuntu box (7683) |
| 4 | NGINX | install, config, start, serve a page, logs | edit page, reverse proxy, reload | load balancing, 502 debugging, location routes | Ubuntu box (7683) |
| 5 | Docker (Week 2) | pull, run, ps, logs, stop, rm | exec, inspect, stats, port, restart | Dockerfile, build cache, volumes, networks, DNS by name | Toolbox (7682) |
| 6 | Git and CI/CD (Week 3) | git init, add, commit, status, log | branch, diff, merge, delete branch | .gitignore, read a GitHub Actions workflow with yq, tags | Toolbox (7682) |
| 7 | Terraform (Week 3) | init, validate, plan, apply, output, state list | variables, fmt, state file, destroy | modules, for_each, resource addresses | Toolbox (7682) |
| 8 | Cloud AWS / Azure (Week 3) | who am I, S3, EC2, resource groups (copy only) | IAM, VPC, subnets, security groups (copy only) | ECR, logs, assume role, OIDC (copy only) | Copy only |

The sample files the steps copy (`access.log`, small scripts, NGINX configs) are in `labs/lab-files`, the Docker example is in `../02_Docker/lab-docker`, and the workflow and Terraform examples are in `../03_CICD_Terraform`. The topics themselves are defined in `ssh-lab-ui/lab-topics.js`.

The Week 1 milestone script is in `labs/week1-milestone/week1-milestone.sh` (`sudo bash week1-milestone.sh all`, then `verify`).
