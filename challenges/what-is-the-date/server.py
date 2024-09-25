import subprocess

from flask import Flask, send_file

# Oh no, my quote was not enough? :O
# BSY{WYwjgqdrtyTiH9MFnyxMqvsFyYob0qGHYATtzf0HWoXiKnTofAUkVqAR4bed}

app = Flask(__name__)

def quote(cmd: str) -> str:
    return f"'{cmd}'"


@app.route("/cmd/<path:cmd>", methods=['GET'])
def execute_cmd(cmd):
    if not cmd.startswith("date"):
        return "Nope, this service serves only date data!", 401

    p = subprocess.run(
        quote(cmd),
        text=True,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT
    )
    return p.stdout


@app.route("/", methods=['GET'])
def get_index():
    return send_file('./index.html')


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=80)