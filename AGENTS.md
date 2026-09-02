# StratoCyberLab Agent Guide

## Purpose

StratoCyberLab is a free, local cyber range for practicing offensive and defensive security. It supports the CTU Introduction to Security course, but must remain usable by anyone with only Docker. The project intentionally favors local, reproducible, hands-on teaching environments over production deployment in cloud.

## Architecture

- The root `docker-compose.yml` creates the `playground-net` bridge and starts:
  - `hackerlab`: the user's root-capable attack workstation, exposed to localhost over SSH and WebSSH.
  - `dashboard`: a Svelte client plus Python HTTP/WebSocket servers. It discovers content (challenges, campaigns, classes, plugins, ...), tracks state in SQLite, and starts or stops Docker Compose projects.
  - `ollama`: the optional local LLM service, reachable only inside the Docker network.
- `challenges/` contains standalone CTF exercises.
- `classes/` contains weekly teaching environments.
- `campaigns/` combines challenges and instructional pages into ordered stories consisting of small challenges.
- `plugins/` contains optional third-party Compose applications. The dashboard may proxy their UI.
- The dashboard bind-mounts the content directories and `/var/run/docker.sock`; Docker socket access is effectively root access to the host.

## Threat Model and Security Boundaries

StratoCyberLab is a local, single-user application. Its lack of authentication is acceptable only because host-facing ports bind to `127.0.0.1`. Never expose the dashboard, WebSSH, SSH, Ollama, plugins, or exercise services publicly or change a loopback bind to all interfaces without an explicit security redesign.

Treat the dashboard, Ollama integration, base stack, and host boundary as security-critical:

- Treat data crossing from challenges, classes, plugins, or models into the dashboard control plane as untrusted input, even when the component was intentionally installed. Running a third-party plugin is an explicit trust decision; plugins with Docker socket access are effectively trusted with the host.
- Harden control-plane code against command, path, URL, template, prompt, and container-configuration injection. Do not pass untrusted values to a shell.
- Do not give workloads or models access to host files, credentials, tools, privileged containers, or the Docker socket.
- Treat third-party plugins as untrusted code. Review their source and Compose configuration before running them. A plugin mounting the Docker socket can take over the host and must carry a prominent warning.
- Preserve localhost bindings and minimize host-published ports, bind mounts, Linux capabilities, and cross-network access.

Challenges, classes, campaigns, and their containers are different: they may be deliberately vulnerable, use weak credentials, contain readable flags, or generate malicious-looking traffic as part of a lesson. Do not “fix,” upgrade away, or report these properties as ordinary defects unless they escape their intended container/network boundary. Preserve the intended learning objective and solve path. Improve containment rather than removing an intentional vulnerability.

Never execute challenge payloads, malware-like samples, or `auto-solve.sh` scripts directly on the host. Run educational workloads only through their intended containers in an isolated local environment.

## Contributing

- Keep changes narrow, follow neighboring patterns, and read the nearest README before editing.
- Preserve public behavior, educational intent, flags, task order, difficulty, and documented solutions unless the task explicitly changes them.
- A challenge must retain `meta.json`, `docker-compose.yml`, `README.md`, and `auto-solve.sh`. Update all four when behavior changes, and make the auto-solver exercise every task and submit every flag.
- Class and campaign metadata drive the dashboard; keep IDs unique and references consistent.
- Attach exercise services to the external `playground-net` only when required. Before assigning a static IP, check all Compose files as well as `docs/development.md`; update the allocation table and avoid collisions.
- Do not add host port exposure, the Docker socket, privileged mode, host mounts, or extra capabilities to educational workloads unless essential to the lesson and clearly documented.
- Plugins must follow `docs/plugins.md`, including required metadata/files and the `scl-plugin-<id>-<name>` container prefix.
- Never commit local environment files, generated state, databases, downloaded models, or credentials unrelated to an intentional exercise.
- Update all necessary places related to every change
   - E.g.: when creating new challenges, update tests and static IP allocation in docs
- We teach adversarial and defensive mindset. Be creative when creating educational content unless stated otherwise
- If a big architectural decision is required to finish a task, ask the core questions before implementation with short description of the best proposed solution  

## Backward Compatibility

- All required code to run SCL is in this project
- When making a bigger change, make sure to update all existing related code (challenges, classes, ...)
- Only plugins are 3rd party code not present in this project. That's why maintain backward compatibility of plugins unless explicitly stated otherwise

## Validation

Use the smallest relevant checks. Do not run `./run_tests.sh`: it is slow and launches the entire vulnerable range.

- Frontend (`dashboard/client`): `npm ci`, `npm run build`, `npx eslint src`
- Backend (`dashboard/server`): install `requirements.txt` and `requirements-dev.txt`, then run `pylint .`; use `python app.py` only when a live local server check is needed.
- Challenge or campaign changes: validate JSON and Compose configuration, build only affected services, and test the documented solve path inside `hackerlab`.
- Class changes: validate metadata and Compose configuration and start only the affected environment.

Do not weaken containment merely to make a test pass.

## Documentation

- When implementing a new standalone feature, add its human-readable documentation to ./docs dir.
- Read existing documentation and follow the style and verbosity
- Use easy to understand technical English.
- Read the respective documentation file before working on the given feature

