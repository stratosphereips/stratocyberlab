from flask import Flask, jsonify, request
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Station-issued credentials. The decoys are honeytokens: attempted use is logged.
KEYS = [
    {"id": "K-19", "key": "kplr_7f2d91c6a4b803ee"},
    {"id": "K-24", "key": "kplr_45a0cd812f67bb39"},
    {"id": "K-31", "key": "kplr_b6e3380d9a2f147c"},
    {"id": "K-42", "key": "kplr_0e8ac53971d24fb6"}
]
ACTIVE_ID = "K-31"
ACTIVE_KEY = next(item["key"] for item in KEYS if item["id"] == ACTIVE_ID)

@app.get("/")
def index():
    return """<html><title>Kepler Station | Admin Relay</title><body>
<h1>Kepler Station Admin Relay</h1>
<p>Orbital operations archive: service directory and maintenance records.</p>
<ul><li><a href='/public/roster.json'>Credential roster</a></li>
<li><a href='/archive/maintenance.ini'>Maintenance record</a></li>
<li><a href='/console/record'>Admin console</a></li></ul>
</body></html>"""

@app.get("/public/roster.json")
def roster():
    return jsonify({"station": "Kepler-9", "issued_credentials": KEYS})

@app.get("/archive/maintenance.ini")
def maintenance_record():
    return """[relay]
station=Kepler-9
credential_set=night-watch
active_credential_id=K-31
last_rotation=2189-04-17T03:14:00Z
""", 200, {"Content-Type": "text/plain; charset=utf-8"}

@app.get("/console/record")
def console_record():
    supplied = request.headers.get("X-Station-Key", "")
    if supplied != ACTIVE_KEY:
        honeytoken = any(item["key"] == supplied for item in KEYS)
        if honeytoken:
            logging.warning("HONEYTOKEN ALERT: attempted station credential use")
            return jsonify({"status": "denied", "message": "Security alert: unauthorized credential presented. Relay access suspended."}), 401
        return jsonify({"status": "denied", "message": "Credential not recognized. Relay access denied."}), 401
    return jsonify({"status": "ok", "record": "Recovered station log: the Kepler crew made it to the escape vessel.", "flag": "BSY{8SGtKkSESEX6xcBSCQOAvWxuEMnUpYjq}"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
