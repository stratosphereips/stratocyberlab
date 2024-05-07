from flask import Flask, request, render_template_string, send_from_directory
import json
import os
import glob


app = Flask(__name__)


# Load challenges from files
def load_challenges(dir='/challenges'):
    challenges = []
    challenges_map = {}

    for filename in glob.glob(f"{dir}/*/meta.json"):
        if filename == "/challenges/template/meta.json":
            continue # skip template
        with open(filename, 'r') as f:
            ch = json.load(f)
            ch["tasks_map"] = {task["id"]:task for task in ch.get("tasks", [])}
            
            if len(ch["tasks_map"]) != len(ch.get("tasks", [])):
                raise Exception(f"Conflict of task IDs in challenge {ch.get('name', '')}")

            ch_id = ch.get("id", "")
            if ch_id in challenges_map:
                raise Exception(f"Conflict of challenge ID {ch_id}")

            challenges.append(ch)
            challenges_map[ch_id] = ch

    return challenges, challenges_map

challenges, challenges_map = load_challenges()

# Home page
@app.route('/')
def home():
    return render_template_string(open('templates/index.html').read(), challenges=challenges)

@app.route('/favicon.ico')
def favicon():
    return send_from_directory("static", 'favicon.ico', mimetype='image/vnd.microsoft.icon')

# Endpoint to submit flags
@app.route('/submit', methods=['POST'])
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

    ch = challenges_map.get(challenge_id, {})
    if not ch:
        return 'This challenge does not exist -_-'

    t = ch.get("tasks_map", {}).get(task_id, {})
    if not t:
        return 'This task does not exist -_-'

    correct_flag = t.get("flag", "")
    if not correct_flag:
        return 'There seems to be a missing flag configured for this task'

    if submitted_flag != correct_flag:
        return 'Incorrect flag, try again.'

    return 'Congratulations, you found a correct flag! 🎉'


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=80)
