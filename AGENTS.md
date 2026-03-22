# AGENTS.md

## Project Overview
* StratoCyberLab is a local cyber range built around Docker Compose.
* The root stack starts `hackerlab`, `dashboard`, and optional `ollama`.
* Most repository content lives in:
  * `dashboard/client` - Svelte frontend
  * `dashboard/server` - Python backend and websocket SSH server
  * `challenges/` - individual CTF-style challenges
  * `classes/` - class/lab environments
  * `campaigns/` - grouped challenge content

## Working Rules
* Keep changes narrow and consistent with existing patterns.
* When editing a challenge, preserve the expected files: `meta.json`, `docker-compose.yml`, `README.md`, and `auto-solve.sh`.
* When adding services to challenges or classes, use the shared `playground-net` network and avoid reusing static IPs already documented in `docs/development.md`.

## Validation
* Full-project verification is `./run_tests.sh` but do not run it as it takes a lot of time and cannot be executed in a sandbox
* Frontend work in `dashboard/client`:
  * `npm ci`
  * `npm run build`
  * `npx eslint src`
* Backend work in `dashboard/server`:
  * `pip install -r requirements.txt -r requirements-dev.txt`
  * `pylint .`
  * `python app.py`
