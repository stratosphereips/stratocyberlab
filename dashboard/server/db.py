import sqlite3
import json
from typing import List, Dict

DATABASE = 'db.sqlite3'


def get_db():
    return sqlite3.connect(DATABASE)


def init_db_tables():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
            CREATE TABLE IF NOT EXISTS classes (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT NOT NULL,
                dir TEXT NOT NULL,
                google_doc_url TEXT,
                yt_recording_url TEXT,
                starting_time TEXT
            );""")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS campaigns (
                campaign_id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT NOT NULL,
                enforce_order BOOLEAN NOT NULL,
                show_locked BOOLEAN NOT NULL
            );""")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pages (
                page_id TEXT NOT NULL PRIMARY KEY,
                page_name TEXT NOT NULL,
                page_content TEXT NOT NULL
            );""")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS challenges (
            challenge_id TEXT NOT NULL,
            challenge_name TEXT NOT NULL,
            challenge_description TEXT NOT NULL,
            difficulty TEXT NOT NULL,
            challenge_dir TEXT NOT NULL,
            tags TEXT NOT NULL, -- json encoded list of strings because sqlite does not support arrays
            campaign_id REFERENCES campaigns(campaign_id),
            PRIMARY KEY (challenge_id, campaign_id)
        );""")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS campaign_steps (
                campaign_id REFERENCES campaigns(campaign_id),
                "order" INTEGER NOT NULL,
                challenge_id REFERENCES challenges(challenge_id),
                page_id REFERENCES pages(page_id),
                PRIMARY KEY(campaign_id, "order")
            );""")

    cursor.execute("""CREATE TABLE IF NOT EXISTS tasks (
            challenge_id REFERENCES challenges(challenge_id),
            task_id TEXT NOT NULL,
            task_name TEXT NOT NULL,
            task_description TEXT NOT NULL,
            flag TEXT NOT NULL,
            task_order INTEGER NOT NULL,
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


def insert_class_data(id: str, name: str, desc: str, cl_dir: str, doc_url: str, yt_url: str, starting_time: str):
    conn = get_db()
    cursor = conn.cursor()
    q = 'INSERT INTO classes (id, name, description, dir, google_doc_url, yt_recording_url, starting_time) VALUES (?, ?, ?, ?, ?, ?, ?)'
    cursor.execute(q, (id, name, desc, cl_dir, doc_url, yt_url, starting_time))
    conn.commit()


def get_classes(only_with_compose: bool = False) -> List[Dict]:
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT id, name, description, dir, google_doc_url, yt_recording_url, starting_time
    FROM classes
    """
    if only_with_compose:
        q += "\nWHERE dir != ''"
    q += "\nORDER BY id"
    cursor.execute(q)
    rows = cursor.fetchall()
    conn.close()

    # Extract column names from the cursor
    columns = [column[0] for column in cursor.description]

    res = [dict(zip(columns, row)) for row in rows]

    return res


def insert_challenge_data(id: str, name: str, desc: str, diff: str, ch_dir: str, tags: List[str], campaign_id: str | None = None):
    if not isinstance(tags, list):
        raise Exception(f"Challenge tags must be array and not {type(tags)}")

    conn = get_db()
    cursor = conn.cursor()
    if campaign_id is None:
        q = 'INSERT INTO challenges (challenge_id, challenge_name, challenge_description, difficulty, challenge_dir, tags) VALUES (?, ?, ?, ?, ?, ?)'
        p = (id, name, desc, diff, ch_dir, json.dumps(tags))
    else:
        q = 'INSERT INTO challenges (challenge_id, challenge_name, challenge_description, difficulty, challenge_dir, campaign_id, tags) VALUES (?, ?, ?, ?, ?, ?, ?)'
        p = (id, name, desc, diff, ch_dir, campaign_id, json.dumps(tags))
    cursor.execute(q, p)
    conn.commit()


def insert_task_data(chal_id: str, id: str, name: str, desc: str, flag: str, order: int):
    conn = get_db()
    cursor = conn.cursor()
    q = 'INSERT INTO tasks (challenge_id, task_id, task_name, task_description, flag, task_order) VALUES (?, ?, ?, ?, ?, ?)'
    cursor.execute(q, (chal_id, id, name, desc, flag, order))
    conn.commit()


def insert_campaign_data(id: str, name: str, description: str, enforce_order: bool, show_locked: bool):
    conn = get_db()
    cursor = conn.cursor()
    q = 'INSERT INTO campaigns (campaign_id, name, description, enforce_order, show_locked) VALUES (?, ?, ?, ?, ?)'
    p = (id, name, description, enforce_order, show_locked)
    cursor.execute(q, p)
    conn.commit()


def insert_page(page_id: str, page_name: str, page_content: str):
    conn = get_db()
    cursor = conn.cursor()
    q = 'INSERT INTO pages (page_id, page_name, page_content) VALUES (?, ?, ?)'
    p = (page_id, page_name, page_content)
    cursor.execute(q, p)
    conn.commit()


def insert_campaign_step(campaign_id: str, order: int, challenge_id: str | None = None, page_id:
                         str | None = None):
    if challenge_id is None and page_id is None:
        raise Exception("Either challenge_id or page_id must be filled!")
    conn = get_db()
    cursor = conn.cursor()
    if page_id is not None:
        q = 'INSERT INTO campaign_steps (campaign_id, "order", page_id) VALUES (?, ?, ?)'
        p = (campaign_id, order, page_id)
    else:
        q = 'INSERT INTO campaign_steps (campaign_id, "order", challenge_id) VALUES (?, ?, ?)'
        p = (campaign_id, order, challenge_id)
    cursor.execute(q, p)
    conn.commit()


def get_tasks(sess: str) -> List[Dict]:
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT challenges.challenge_id,
           challenges.challenge_name,
           challenges.challenge_description,
           challenges.difficulty,
           challenges.tags as challenge_tags,
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
    WHERE campaign_id IS NULL
    ORDER BY task_order ASC
    """
    cursor.execute(q, (sess, ))
    rows = cursor.fetchall()
    conn.close()

    # Extract column names from the cursor
    columns = [column[0] for column in cursor.description]

    res = [dict(zip(columns, row)) for row in rows]

    for it in res:
        # Parse the json encoded tags
        it["challenge_tags"] = json.loads(it.get("challenge_tags", "[]"))

    return res


def get_campaigns():
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT
    campaign_id as id,
    name,
    description
    FROM
    campaigns
    """

    cursor.execute(q)
    rows = cursor.fetchall()
    conn.close()

    # Extract column names from the cursor
    columns = [column[0] for column in cursor.description]

    res = [dict(zip(columns, row)) for row in rows]

    return res


def get_campaign_steps(campaign_id: str, sess: str):
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT
    campaigns.campaign_id,
    campaigns.enforce_order,
    campaigns.show_locked,
    campaign_steps.challenge_id,
    challenges.challenge_name,
    challenges.challenge_description,
    challenges.challenge_dir,
    challenges.difficulty,
    tasks.task_id,
    tasks.task_name,
    tasks.task_description,
    pages.page_id,
    pages.page_name,
    pages.page_content,
    CASE
        WHEN solved = true THEN tasks.flag
        ELSE ''
    END as flag,
    CASE
        WHEN campaign_steps.challenge_id IS NULL THEN 'page'
        ELSE 'challenge'
    END as step_type,
    COALESCE(solved, false) AS solved
    FROM campaigns
    JOIN campaign_steps USING(campaign_id)
    LEFT JOIN challenges ON (campaign_steps.challenge_id = challenges.challenge_id)
    LEFT JOIN pages ON (campaign_steps.page_id = pages.page_id)
    LEFT JOIN tasks USING(challenge_id)
     LEFT JOIN
        (SELECT challenge_id, task_id, true as solved FROM task_solves WHERE session = ? )
            USING(challenge_id, task_id)
    WHERE campaigns.campaign_id = ?
    ORDER BY "order" ASC, task_order ASC
    ;"""

    cursor.execute(q, (sess, campaign_id))
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

    return ""


def get_challenge_dir(chal_id: str) -> str:
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT challenge_dir FROM challenges WHERE challenge_id = ?
    """
    cursor.execute(q, (chal_id, ))
    rows = cursor.fetchall()
    conn.close()

    if rows:
        return rows[0][0]
    return ""


def get_class_dir(c_id: str) -> str:
    conn = get_db()
    cursor = conn.cursor()
    q = """
    SELECT dir FROM classes WHERE id = ?
    """
    cursor.execute(q, (c_id, ))
    rows = cursor.fetchall()
    conn.close()

    if rows:
        return rows[0][0]
    return ""


def get_challenges(include_campaigns=False) -> List[Dict]:
    conn = get_db()
    cursor = conn.cursor()
    q = """
        SELECT challenge_id, challenge_name, challenge_description, challenge_dir
        FROM challenges
    """
    if not include_campaigns:
        q += "WHERE campaign_id IS NULL"
    cursor.execute(q)
    rows = cursor.fetchall()
    conn.close()

    # Extract column names from the cursor
    columns = [column[0] for column in cursor.description]

    res = [dict(zip(columns, row)) for row in rows]

    return res


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
