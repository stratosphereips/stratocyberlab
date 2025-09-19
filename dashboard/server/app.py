import asyncio
import json
import os
import os.path
import sys
import uuid
from functools import wraps
from pathlib import Path
from typing import List

from quart import Quart, request, send_from_directory, session, jsonify

import db
import docker
import llm
from config import getenv


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def get_dirs(parent: str) -> List[str]:
    return [d for d in os.listdir(parent) if os.path.isdir(os.path.join(parent, d))]

# load challenges from files and bootstrap DB


def init(parent_ch_dir=getenv('CHALLENGE_DIR') or '/challenges', parent_cl_dir=getenv('CLASS_DIR') or '/classes', parent_campaign_dir=getenv('CAMPAIGN_DIR') or '/campaigns'):
    # this file works as a check to know if DB was already bootstrapped or not
    # because otherwise this code could run multiple times if the container was restarted
    file = Path(".was_db_inited")
    if file.exists():
        return

    db.init_db_tables()

    for name in get_dirs(parent_ch_dir):
        if name == "template":
            continue

        ch_dir = f"{parent_ch_dir}/{name}"
        if not os.path.isfile(f"{ch_dir}/docker-compose.yml"):
            eprint(f"challenge {name} is missing docker-compose.yml file")
            return

        with open(f"{ch_dir}/meta.json", 'r', encoding='utf8') as f:
            ch = json.load(f)

        ch_id, ch_name, ch_diff, ch_desc = ch["id"], ch["name"], ch["difficulty"], ch["description"]
        db.insert_challenge_data(ch_id, ch_name, ch_desc, ch_diff, ch_dir)

        for i, task in enumerate(ch["tasks"]):
            t_id, t_name, t_desc, t_flag = task["id"], task["name"], task["description"], task["flag"]
            db.insert_task_data(ch_id, t_id, t_name, t_desc, t_flag, order=i)

    for camp_name in get_dirs(parent_campaign_dir):
        if camp_name == '_template' or camp_name == 'example':
            continue

        camp_dir = f'{parent_campaign_dir}/{camp_name}'
        with open(f"{camp_dir}/meta.json", 'r', encoding='utf8') as f:
            camp = json.load(f)

        db.insert_campaign_data(camp['id'], camp['name'], camp['description'], camp['enforceOrder'], camp['showLocked'])

        for i, step in enumerate(camp['timeline']):
            if step['type'] == 'challenge':
                chall_id = step['id']
                chall_dir = f'{camp_dir}/{chall_id}'
                with open(f"{chall_dir}/meta.json", 'r', encoding='utf8') as f:
                    chall = json.load(f)

                db.insert_challenge_data(chall['id'], chall['name'], chall['description'],
                                         chall['difficulty'], chall_dir, camp['id'])

                db.insert_campaign_step(camp['id'], challenge_id=chall['id'], order=i)

                for j, task in enumerate(chall["tasks"]):
                    db.insert_task_data(chall_id, task["id"], task["name"], task["description"], task["flag"], order=j)

            if step['type'] == 'page':
                page_id = step['id']
                with open(f'{camp_dir}/pages/{page_id}.md', 'r', encoding='utf8') as f:
                    content = f.read()
                db.insert_page(page_id, step['name'], content)
                db.insert_campaign_step(camp['id'], page_id=page_id, order=i)

    for name in get_dirs(parent_cl_dir):
        if name.startswith("ignore-"):
            continue

        cl_dir = f"{parent_cl_dir}/{name}"

        with open(f"{cl_dir}/meta.json", 'r', encoding='utf8') as f:
            class_data = json.load(f)

        dir = ""
        if os.path.isfile(f"{cl_dir}/docker-compose.yml"):
            # set dir only if there is a docker-compose file
            dir = cl_dir

        id, name, desc = class_data["id"], class_data["name"], class_data["description"]
        doc_url, yt_url = class_data.get(
            "google_doc_url", ""), class_data.get("yt_recording_url", "")
        db.insert_class_data(id, name, desc, dir, doc_url, yt_url)

    file.touch()
    eprint("DB successfully initialised.")


app = Quart(__name__, static_folder='public', static_url_path='')
app.secret_key = 'does not matter since this is all local'


@app.before_serving
async def startup():
    init()
    # escaping backslashes makes it ugly here in editor but pretty in terminal
    banner = """
 ____  _             _         ____      _               _          _     
/ ___|| |_ _ __ __ _| |_ ___  / ___|   _| |__   ___ _ __| |    __ _| |__  
\\___ \\| __| '__/ _` | __/ _ \\| |  | | | | '_ \\ / _ \\ '__| |   / _` | '_ \\ 
 ___) | |_| | | (_| | || (_) | |__| |_| | |_) |  __/ |  | |__| (_| | |_) |
|____/ \\__|_|  \\__,_|\\__\\___/ \\____\\__, |_.__/ \\___|_|  |_____\\__,_|_.__/ 
                                   |___/                                  
        |  RUNNING, NAVIGATE TO http://127.0.0.1/ IN YOUR BROWSER |
        +----------------------------------------------------------+    
"""
    eprint(banner)


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

# graceful shutdown


@app.after_serving
async def shutdown():
    eprint("Initiating graceful shutdown - stopping all challenges and classes...")
    await classes_stop_all()
    await challenges_stop_all()

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
# ||             Classes              ||
# ======================================
@app.route('/api/classes', methods=['GET'])
@manage_session
async def classes_get():
    return jsonify(db.get_classes())


@app.route('/api/classes/up', methods=['GET'])
@manage_session
async def all_classes_up():
    classes = db.get_classes(only_with_compose=True)
    all_up = []

    for c in classes:
        if not c["dir"]:
            # some classes may not have docker-compose
            continue
        up = docker.is_up(c["dir"])
        if up:
            all_up.append(c["id"])

    return jsonify(all_up)


@app.route('/api/classes/start', methods=['POST'])
@manage_session
async def class_start():
    if request.is_json:
        data = await request.get_json()
    else:
        data = await request.form

    c_id = data.get('id')
    if not c_id:
        return 'Wrong request, missing id', 400

    class_dir = db.get_class_dir(c_id)
    if not class_dir:
        return 'This class does not exist or does not have a docker-compose file', 400

    try:
        eprint(f"Let's start a class with id: '{c_id}'")
        # first try to turn-off previous containers
        docker.stop_compose(class_dir)
        docker.start_compose(class_dir)
    except Exception as e:
        eprint(f"error starting a class: {e}")
        return f"error starting a class: {e}", 500

    return 'Class started! 🎉'


@app.route('/api/classes/stop', methods=['POST'])
@manage_session
async def class_stop():
    if request.is_json:
        data = await request.get_json()
    else:
        data = await request.form

    c_id = data.get('id')
    if not c_id:
        return 'Wrong request, missing id', 400

    class_dir = db.get_class_dir(c_id)
    if not class_dir:
        return 'This class does not exist or does not have a docker-compose file', 400

    try:
        eprint(f"Let's stop a class with id: '{c_id}'")
        docker.stop_compose(class_dir)
    except Exception as e:
        eprint(f"error stopping a class: {e}")
        return f"error stopping a class: {e}", 500

    return 'Class stopped'


async def classes_stop_all():
    classes = db.get_classes(only_with_compose=True)

    eprint("Stopping all classes")
    for c in classes:
        c_dir = c["dir"]
        c_id = c["id"]

        try:
            eprint(f"Let's stop a class with id: '{c_id}'")
            docker.stop_compose(c_dir)
        except Exception as e:
            eprint(f"error stopping a class: {e}")
            return f"error stopping a class: {e}", 500

    return 'All stopped! 🎉'

# ======================================
# ||             Campaigns            ||
# ======================================


@app.route('/api/campaigns', methods=['GET'])
@manage_session
async def campaigns_get():
    return jsonify(db.get_campaigns())


@app.route('/api/campaigns/<campaign_id>', methods=['GET'])
@manage_session
async def campaign_get(campaign_id: str):
    steps_from_db = db.get_campaign_steps(campaign_id, get_session_id())

    if len(steps_from_db) == 0:
        return "Campaign not found", 404

    enforce_order = steps_from_db[0]['enforce_order']
    show_locked = steps_from_db[0]['show_locked'] or not enforce_order

    parsed_steps = []
    step_map = {}
    for t in steps_from_db:
        if t['step_type'] == 'page':
            parsed_steps.append({
                'id': t['page_id'],
                'type': 'page',
                'name': t['page_name'],
                'content': t['page_content'],
            })
            continue

        ch_id = t["challenge_id"]

        ch = step_map.get(ch_id, None)
        if not ch:
            ch = {
                "id": ch_id,
                'type': 'challenge',
                "name": t['challenge_name'],
                "difficulty": t["difficulty"],
                "description": t["challenge_description"],
                "tasks": [],
                "dir": t['challenge_dir'],
            }
            step_map[ch_id] = ch
            parsed_steps.append(ch)

        ch["tasks"].append({
            "id": t["task_id"],
            "name": t["task_name"],
            "description": t["task_description"],
            "flag": t["flag"],
            "solved": t["solved"],
        })

        if t['step_type'] == 'challenge' and not t['solved'] and not show_locked:
            break

    for ch in parsed_steps:
        if ch['type'] != 'challenge':
            continue
        up = docker.is_up(ch["dir"])
        if up:
            ch['running'] = True

        # do not expose directories to FE
        del ch['dir']

    return jsonify({
        'id': steps_from_db[0]['campaign_id'],
        'steps': parsed_steps,
    })

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
        ch_id, ch_name, ch_diff, ch_desc = t["challenge_id"], t[
            "challenge_name"], t["difficulty"], t["challenge_description"]
        t_id, t_name, t_desc, t_flag, solved = t["task_id"], t[
            "task_name"], t["task_description"], t["flag"], t["solved"]

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


@app.route('/api/challenges/start/all', methods=['POST'])
@manage_session
async def challenges_start_all():
    challenges = db.get_challenges(include_campaigns=True)

    eprint("Starting all challenges")
    for ch in challenges:
        ch_dir = ch["challenge_dir"]
        ch_id = ch["challenge_id"]

        try:
            eprint(f"Let's start a challenge with id: '{ch_id}'")
            # first try to turn-off previous containers
            docker.stop_compose(ch_dir)
            docker.start_compose(ch_dir)
        except Exception as e:
            eprint(f"error starting a challenge ({ch_id}): {e}")
            return f"error starting a challenge ({ch_id}): {e}", 500

    return 'All started! 🎉'


@app.route('/api/challenges/stop/all', methods=['POST'])
@manage_session
async def route_challenges_stop_all():
    return await challenges_stop_all()


async def challenges_stop_all():
    challenges = db.get_challenges(include_campaigns=True)

    eprint("Stopping all challenges")
    for ch in challenges:
        ch_dir = ch["challenge_dir"]
        ch_id = ch["challenge_id"]

        try:
            eprint(f"Let's stop a challenge with id: '{ch_id}'")
            docker.stop_compose(ch_dir)
        except Exception as e:
            eprint(f"error stopping a challenge ({ch_id}): {e}")
            return f"error stopping a challenge ({ch_id}): {e}", 500

    return 'All stopped! 🎉'


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
        return 'This challenge does not exist -_-', 404

    try:
        eprint(f"Let's start a challenge with id: '{challenge_id}'")
        # first try to turn-off previous containers
        docker.stop_compose(ch_dir)
        docker.start_compose(ch_dir)
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
        return 'This challenge does not exist -_-', 404

    try:
        eprint(f"Let's stop a challenge with id: '{challenge_id}'")
        docker.stop_compose(ch_dir)
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


# ======================================
# ||             LLM                  ||
# ======================================
@app.route('/api/llm/state', methods=['GET'])
async def llm_state():
    return jsonify({
        "current_model": llm.get_current_model(),
        "models": await llm.list_local_models(),
        "pulls": llm.get_pulls_snapshot(),
    })

@app.route('/api/llm/models', methods=['GET'])
async def llm_list_models():
    return jsonify({"models": await llm.list_local_models()})


@app.route('/api/llm/models/info', methods=['GET'])
async def llm_model_info():
    name = request.args.get('name', '').strip()
    if not name:
        return "Missing 'name' query parameter", 400
    try:
        info = await llm.model_info(name)
        return jsonify(info)
    except Exception as e:
        return f"Could not get info for '{name}': {e}", 404


@app.route('/api/llm/models/pull', methods=['POST'])
async def llm_pull_model():
    data = await request.get_json()
    name = (data or {}).get('name', '').strip()
    if not name:
        return "Missing 'name' in body", 400
    # Start or no-op if already pulling
    await llm.pull_model(name)
    return "Pull started (or already in progress)", 200

@app.route('/api/llm/pulls', methods=['GET'])
async def llm_pulls():
    return jsonify({"pulls": llm.get_pulls_snapshot()})


@app.route('/api/llm/models/<path:name>', methods=['DELETE'])
async def llm_delete_model(name):
    try:
        await llm.delete_local_model(name)
        return "Deleted", 200
    except Exception as e:
        return f"Delete failed: {e}", 400


@app.route('/api/llm/model', methods=['GET', 'PUT'])
async def llm_current_model():
    if request.method == 'GET':
        return jsonify({"current_model": llm.get_current_model()})
    else:
        data = await request.get_json()
        name = (data or {}).get('name', '').strip()
        if not name:
            return "Missing 'name' in body", 400
        try:
            await llm.set_current_model(name)
            return "OK", 200
        except Exception as e:
            return str(e), 400


@app.route('/api/llm/chat', methods=['POST'])
async def llm_chat():
    try:
        body = await request.get_json()
        return await llm.chat_with_llm(body)
    except Exception as e:
        return str(e), 400


if __name__ == '__main__':
    # Only for debug running, in docker-compose we use hypercorn
    init()
    app.run(debug=True, host=getenv('HOST') or '0.0.0.0', port=getenv('PORT') or 80)
