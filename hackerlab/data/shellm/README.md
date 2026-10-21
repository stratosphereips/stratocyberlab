# shelLMv2 Docker

A dockerized, SSH-reachable wrapper around [shelLMv2](../shelLMv2): an LLM-driven
fake interactive shell, used here as an SSH honeypot other people can connect to
and try to "hack."

## What's in here

- `Dockerfile` - builds a self-contained image (Python + openssh-server + the
  shelLMv2 app).
- `docker_config/entrypoint.sh` - generates SSH host keys, creates the honeypot
  login user, and starts `sshd` on the configured port (default **1397**, chosen
  to avoid clashing with Cowrie's 2222 - change it via `PORT` in `.env`).
  Doubles as a plain setup script if you ever need to run this without
  Docker-in-Docker - see note at the top of the file.
- `docker_config/run_shellm.sh` - the `ForceCommand` every SSH login is dropped
  into instead of a real shell. Re-syncs `personality_prompt.yaml` into the
  app's internal copy on every connection (so editing the top-level file always
  takes effect on your next login, nothing else to keep in sync), then launches
  `LinuxSSHbot.py` with the provider/model from `.env`.
- `docker_config/sshd_config` - minimal sshd config: password auth only, the
  honeypot user is force-commanded into the bot. `Port` and `Match User` are
  rewritten by `entrypoint.sh` on every run from `.env`'s `PORT`/`HONEYPOT_USER`
  - don't bother editing this file directly, it'll just get overwritten.
- `personality_prompt.yaml` - **this is what you edit.** A bare, functional-only
  skeleton: just the technical rules that keep the model behaving like a shell
  (prompt format, error message style, no meta-commentary). It has no persona,
  no backstory, no fake users or files - left as-is, it produces an obviously
  generic, unconvincing shell. Building an actual convincing persona here is
  the point of the exercise.
- `shellm_app/` - vendored `shelLMv2` code, with two small adaptations from
  upstream: an added `groq` provider (`LLM_Plugins/api_clients/groq_client.py`,
  Groq's API is OpenAI-compatible so this is a thin client), and `.env`/
  personality-file path resolution adjusted to work cleanly inside this image
  (upstream expects `.env` two directories above the script and only accepts a
  `.yml` extension for personality files; this fork checks `/opt/shellm/.env`
  first and accepts both `.yml` and `.yaml`).
- `env.template` - copy to `.env` and fill in.

## Build & run

```bash
cp env.template .env
# edit .env: set PROVIDER (einfra|openai|groq), the matching API key and model,
# a HONEYPOT_USER/HONEYPOT_PASSWORD for people to log in with, and PORT if you
# don't want the default 1397.
# edit personality_prompt.yaml: build out your actual persona.

docker build -t shellm-honeypot .
docker run -d --name shellm-honeypot \
    --env-file .env \
    -p 1397:1397 \
    shellm-honeypot
```
(If you changed `PORT` in `.env`, update the `-p` mapping and the Dockerfile's
`EXPOSE` line to match.)

Then anyone on the network can:
```bash
ssh <HONEYPOT_USER>@<host> -p <PORT>
```
...and lands in the fake shell instead of a real one.

### Running without Docker-in-Docker

If your environment can't nest Docker (e.g. a restricted/unprivileged container),
skip `docker build`/`docker run` entirely - `docker_config/entrypoint.sh` works
standalone on any Debian/Ubuntu system with root:

```bash
cp env.template .env   # same as above
# edit .env and personality_prompt.yaml the same way
sudo bash docker_config/entrypoint.sh
```

It installs `openssh-server` and the Python deps itself if they're missing, then
starts the same honeypot sshd on the configured `PORT`. Networking/connectivity
for anyone SSHing in is identical either way - this only changes how it's
launched.

### Changing the port later

Edit `PORT` in `.env`, then re-run `entrypoint.sh` (same command as above) -
it rewrites `sshd_config`'s `Port` line and restarts cleanly. If the old sshd
process is still bound to the previous port, stop it first:
```bash
sudo pkill -f "sshd -f /opt/shellm/docker_config/sshd_config"
```

## Supported providers

| `PROVIDER` | Needs | Notes |
|---|---|---|
| `einfra`  | `EINFRA_API_KEY`  | CESNET e-INFRA endpoint |
| `openai`  | `OPENAI_API_KEY`  | OpenAI's API |
| `groq`    | `GROQ_API_KEY`    | Free tier at console.groq.com. Model names differ from e-infra/OpenAI - e.g. `openai/gpt-oss-120b`, not `gpt-oss-120b`. List available models: `curl https://api.groq.com/openai/v1/models -H "Authorization: Bearer $GROQ_API_KEY"` |
| `ollama`  | `OLLAMA_BASE_URL` | Local/remote Ollama instance |

Only one provider is active per run (whatever `PROVIDER` is set to in `.env`).

## Troubleshooting

- **"ssh: connect to host: Network is unreachable"** right after login: the
  backend API call failed (bad/missing key, wrong model name, or the account
  doesn't have access to that endpoint). This message is deliberately generic
  so a real attacker doesn't learn why - to see the real error, run
  `python3 shellm_app/LinuxSSHbot.py --provider ... --model ... --personality personality_prompt --trace`
  directly (not through SSH) and read the traceback.
- **Session continues an old persona after editing `personality_prompt.yaml`**:
  shelLM intentionally carries conversation history across sessions for
  consistency. Clear `shellm_app/logs/` to force a fresh start with your edited
  personality.
- **A reasoning-style model (e.g. `gpt-oss-120b` on Groq) returns empty output**:
  it spent its whole token budget on internal reasoning before writing a reply.
  The default `max_tokens: 900` in the API clients is normally enough for real
  commands; this mostly only shows up with artificially tiny token limits.
- **Logging in as a honeypot user lands you in a real shell, not the LLM**:
  means `sshd_config`'s `Match User` doesn't match `HONEYPOT_USER` - re-run
  `entrypoint.sh`, it rewrites that line from `.env` on every run.
