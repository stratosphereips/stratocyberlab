from flask import Flask, request, render_template_string, send_from_directory, make_response, session, Response
import json
import os
import glob
import uuid
from copy import deepcopy
from datetime import datetime, timedelta
from typing import List, Tuple
from pathlib import Path
from functools import wraps
import db

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
    print("DB successfuly initialised.")
    

SESS_COOKIE_NAME = "playground_sess_id"
app = Flask(__name__, static_folder='public', static_url_path='')
app.secret_key = 'does not matter since this is all local'
init()

# wrapper that just creates session_id if it did not exist before
def manage_session(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if "id" not in session:
            session["id"] = uuid.uuid4().hex
        
        response = func(*args, **kwargs)
            
        return response
    return wrapper

def get_session_id():
    return session['id']

# livecheck
@app.route('/live', methods=['GET'])
def live():
    return "OK"


# livecheck
@app.route('/', methods=['GET'])
def root():
    return app.send_static_file('index.html')

# Static
@app.route('/<path:filename>', methods=["GET"])
@manage_session
def static_files(filename):
    return send_from_directory(app.static_folder, filename)


# Endpoint to submit flags
@app.route('/api/submit', methods=['POST'])
@manage_session
def submit():
    if request.is_json:
        # Handle request as JSON
        data = request.get_json()
    else:
        # Handle request as Form Data
        data = request.form

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


# Endpoint to submit flags
@app.route('/api/challenges', methods=['GET'])
@manage_session
def get_challenges():
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

        
    return challenges


if __name__ == '__main__':
    init()
    app.run(debug=True, host="0.0.0.0", port=80)
