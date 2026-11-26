# 1-Month DevOps Learning Plan

Reference plan (KodeKloud track). Each week ends with a hands-on milestone lab. Notes for finished topics live in the numbered folders of this repo.

| Week | Tools | Main KodeKloud courses and labs | Time | Weekly deliverable |
| ---- | ----- | ------------------------------- | ---- | ------------------ |
| 1 (Days 1-7) | Linux (Ubuntu), Bash, Networking, NGINX | DevOps Pre-Requisite (Linux/Networking), Shell Scripts for Beginners, Advanced Bash, Demystifying DNS, Linux Playground | 10-12 hrs | Hardened Linux VM running NGINX with TLS proxying a backend API, plus an automated maintenance Bash script |
| 2 (Days 8-14) | Docker, Docker Compose | Docker for the Absolute Beginner (fast-tracked), DCA labs | 10-12 hrs | Production-grade multi-tier stack behind an NGINX proxy via Compose |
| 3 (Days 15-21) | GitHub Actions / Azure DevOps, AWS or Azure, Terraform | CI/CD labs, AWS Cloud Practitioner or AZ-104, Terraform Basics, Cloud Playgrounds | 10-12 hrs | Terraform-provisioned cloud infra plus a CI/CD pipeline that pushes containers via OIDC |
| 4 (Days 22-30) | Kubernetes, Helm | Kubernetes for Beginners, CKAD/CKA labs, Helm for Beginners | 12-14 hrs | Helm-packaged app deployed to Kubernetes through CI/CD |

## Week 1: Linux, Bash, Networking, NGINX

KodeKloud: Linux Basics and Networking Basics labs (skip basic Git/YAML), Shell Scripts for Beginners and Advanced Bash (flow control, exit codes, functions, `set -euo pipefail`, awk, sed, redirection), Linux Playground (NGINX reverse proxy, upstream load balancing, TLS termination, systemd).

Topics and where my notes are:

- [x] Shell basics: [[01_Intro_to_shell]], [[02_Basic_linux_commands]], [[03_Paths]], [[04_Shell]]
- [ ] Filesystem hierarchy, users, permissions, sudoers: [[05_Filesystem_and_permissions]] (notes written, practice pending)
- [x] SSH user + restricting my folders from other users (chmod, umask, ACL, setgid, sshd `Match`, SFTP chroot): [[06_SSH_user_and_folder_restriction]]
- [ ] Processes, systemd, `systemctl`, `journalctl`, `apt`, resource tools (`htop`, `vmstat`, `iostat`, `df`), SSH hardening
- [ ] Bash scripting: defensive scripts, exit codes, pipes/redirection, grep/awk/sed/jq, cron
- [ ] Networking: TCP/IP, DNS (`dig`, `nslookup`), HTTP/TLS, CIDR, `ufw`/`iptables`, `curl -v`, `ss`, `traceroute`, `tcpdump`
- [ ] NGINX: reverse proxy, load balancing, TLS termination, location routing, rate limiting, 502/504 debugging

**Milestone lab:** in the Ubuntu playground, do baseline SSH hardening, run a sample backend under systemd, put NGINX in front as a TLS-terminating reverse proxy, and write an idempotent Bash script for health checks and log rotation.

## Week 2: Containers and local multi-service stacks

- Docker: image layers and cache, multi-stage builds, Alpine/Distroless, non-root user, `.dockerignore`, bridge/host networking, volumes.
- Compose: `docker-compose.yml`, internal DNS, `depends_on` with `condition: service_healthy`, environment variable precedence.

Daily progress:

- [ ] Day 8 (W2 D1): Docker fundamentals: images, containers, run/exec/logs, layers, first Dockerfile: [[01_Docker_fundamentals]] (notes + lab topic 5 written, run the lab to tick)
- [ ] Day 9: Dockerfile layer caching, `.dockerignore`, build context size
- [ ] Day 10: multi-stage builds, slim/distroless bases, non-root user
- [ ] Day 11: networking (bridge/host/internal) and volumes vs bind mounts
- [ ] Day 12: Docker Compose, service discovery, `service_healthy`, env precedence
- [ ] Day 13: image scanning (Trivy), storage drivers, container security
- [ ] Day 14: milestone: multi-tier stack behind NGINX

**Milestone lab:** containerize frontend + API + relational DB + Redis with multi-stage Dockerfiles, run behind NGINX with Compose, health checks and persistent volumes.

## Week 3: CI/CD, cloud, Terraform

- GitHub Actions / Azure DevOps: workflow syntax, matrix builds, OIDC keyless auth, secrets, build/push, vulnerability scanning.
- AWS/Azure: IAM least privilege, VPC/VNet, public/private subnets, NAT, security groups, compute, storage, monitoring.
- Terraform: HCL, state and remote backend locking, variables, reusable modules, plan/apply in CI.

Daily progress (lab topics 6, 7 and 8, all in `Interview_Commands.md`):

- [ ] Day 15: Git basics: init, add, commit, status, log (topic 6, Level 1)
- [ ] Day 16: branches, merge, `.gitignore`, tags (topic 6, Levels 2 and 3)
- [ ] Day 17: GitHub Actions: read and write a workflow, secrets, matrix, OIDC (topic 6, Q&A and copy-only tab)
- [ ] Day 18: Terraform basics: init, plan, apply, state (topic 7, Level 1)
- [ ] Day 19: variables, modules, `for_each`, remote state with locking (topic 7, Levels 2 and 3)
- [ ] Day 20: AWS / Azure: IAM, VPC, subnets, security groups (topic 8, on a KodeKloud playground)
- [ ] Day 21: milestone: Terraform-provisioned infra plus a pipeline that pushes an image via OIDC

**Milestone lab:** modular Terraform with remote state for VPC/VNet, IAM roles and a container registry, plus a pipeline that tests, builds, scans and pushes the image via OIDC.

## Week 4: Kubernetes and Helm

- Kubernetes: control plane vs nodes, Deployments/StatefulSets/DaemonSets/Jobs, ConfigMaps/Secrets, Services/Ingress, NetworkPolicies, PV/PVC, HPA, probes, debugging (`CrashLoopBackOff`, `ImagePullBackOff`).
- Helm: chart structure, Go templating, `values-dev.yaml`/`values-prod.yaml`, install/upgrade/rollback, ingress-nginx, cert-manager.

**Capstone:** deploy the multi-service app to a multi-node cluster (or EKS/AKS sandbox) with a custom Helm chart, Ingress, HPA, and automated CI/CD deployment.
