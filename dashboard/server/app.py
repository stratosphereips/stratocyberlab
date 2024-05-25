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

    for filename in glob.glob(f"{dir}/*/meta.json"):
        if filename == "/challenges/template/meta.json":
            continue # skip for template

        with open(filename, 'r') as f:
            ch = json.load(f)

        ch_id, ch_name, ch_diff, ch_desc = ch["id"], ch["name"], ch["difficulty"], ch["description"]
        db.insert_challenge_data(ch_id, ch_name, ch_desc, ch_diff)

        for task in ch["tasks"]:
            t_id, t_name, t_desc, t_flag = task["id"], task["name"], task["description"], task["flag"]
            db.insert_task_data(ch_id, t_id, t_name, t_desc, t_flag)

    file.touch()
    eprint("DB successfuly initialised.")


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

# Endpoint to submit flags
@app.route('/api/submit', methods=['POST'])
@manage_session
async def submit():
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
async def get_challenges():
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

@app.route('/llm/is_model_available', methods=['GET'])
async def llm_is_model_available():
    return jsonify({"available": await llm.is_model_available()})

pull_in_progress = False
@app.route('/llm/pull_model', methods=['POST'])
async def llm_pull_model():
    global pull_in_progress

    # poor people synchronization with race conditions
    if pull_in_progress:
        return (409, "Model pull is already in progress")
    pull_in_progress = True

    try:
        await llm.pull_model()
    except Exception as e:
        return (500, f"error pulling a model: {e}")
    finally:
        pull_in_progress = False

@app.route('/llm/chat', methods=['POST'])
async def llm_chat():
    return await llm.chat_with_llm(await request.json)


if __name__ == '__main__':
    init()
    app.run(debug=True, host='0.0.0.0', port=80)
