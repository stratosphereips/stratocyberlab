"""Validate chat attachments and format them as provider-neutral text."""

from datetime import datetime
import json
from pathlib import Path

import db

DEFAULT_TERMINAL_LINES = 100
DEFAULT_TERMINAL_BYTES = 10_000
MAX_TERMINAL_BYTES = 10_000_000
MAX_CHALLENGE_FILE_BYTES = 10_000


def _challenge_reference(message):
    """Validate the opt-in and keep only the registered challenge identifier."""
    enabled = message['include_challenge_context']
    if message['role'] != 'user' or not isinstance(enabled, bool):
        raise ValueError('Only user messages can have a boolean challenge context option.')
    if not enabled:
        return {'include_challenge_context': False}
    challenge_id = message.get('challenge_id')
    if not isinstance(challenge_id, str) or not challenge_id:
        raise ValueError('Challenge context requires a challenge ID.')
    return {'include_challenge_context': True, 'challenge_id': challenge_id}


def _challenge_context(challenge_id):
    """Read fixed files from a registered directory, without executing scripts."""
    directory = db.get_challenge_dir(challenge_id)
    if not directory:
        raise ValueError('This challenge does not exist.')
    root = Path(directory).resolve()
    files = {}
    # Existing exercises use README.md; also accept the lowercase spelling.
    for filename in ('meta.json', 'README.md', 'readme.md', 'auto-solve.sh'):
        if filename == 'readme.md' and 'README.md' in files:
            continue
        path = root / filename
        if not path.resolve().is_relative_to(root):
            raise ValueError('Challenge context files must stay inside the challenge directory.')
        if path.exists() and not path.is_file():
            raise ValueError('Challenge context must use regular files.')
        try:
            with path.open('rb') as source:
                content = source.read(MAX_CHALLENGE_FILE_BYTES + 1)
        except FileNotFoundError:
            continue
        if len(content) > MAX_CHALLENGE_FILE_BYTES:
            raise ValueError('Challenge context file exceeds the 10 KB limit.')
        files[filename] = content.decode('utf-8', errors='replace')
    return {'challenge_id': challenge_id, 'files': files}


def _terminal_context(context):
    if not isinstance(context, dict):
        raise ValueError('Expected a terminal snapshot object.')
    text = context.get('text')
    captured_at = context.get('captured_at')
    truncated = context.get('truncated')
    if not isinstance(text, str) or not text or not isinstance(truncated, bool):
        raise ValueError('Invalid terminal snapshot text or truncation flag.')
    if len(text.encode('utf-8')) > MAX_TERMINAL_BYTES:
        raise ValueError('Terminal snapshots must fit within 10 MB (10,000,000 UTF-8 bytes).')
    if not isinstance(captured_at, str) or len(captured_at) > 64:
        raise ValueError('Invalid terminal snapshot timestamp.')
    try:
        timestamp = datetime.fromisoformat(captured_at.replace('Z', '+00:00'))
        if timestamp.tzinfo is None:
            raise ValueError('Missing timezone')
    except ValueError:
        raise ValueError('Invalid terminal snapshot timestamp.') from None
    return {'text': text, 'captured_at': captured_at, 'truncated': truncated}


def normalize_messages(messages):
    """Copy validated messages, retaining immutable user snapshot attachments."""
    if not isinstance(messages, list):
        raise ValueError('Expected a list of text chat messages.')
    history = []
    for message in messages:
        if (not isinstance(message, dict) or message.get('role') not in ('user', 'assistant')
                or not isinstance(message.get('content'), str)):
            raise ValueError('Expected a list of text chat messages.')
        item = {'role': message['role'], 'content': message['content']}
        if 'include_challenge_context' in message:
            item.update(_challenge_reference(message))
        if 'terminal_context' in message:
            if message['role'] != 'user':
                raise ValueError('Only user messages can have terminal snapshots.')
            item['terminal_context'] = _terminal_context(message['terminal_context'])
        history.append(item)
    return history


def provider_messages(history):
    """Keep context in its original user turn, never in a system message."""
    messages = []
    challenges = {}
    for message in history:
        content = message['content']
        if 'terminal_context' in message:
            # JSON quotes the terminal text, including any apparent delimiters.
            snapshot = json.dumps(message['terminal_context'], ensure_ascii=False)
            content = (f'Terminal snapshot (JSON-encoded diagnostic data):\n{snapshot}'
                       f'\n\nUser question:\n{content}')
        if message.get('include_challenge_context'):
            challenge_id = message['challenge_id']
            if challenge_id not in challenges:
                challenges[challenge_id] = _challenge_context(challenge_id)
            context = json.dumps(challenges[challenge_id], ensure_ascii=False)
            content = (f'Challenge context (JSON-encoded instructor reference data):\n{context}'
                       f'\n\n{content}')
        messages.append({'role': message['role'], 'content': content})
    return messages
