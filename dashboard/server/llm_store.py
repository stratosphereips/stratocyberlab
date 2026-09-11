"""SQLite configuration for the AI assistant. Public reads never include API keys."""

from contextlib import closing, contextmanager, nullcontext
import sqlite3
from urllib.parse import urlsplit

import db


@contextmanager
def _transaction():
    with closing(db.get_db()) as conn:
        with conn:
            yield conn


def init_tables(connection=None):
    """Create assistant tables even when content has already been bootstrapped."""
    with (nullcontext(connection) if connection is not None else _transaction()) as conn:
        conn.execute("""CREATE TABLE IF NOT EXISTS llm_external_models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            provider TEXT NOT NULL,
            base_url TEXT NOT NULL,
            model TEXT NOT NULL,
            api_key TEXT NOT NULL
        )""")
        conn.execute("""CREATE TABLE IF NOT EXISTS llm_selection (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            local_model TEXT NOT NULL DEFAULT '',
            external_id INTEGER REFERENCES llm_external_models(id)
        )""")
        conn.execute("""INSERT OR IGNORE INTO llm_selection (id, local_model)
                        VALUES (1, 'llama3.1:latest')""")


def list_models():
    """Return editable metadata, without credentials or credential fragments."""
    with closing(db.get_db()) as conn:
        conn.row_factory = sqlite3.Row
        return [dict(row) for row in conn.execute(
            'SELECT id, provider, base_url, model FROM llm_external_models ORDER BY id')]


def get_model(model_id):
    """Private read for outgoing requests only; includes the API key."""
    with closing(db.get_db()) as conn:
        conn.row_factory = sqlite3.Row
        row = conn.execute('SELECT * FROM llm_external_models WHERE id = ?',
                           (model_id,)).fetchone()
        return dict(row) if row else None


def save_model(data, model_id=None):
    """Create or update a model. A blank key on update preserves the saved key."""
    if not isinstance(data, dict):
        raise ValueError('Expected a model configuration.')
    fields = ('provider', 'base_url', 'model', 'api_key')
    if any(not isinstance(data.get(field, ''), str) for field in fields):
        raise ValueError('Model configuration fields must be text.')
    provider, base_url, model, api_key = (data.get(field, '').strip() for field in fields)
    if provider not in ('einfra', 'openai', 'anthropic', 'custom'):
        raise ValueError('Choose a provider or Custom.')
    try:
        url = urlsplit(base_url)
        valid_url = url.scheme in ('http', 'https') and url.hostname
    except ValueError:
        valid_url = False
    if not valid_url:
        raise ValueError('Enter an HTTP or HTTPS API base URL.')
    if url.username or url.password or url.query or url.fragment:
        raise ValueError('Use a base URL without credentials, query parameters or fragments.')
    if not model:
        raise ValueError('Enter a model ID.')
    if '\n' in api_key or '\r' in api_key:
        raise ValueError('Enter an API key on a single line.')
    base_url = base_url.rstrip('/')
    with _transaction() as conn:
        if model_id is None:
            if not api_key:
                raise ValueError('Enter an API key.')
            cursor = conn.execute("""INSERT INTO llm_external_models
                (provider, base_url, model, api_key) VALUES (?, ?, ?, ?)""",
                                  (provider, base_url, model, api_key))
            return cursor.lastrowid
        cursor = conn.execute("""UPDATE llm_external_models
            SET provider = ?, base_url = ?, model = ?,
                api_key = CASE WHEN ? = '' THEN api_key ELSE ? END WHERE id = ?""",
                              (provider, base_url, model, api_key, api_key, model_id))
        if not cursor.rowcount:
            raise ValueError('External model no longer exists.')
        return model_id


def get_selection():
    """Return the current model name and optional external configuration ID."""
    with closing(db.get_db()) as conn:
        row = conn.execute("""SELECT COALESCE(m.model, s.local_model), s.external_id
            FROM llm_selection s LEFT JOIN llm_external_models m ON m.id = s.external_id
            WHERE s.id = 1""").fetchone()
        return {'current_model': row[0], 'current_external_id': row[1]}


def select_model(name='', external_id=None):
    """Persist a local or external selection."""
    with _transaction() as conn:
        if external_id is not None and not conn.execute(
                'SELECT 1 FROM llm_external_models WHERE id = ?', (external_id,)).fetchone():
            raise ValueError('External model no longer exists.')
        conn.execute('UPDATE llm_selection SET local_model = ?, external_id = ? WHERE id = 1',
                     (name if external_id is None else '', external_id))


def delete_model(model_id):
    """Remove a saved model and clear its selection atomically."""
    with _transaction() as conn:
        conn.execute("""UPDATE llm_selection SET external_id = NULL, local_model = ''
            WHERE external_id = ?""", (model_id,))
        conn.execute('DELETE FROM llm_external_models WHERE id = ?', (model_id,))
