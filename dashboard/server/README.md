# StratoCyberLab Dashboard - Server

## Development

- `pip install -r requirements.txt` to install dependencies
- `python app.py` to run the development server (also done in Docker)

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
