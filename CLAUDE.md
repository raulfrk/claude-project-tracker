# Project Skill Improvement

**Type**: learning
**Created**: 2026-02-19

## Description

Claude Code skill improvement project — plugin at github.com/raulfrk/claude-project-tracker

## Overview

A learning project to iteratively improve the `/project` Claude Code skill — adding features, fixing UX issues, and refining how project tracking files and Todoist are managed. The skill is packaged as an installable Claude Code plugin hosted on GitHub.

## Key Decisions

- Use `permissions.allow` in `~/.claude/settings.json` to auto-approve edits to project files (`allowedTools` is incorrect and does not work).
- Absolute paths in `allowedTools` require double-slash prefix (`//home/raul/...`); single slash is relative to the settings file location.
- Also allow `Edit` and `Write` on `~/.claude/settings.json` itself so the skill can update allowed tools without prompting.
- MCP tool permissions use the format `mcp__<server-name>__<tool-name>` in `permissions.allow`.
- Bash permissions for directory-scoped execution use `Bash(python //home/raul/projects/**)` style patterns.
- Plugin `marketplace.json` `source` for GitHub must be `{"source": "url", "url": "https://github.com/raulfrk/claude-project-tracker.git"}` — `"./"` doesn't re-fetch on update; `{"source": "github", ...}` uses SSH (no key configured).
- `gh auth setup-git` configures git to use the gh token as HTTPS credential helper (no password prompts).
- `gh repo create <name> --public --source=. --remote=origin --push` creates and pushes in one command; if SSH key missing, switch remote to HTTPS first.
- Per-path mode is additive: project-level `mode` is the default; per-path `mode` overrides only when it differs. On write, omit per-path `mode` when equal to project-level (keeps YAML clean).
- Always bump the plugin version in `.claude-plugin/marketplace.json` (and `plugin.json`) before pushing — `claude plugin update` checks versions and won't update if unchanged.
- CLAUDE.md split: public `CLAUDE.md` (no local paths, safe to commit) + private `CLAUDE.local.md` (gitignored, tracking dir + session data); ensure-gitignore adds `*.local.md` to `.gitignore` in git repos automatically.
- Three assistance modes: `standard` (no learning), `learning` (Claude implements + explains + quizzes; mastery tracked; user observes), `active-learning` (pair programming; Claude scaffolds; user implements; Claude reviews).
- `/project load` requires two Bash permissions: `Bash(test -d //home/raul/**)` for content path existence checks and `Bash(git -C //home/raul/**)` for ensure-gitignore's `git rev-parse --show-toplevel`. Scope to `//home/raul/**` to cover content paths anywhere in home.

## Project Structure

- `.claude-plugin/marketplace.json` — marketplace catalog listing all plugins
- `plugins/project-tracker/` — project management plugin (skills, hooks, plugin.json)

## Development Notes

- GitHub repo: https://github.com/raulfrk/claude-project-tracker
- Plugin installed as `project-tracker@claude-project-tracker` (v1.0.5)
- See full session log in `~/projects/tracking/project-skill-improvement/NOTES.md`
