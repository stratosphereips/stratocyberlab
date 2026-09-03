# StratoCyberLab Dashboard - Server

## Development

- Install [uv](https://docs.astral.sh/uv/getting-started/installation/), then run
  `uv venv && uv pip install -r requirements.txt -r requirements-dev.txt` to
  create a virtual environment and install dependencies (including development
  tools)
- Locally edit `.env` (do not commit it!) to remove leading slash from
  directories (e.g. `CHALLENGE_DIR`), so that relative paths are used, unlike
  in the Docker where both the directories are indeed located at `/`
- `uv run python app.py` to run the development server (also done in Docker)
- `uv run python ws_ssh.py` to run the websocket server
  - The reason for 2 servers is a conflict of threading (used for SSH
    connections in `ws_ssh.py`) and asyncio (used by Quart in http server)

## Code Quality

Before committing your changes, please make sure they do not generate new
warnings (contain lints) and the code is properly formatted.

### Linting

We use [pylint](https://pypi.org/project/pylint) to check server code for lints.
Use the command `uv run pylint .` (in this directory) to run code analysis.

### Formatting

[autopep8](https://pypi.org/project/autopep8) is used for code formatting.
Use the command `uv run autopep8 --in-place *.py` (in this directory) to reformat
all code.
