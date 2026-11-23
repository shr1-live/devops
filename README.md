# DevOps Learning

A personal workspace for learning DevOps: notes, hands-on experiments, and reference material collected along the way.

Study order and weekly milestones: see [00_Learning_Plan.md](00_Learning_Plan.md).

## How notes are kept

- **Obsidian (local):** this repository is used as an Obsidian vault. Notes are plain Markdown files and link to each other with `[[wikilinks]]`, so you can browse them in Obsidian or any text editor.
- **Notion (cloud):** notes are also synced to Notion through the Notion MCP server, so they can be read from any device.

The Markdown files in this repo are the source of truth. Notion holds a copy for access from anywhere.

## Getting started

1. Clone the repository.
2. In Obsidian, choose **Open folder as vault** and select the repository folder.
3. To sync notes to Notion, connect the Notion MCP server in Claude Code, then ask Claude to push or update specific notes.

## Ubuntu practice environment (Docker)

The repo includes a [Dockerfile](Dockerfile) and [compose.yaml](compose.yaml) that run an Ubuntu 24.04 container for safe hands-on practice.

- You log in as user `dev`, who can use `sudo` without a password.
- The repo is mounted at `~/devops` inside the container, so edits show up on both sides.
- The home folder (`/home/dev`) is kept in a Docker volume, so shell history and files you create there survive restarts.

Run these commands from the repo folder:

| Command | What it does |
| --- | --- |
| `docker compose up -d` | Start the container in the background |
| `docker compose up -d --build` | Rebuild the image and start (run this after editing the Dockerfile) |
| `docker compose exec ubuntu bash` | Open a shell inside the container |
| `docker compose exec -u root ubuntu bash` | Open a root shell |
| `docker compose ps` | Check whether the container is running |
| `docker compose logs` | Show the container's output |
| `docker compose stop` | Stop the container (your files are kept) |
| `docker compose down` | Remove the container (the home volume is kept) |
| `docker compose down -v` | Remove the container **and** the home volume, for a fresh start |

Type `exit` or press `Ctrl+D` to leave the container shell. The container keeps running until you stop it.

If you break something while practising, `docker compose down -v` followed by `docker compose up -d` gives you a clean machine again. Your repo files are not affected because they live on the host.

To keep the image small, Ubuntu leaves out most manual pages. If `man <command>` shows nothing, run `sudo unminimize` once inside the container to restore them (this takes a few minutes).
