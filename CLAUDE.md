# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal DevOps learning repo. It holds study notes and hands-on experiments, not a deployable application, so there is no build, lint, or test setup at the repo level. If an experiment folder brings its own tooling (Dockerfile, Terraform, CI config, scripts), look for commands inside that folder.

## Notes: Obsidian vault + Notion sync

- The repo root is an **Obsidian vault**. Notes are Markdown files.
  - Link between notes with Obsidian `[[wikilinks]]` (e.g. `[[Docker Networking]]`), not relative Markdown links. Obsidian resolves a link by note filename, so renaming a note breaks links to it unless they are updated too.
  - Do not edit or commit anything under `.obsidian/` (Obsidian app/workspace config) unless the user asks.
- Notes are **mirrored to Notion** through the Notion MCP server for access from anywhere.
  - The local Markdown files are the source of truth. When a note changes, update it here first, then push it to Notion.
  - Only write to Notion when the user asks. Before creating a new Notion page, check whether one already exists for that note so it isn't duplicated.
  - If no Notion MCP tools are available in the session, tell the user the server isn't connected instead of skipping the sync silently.
