# claude-setup repo rules

The root `CLAUDE.md` in this repo is the user's GLOBAL instructions file (`~/.claude/CLAUDE.md` links to it). Rules that apply only to this repo go here, in `.claude/CLAUDE.md`.

## Everything is a symlink back to this repo

- Every config file, memory file, skill, agent and script managed here lives in this repo. Its expected location (`~/.claude/...`, `~/memories/...`, `~/code/claude-scripts/...`) holds only a symlink to it.
- Never leave a plain file or a copied folder at the expected location. Edits to a copy never reach git, and the copy silently drifts from the repo.
- When adding something new: create it in the repo, symlink it (`ln -s` for files, `ln -sfn` for folders), and add it to the Symlink Map and setup commands in `README.md`. All in the same commit.
- Before overwriting a plain file with a symlink, diff it against the repo copy and merge anything only the plain file has.
- To check for drift: `find ~/.claude/skills ~/.claude/agents ~/memories -maxdepth 1 ! -type l` should list only folders and files that are not managed here.

## This repo is public

Do not commit secrets, hostnames, IP addresses, usernames on servers, or notes about machine security (like passwordless sudo). Keep those in local-only files: they still live in this repo and are symlinked like everything else, but are listed in `.gitignore` (for example `memories/system-notes.md`).
