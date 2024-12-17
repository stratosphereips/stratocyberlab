# StratoCyberLab Dashboard - Server

## Development

- `pip install -r requirements.txt && pip install -r requirements-dev.txt` to 
  install dependencies (including development tools)
- Locally edit `.env` (do not commit it!) to remove leading slash from 
  directories (e.g. `CHALLENGE_DIR`), so that relative paths are used, unlike 
  in the Docker where both the directories are indeed located at `/`
- `python app.py` to run the development server (also done in Docker)
- `python ws_ssh.py` to run the websocket server 
  - The reason for 2 servers is a conflict of threading (used for SSH 
    connections in `ws_ssh.py`) and asyncio (used by Quart in http server)  

## Code Quality

Before committing your changes, please make sure they do not generate new 
warnings (contain lints) and the code is properly formatted.

### Linting

We use [pylint](https://pypi.org/project/pylint) to check server code for lints.
Use the command `pylint .` (in this directory) to run code analysis.

### Formatting

[autopep8](https://pypi.org/project/autopep8) is used for code formatting.
Use the command `autopep8 --in-place *.py` (in this directory) to reformat 
all code.
