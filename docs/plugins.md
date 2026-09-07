# Plugins

StratoCyberLab can load third-party plugins from the top-level [`./plugins`](./../plugins/) directory.

**Important Note: Plugins might have mounted docker socket which gives them theoretical root access to your host machine. Use only third party plugins that you fully trust!!!**

## Structure

Each plugin lives in its own directory and must contain:

- `./plugins/<id>/metadata.json`
- `./plugins/<id>/docker-compose.yml`
- `./plugins/<id>/README.md`
- any additional source files needed by the plugin

### Metadata

Every plugin must provide a `metadata.json` file with this structure:

```json
{
  "id": "<id>",
  "name": "<human readable name>",
  "description": "<description what the plugin does>",
  "version": "<version of the plugin shown in the SCL dashboard>",
  "ui_url": "http://<control_plane_hostname>:<port>"
}
```

Required fields:

- `id`
- `name`
- `description`
- `version`

Optional fields:

- `ui_url`

The dashboard validates plugin metadata at startup. Invalid plugins are still shown in the UI together with validation errors, but they cannot be started.

### Plugin's UI

* Plugins can optionally expose HTTP UI which is rendered in SCL dashboard via iframe.
* If a plugin exposes a UI, it must define the HTTP URL of the UI in `ui_url` metadata field.
    - Use hostname of the service serving the UI, example: `http://scl-plugin-observability-control-plane:9001/`
* Since ports of the plugins' containers are not published to the host machine, all traffic between dashboard <> plugins is proxied through the dashboard server. That's why the containers serving the plugin's UI must be attached to docker network `playground-net` so dashboard can reach it.

Proxy explanation:

- Dashboard iframe loads the plugin document at path `src="/plugins/<plugin_id>/"`
- Dashboard server proxies traffic:
    - Request to dashboard server `/plugins/<plugin_id>/<path>` is proxied to `<ui_url of plugin_id>/<path>` 
- This means plugin's UI should use relative paths to fetch assets. Example:
    - OK -> `fetch("users.json")` resolves to `/plugins/observability/users.json` and is correctly proxied to `<ui_url of plugin_id>/users.json`
    - NOT OK -> `fetch("/users.json")` resolves to `/users.json` and is NOT proxied to your plugin.
    - NOT OK -> `fetch("../users.json")` resolves to `/plugins/users.json` and is NOT proxied to your plugin


### Plugin Responsibilities

Plugin authors are fully responsible for their own `docker-compose.yml`, including:

- service definitions
- networks
- optional `/var/run/docker.sock` mount
- any extra containers started dynamically by the plugin during its lifecycle

## Runtime Rules

- Plugin services should perform graceful shutdown by handling cleanly `SIGINT` signal (received when plugin stops) such as stopping dynamically started containers etc.
- All containers defined in the plugin compose file, and any containers the plugin starts later, must use the `scl-plugin-<id>-<name>` prefix for observability and debugging reasons.

## Reference Plugin

[`./plugins/observability`](./../plugins/observability/) is a minimal reference plugin.

It demonstrates:

- the required plugin file layout
- a simple control plane served on port `9001`
- a mounted Docker socket
- a `Refresh` action that lists running container names with the `scl-` prefix
- graceful shutdown via `SIGINT`
