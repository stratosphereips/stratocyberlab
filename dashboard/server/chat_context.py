"""Validate chat attachments and format them as provider-neutral text."""

from datetime import datetime
import json

MAX_TERMINAL_LINES = 100
MAX_TERMINAL_BYTES = 10000


def _terminal_context(context):
    if not isinstance(context, dict):
        raise ValueError('Expected a terminal snapshot object.')
    text = context.get('text')
    captured_at = context.get('captured_at')
    truncated = context.get('truncated')
    if not isinstance(text, str) or not text or not isinstance(truncated, bool):
        raise ValueError('Invalid terminal snapshot text or truncation flag.')
    if len(text.split('\n')) > MAX_TERMINAL_LINES or len(text.encode('utf-8')) > MAX_TERMINAL_BYTES:
        raise ValueError('Terminal snapshots must fit within 100 lines and 10,000 UTF-8 bytes.')
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
        if 'terminal_context' in message:
            if message['role'] != 'user':
                raise ValueError('Only user messages can have terminal snapshots.')
            item['terminal_context'] = _terminal_context(message['terminal_context'])
        history.append(item)
    return history


def provider_messages(history):
    """Keep snapshots in their original user turn, never in a system message."""
    messages = []
    for message in history:
        content = message['content']
        if 'terminal_context' in message:
            # JSON quotes the terminal text, including any apparent delimiters.
            snapshot = json.dumps(message['terminal_context'], ensure_ascii=False)
            content = (f'Terminal snapshot (JSON-encoded diagnostic data):\n{snapshot}'
                       f'\n\nUser question:\n{content}')
        messages.append({'role': message['role'], 'content': content})
    return messages
