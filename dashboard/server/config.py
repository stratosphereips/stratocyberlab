import os

from dotenv import dotenv_values, find_dotenv

config = {
    **dotenv_values(find_dotenv()),
    **os.environ
}


def getenv(key: str) -> str | None:
    if key in config:
        return config[key]

    return None
