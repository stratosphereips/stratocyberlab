  GNU nano 7.2                                                                                        server.py                                                                                                  from fastapi import FastAPI
from string import ascii_letters, digits
from random import choices, randint
import time

#characters = ascii_letters + digits
characters = digits

CORRECT_PASSWORD = "".join(choices(characters, k=randint(5, 6)))
#CORRECT_PASSWORD = "30471"
LENGTH = len(CORRECT_PASSWORD)
DELAY = 0.0025
#DELAY = 0
with open('server_access_info.txt', 'w') as sourceFile:
    print(f"length:{LENGTH}, password:{CORRECT_PASSWORD}", file=sourceFile)

assert all(c in characters for c in CORRECT_PASSWORD)

app = FastAPI()


def check_password_vulnerable(password: str) -> bool:
    """
    Checks if the password is correct.

    This is intentionally made to be vulnerable to show how a side channel timing attack could be made
    """
    if len(password) != LENGTH:
        return False
    time.sleep(DELAY) # ADD a bit of delay for the demo to be more consistant
    for i in range(len(CORRECT_PASSWORD)):
        if password[i] != CORRECT_PASSWORD[i]:
            return False
        time.sleep(DELAY) # ADD a bit of delay for the demo to be more consistant
    return True


def check_password_safe(password: str) -> bool:
    return password == CORRECT_PASSWORD


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/login/vuln/")
async def login_vuln(password: str):
    if check_password_vulnerable(password):
        return {"message": "Success"}
    return {"message": "Incorrect Password"}


@app.get("/login/safe/")
async def login_safe(password: str):
    if check_password_safe(password):
        return {"message": "Success"}
    return {"message": "Incorrect Password"}