# SSH Lab UI

One page with five practice topics (Linux, Bash scripting, Networking, NGINX, Docker), each in three levels (basic, next level, medium) plus interview Q&A, defined in `lab-topics.js`: steps with a plain-English note under each command, **Run** / **Copy** buttons, and a live terminal next to them. Static files only (HTML + xterm.js), no build step.

## Run it (full version, with the terminal)

The terminal is a Docker container on your own PC. In `D:\Devops`, double-click `ssh-lab.cmd`, or:

```powershell
docker compose up -d --build sshlab dashboard
```

Then open http://localhost:7000/ssh-lab.html (the header shows a build time so you can tell the page is fresh) and press **Run** on any step.

## Deploy the page on Vercel

1. Push this folder to GitHub (it is `ssh-lab-ui/` in `shr1-live/devops`).
2. Vercel → **Add New → Project** → import the repo.
3. **Root Directory:** `ssh-lab-ui`. **Framework Preset:** Other. Leave build and output settings empty.
4. **Deploy.**

## What works where

| | Vercel link (anyone) | Your PC with the lab running |
|---|---|---|
| Steps, explanations, Copy buttons, progress ticks | yes | yes |
| ▶ Run + live terminal | no | yes (Chrome / Edge) |

Vercel only hosts the page. It cannot host the terminal (that needs a running container), and a public terminal would be a public shell, so the page always connects to `ws://localhost:7683` on the visitor's own PC. If nothing is listening there, it shows a "start the lab" message and the Copy buttons still work.

## Files

- `index.html` the whole UI (same file as `dashboard/ssh-lab.html` in `D:\Devops`)
- `vendor/` xterm.js 5.3.0 and its fit addon, stored locally so there is no CDN dependency
- Backend: `sshlab/Dockerfile` + the `sshlab` service in `compose.yaml` (Ubuntu 24.04 + ttyd on 127.0.0.1:7683)
