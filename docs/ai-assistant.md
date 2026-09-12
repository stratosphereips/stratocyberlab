# AI assistant

The assistant supports local Ollama models and external OpenAI-compatible providers
with your own API key. Ollama is optional: `docker compose up` starts only the
dashboard and Hackerlab, without downloading the Ollama image.

## Local models

Open **AI Assistant → Models → Start Ollama**. The first start may download the
Ollama image (about 5 GB), which can take several minutes depending on your
connection. The modal shows when the image is downloading and the service is
starting. You can close the modal while it works; keep the dashboard running.

**Stop Ollama** stops and removes the service container, freeing its runtime
resources and network attachment. Downloaded models and the selected model are
persisted. Start Ollama again to resume using a local model. Stopping also interrupts
any local model downloads or requests from other browser windows.

The standalone container is named `scl-ollama`, uses `ollama/ollama:0.34.0`, and
joins `playground-net` at `172.20.0.100`. It publishes no host ports.

The dashboard's graceful shutdown stops and removes Ollama automatically, including
when you run `docker compose stop` or `docker compose down`. Pending background
operations finish or are cancelled before this cleanup, so a startup cannot later
restart Ollama. Downloaded models and the cached image are kept. The dashboard has
a two-minute Compose stop grace period to allow managed-container cleanup.

A forced termination or crash can bypass graceful shutdown. If Ollama remains
running, start the dashboard and stop it in **Models**, or run
`docker stop scl-ollama` followed by `docker rm scl-ollama` on the host.
These commands keep the models and release the `playground-net` attachment.

### Model storage and upgrades

Models remain in the SCL folder's `./ollama/` directory on Linux, macOS and Windows
with Docker Desktop. The dashboard has a read-only mount of this directory at
`/ollama`. It inspects its own Docker mount and passes the daemon's source path
to the standalone container, which mounts it at `/root/.ollama` with write access.

To reclaim model disk space, stop Ollama, shut down SCL, and delete `./ollama/`.
This permanently removes downloaded models. Docker's cached Ollama image is
separate; after removing the container, `docker image rm ollama/ollama:0.34.0`
removes that image if it is no longer used.

## External providers

In **Models**, add an external provider's base URL, model ID and API key, then
select it. External chat and model configuration work with Ollama stopped and
while its image downloads. Requests are sent to the configured provider.
Saved keys and model selection use the dashboard's
[persistent state](./persistent-state.md).

## Server API

`GET /api/llm/state` includes an `ollama` object with `status`, `busy`, `running`
and `error`, alongside the model lists and selection. Local model discovery is
skipped while the container is absent or a lifecycle operation is in progress.

`POST /api/llm/ollama/start` and `POST /api/llm/ollama/stop` accept an empty JSON
object. They return HTTP 202 and run in the background. Poll the state endpoint
for completion or errors. Overlapping lifecycle requests return HTTP 409.
Container image, name, network, address and storage destination are fixed by the
server; these endpoints do not accept container configuration from the browser.

The lifecycle and assistant regression tests mock Docker and model providers:

```bash
python -m unittest discover -s tests -p 'test_ollama_runtime.py'
python -m unittest discover -s tests -p 'test_llm.py'
```
