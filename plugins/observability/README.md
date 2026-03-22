# Observability Plugin

This reference plugin exposes a tiny control plane that shows currently running Docker containers whose names start with `scl-`.

## Files

- `metadata.json` describes the plugin for the dashboard
- `docker-compose.yml` starts the plugin control plane
- `Dockerfile` builds the plugin container
- `app.py` serves the plugin UI and the `actions.json` endpoint

## Behavior

- The service mounts `/var/run/docker.sock`
- The UI calls `actions.json` through the dashboard proxy when you press `Refresh`
- The server handles `SIGINT` and shuts down cleanly

## Naming

The plugin container is named `scl-plugin-observability-control-plane` to follow the required `scl-plugin-<id>-<name>` prefix convention.
