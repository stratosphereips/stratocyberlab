from typing import List, Tuple
from pathlib import Path
from functools import wraps
from quart import Quart, request, send_from_directory, make_response, session, Response, jsonify
import json
import glob
import uuid
import sys
import db
import llm
import asyncio
import os, os.path
import docker


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# load challenges from files and bootstrap DB
def init(dir='/challenges'):
    # this file works as a check to know if DB was already bootstrapped or not
    # because otherwise this code could run multiple times if the container was restarted
    file = Path(".was_db_inited")
    if file.exists():
        return

    db.init_db_tables()

    for name in os.listdir(dir):
        if name == "template":
            continue

        ch_dir = f"{dir}/{name}"
        if not os.path.isfile(f"{ch_dir}/docker-compose.yml"):
            eprint(f"challenge {name} is missing docker-compose.yml file")
            return

        with open(f"{ch_dir}/meta.json", 'r') as f:
            ch = json.load(f)

        ch_id, ch_name, ch_diff, ch_desc = ch["id"], ch["name"], ch["difficulty"], ch["description"]
        db.insert_challenge_data(ch_id, ch_name, ch_desc, ch_diff, ch_dir)

        for task in ch["tasks"]:
            t_id, t_name, t_desc, t_flag = task["id"], task["name"], task["description"], task["flag"]
            db.insert_task_data(ch_id, t_id, t_name, t_desc, t_flag)

    file.touch()
    eprint("DB successfully initialised.")


app = Quart(__name__, static_folder='public', static_url_path='')
app.secret_key = 'does not matter since this is all local'

# wrapper that just creates session_id if it did not exist before
def manage_session(func):
    @wraps(func)
    async def wrapper(*args, **kwargs):
        if "id" not in session:
            session["id"] = uuid.uuid4().hex

        response = await func(*args, **kwargs)
        return response
    return wrapper

def get_session_id():
    return session['id']

# live check
@app.route('/live', methods=['GET'])
async def live():
    return "OK"

# root
@app.route('/', methods=['GET'])
async def root():
    return await app.send_static_file('index.html')

# Static files
@app.route('/<path:filename>', methods=["GET"])
@manage_session
async def static_files(filename):
    return await send_from_directory(app.static_folder, filename)

# ======================================
# ||             Challenges           ||
# ======================================
@app.route('/api/challenges/submit', methods=['POST'])
@manage_session
async def challenges_submit():
    if request.is_json:
        data = await request.get_json()
    else:
        data = await request.form

    challenge_id = data.get('challenge_id')
    task_id = data.get('task_id')
    submitted_flag = data.get('flag')

    db_flag = db.get_task_flag(challenge_id, task_id)

    if not db_flag:
        return 'This challenge/task does not exist -_-'

    if submitted_flag != db_flag:
        return 'Incorrect flag, try again.'

    db.write_new_solve(get_session_id(), challenge_id, task_id)

    return 'Congratulations, you found a correct flag! 🎉'

@app.route('/api/challenges', methods=['GET'])
@manage_session
async def challenges_get():
    tasks = db.get_tasks(get_session_id())

    challenges = []
    challenges_map = {}
    for t in tasks:
        ch_id, ch_name, ch_diff, ch_desc = t["challenge_id"], t["challenge_name"], t["difficulty"], t["challenge_description"]
        t_id, t_name, t_desc, t_flag, solved = t["task_id"], t["task_name"], t["task_description"], t["flag"], t["solved"]

        ch = challenges_map.get(ch_id, None)
        if not ch:
            ch = {
                "id": ch_id,
                "name": ch_name,
                "difficulty": ch_diff,
                "description": ch_desc,
                "tasks": [],
            }
            challenges_map[ch_id] = ch
            challenges.append(ch)

        ch["tasks"].append({
            "id": t_id,
            "name": t_name,
            "description": t_desc,
            "flag": t_flag,
            "solved": solved,
        })

    return jsonify(challenges)

@app.route('/api/challenges/start', methods=['POST'])
@manage_session
async def challenge_start():
    if request.is_json:
        data = await request.get_json()
    else:
        data = await request.form

    challenge_id = data.get('challenge_id')

    ch_dir = db.get_challenge_dir(challenge_id)
    if not ch_dir:
        return 'This challenge does not exist -_-'

    try:
        eprint(f"Let's start a challenge with id: '{challenge_id}'")
        docker.stop_challenge(ch_dir)  # first try to turn-off previous containers
        docker.start_challenge(ch_dir)
    except Exception as e:
        eprint(f"error starting a challenge: {e}")
        return f"error starting a challenge: {e}", 500

    return 'Challenge started! 🎉'

@app.route('/api/challenges/stop', methods=['POST'])
@manage_session
async def challenge_stop():
    if request.is_json:
        data = await request.get_json()
    else:
        data = await request.form

    challenge_id = data.get('challenge_id')

    ch_dir = db.get_challenge_dir(challenge_id)
    if not ch_dir:
        return 'This challenge does not exist -_-'

    try:
        eprint(f"Let's stop a challenge with id: '{challenge_id}'")
        docker.stop_challenge(ch_dir)
    except Exception as e:
        eprint(f"error stopping a challenge: {e}")
        return f"error stopping a challenge: {e}", 500

    return 'Challenge stopped'

@app.route('/api/challenges/up', methods=['GET'])
@manage_session
async def all_challenges_up():
    challenges = db.get_challenges()
    all_up = []

    for ch in challenges:
        up = docker.is_up(ch["challenge_dir"])
        if up:
            all_up.append(ch["challenge_id"])

    return jsonify(all_up)

@app.route('/api/challenges/up/<ch_id>', methods=['GET'])
@manage_session
async def challenge_up(ch_id):
    ch_dir = db.get_challenge_dir(ch_id)

    resp = {
        "running": docker.is_up(ch_dir)
    }

    return jsonify(resp)



# ======================================
# ||             LLM                  ||
# ======================================
@app.route('/api/llm/is_model_available', methods=['GET'])
async def llm_is_model_available():
    return jsonify({
        "available": await llm.is_model_available(),
        "pulling": pull_in_progress
    })

pull_in_progress = False
@app.route('/api/llm/pull_model', methods=['POST'])
async def llm_pull_model():
    global pull_in_progress

    # poor people synchronization with race conditions
    if pull_in_progress:
        return "Model pull is already in progress", 409
    pull_in_progress = True


    async def job():
        global pull_in_progress
        await llm.pull_model()
        pull_in_progress = False

    # Do not wait for the result
    loop = asyncio.get_event_loop()
    loop.create_task(job())

    return "Model pull started in the background", 200

@app.route('/api/llm/chat', methods=['POST'])
async def llm_chat():
    return await llm.chat_with_llm(await request.json)


if __name__ == '__main__':
    init()
    app.run(debug=True, host='0.0.0.0', port=80)
