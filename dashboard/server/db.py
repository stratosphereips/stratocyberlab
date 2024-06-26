import sqlite3
from typing import Tuple, List, Set, Dict
from collections import defaultdict

DATABASE = 'db.sqlite3'

def get_db():
    return sqlite3.connect(DATABASE)
    return conn

def init_db_tables():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS challenges (
            challenge_id TEXT NOT NULL PRIMARY KEY,
            challenge_name TEXT NOT NULL,
            challenge_description TEXT NOT NULL,
            difficulty TEXT NOT NULL
        );""")

    cursor.execute("""CREATE TABLE IF NOT EXISTS tasks (
            challenge_id REFERENCES challenges(challenge_id),
            task_id TEXT NOT NULL,
            task_name TEXT NOT NULL,
            task_description TEXT NOT NULL,
            flag TEXT NOT NULL,
            PRIMARY KEY(challenge_id, task_id)
        );""")

    cursor.execute("""CREATE TABLE IF NOT EXISTS task_solves (
            session TEXT NOT NULL,
            task_id REFERENCES tasks(task_id),
            challenge_id REFERENCES challenges(challenge_id),
            UNIQUE(session, task_id, challenge_id)
        );
        """)
    conn.commit()
    conn.close()

def insert_challenge_data(id: str, name: str, desc: str, diff: str):
    conn = get_db()
    cursor = conn.cursor()    
    q = 'INSERT INTO challenges (challenge_id, challenge_name, challenge_description, difficulty) VALUES (?, ?, ?, ?)'
    cursor.execute(q, (id, name, desc, diff))
    conn.commit()


def insert_task_data(chal_id: str, id: str, name: str, desc: str, flag: str):
    conn = get_db()
    cursor = conn.cursor()    
    q = 'INSERT INTO tasks (challenge_id, task_id, task_name, task_description, flag) VALUES (?, ?, ?, ?, ?)'
    cursor.execute(q, (chal_id, id, name, desc, flag))
    conn.commit()

# Returns challenges mapped to a set of solved tasks 
def get_tasks(sess: str) -> List[Dict]:
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT challenges.challenge_id,
           challenges.challenge_name,
           challenges.challenge_description,
           challenges.difficulty,
           tasks.task_id, 
           tasks.task_name, 
           tasks.task_description, 
           CASE
                WHEN solved = true THEN tasks.flag
                ELSE ''
           END as flag,
           COALESCE(solved, false) AS solved
    FROM challenges
    JOIN tasks USING(challenge_id)
    LEFT JOIN 
        (SELECT challenge_id, task_id, true as solved FROM task_solves WHERE session = ? )
            USING(challenge_id, task_id)
    """
    cursor.execute(q, (sess, ))
    rows = cursor.fetchall()
    conn.close()

    # Extract column names from the cursor
    columns = [column[0] for column in cursor.description]

    res = [dict(zip(columns, row)) for row in rows]

    return res


def get_task_flag(chal_id: str, task_id: str) -> str:
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT flag FROM tasks WHERE challenge_id = ? AND task_id = ?
    """
    cursor.execute(q, (chal_id, task_id))
    rows = cursor.fetchall()
    conn.close()

    if rows:
        return rows[0][0]
    else:
        return ""


def write_new_solve(sess: str, challenge_id: str, task_id: str):
    conn = get_db()
    cursor = conn.cursor()
    try:
        q = 'INSERT INTO task_solves (session, challenge_id, task_id) VALUES (?, ?, ?) ON CONFLICT DO NOTHING'
        cursor.execute(q, (sess, challenge_id, task_id))
        conn.commit()

    finally:
        cursor.close()
        conn.close()
