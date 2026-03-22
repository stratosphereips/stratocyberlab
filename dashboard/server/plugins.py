import json
import os
from typing import Dict, List
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

REQUIRED_FILES = ('metadata.json', 'docker-compose.yml', 'README.md')
REQUIRED_METADATA_FIELDS = ('id', 'name', 'description', 'version')


def _build_empty_plugin(directory_name: str, plugin_dir: str) -> Dict:
    return {
        'id': directory_name,
        'name': directory_name,
        'description': '',
        'version': '',
        'ui_url': '',
        'dir': plugin_dir,
        'valid': False,
        'validation_errors': [],
    }


def _validate_metadata(plugin: Dict, metadata: Dict) -> None:
    for field in REQUIRED_METADATA_FIELDS:
        value = metadata.get(field)
        if not isinstance(value, str) or not value.strip():
            plugin['validation_errors'].append(f"metadata.json field '{field}' must be a non-empty string")

    metadata_id = metadata.get('id')
    if isinstance(metadata_id, str) and metadata_id and metadata_id != plugin['id']:
        plugin['id'] = metadata_id

    for field in ('name', 'description', 'version'):
        value = metadata.get(field)
        if isinstance(value, str) and value.strip():
            plugin[field] = value.strip()

    ui_url = metadata.get('ui_url')
    if ui_url is None:
        return

    if not isinstance(ui_url, str) or not ui_url.strip():
        plugin['validation_errors'].append("metadata.json field 'ui_url' must be a non-empty string when provided")
        return

    parsed = urlsplit(ui_url)
    if parsed.scheme not in ('http', 'https') or not parsed.netloc:
        plugin['validation_errors'].append("metadata.json field 'ui_url' must be a valid http(s) URL")
        return

    plugin['ui_url'] = ui_url.strip()


def discover_plugins(parent_dir: str) -> List[Dict]:
    discovered = []
    if not os.path.isdir(parent_dir):
        return discovered

    for directory_name in sorted(os.listdir(parent_dir)):
        plugin_dir = os.path.join(parent_dir, directory_name)
        if not os.path.isdir(plugin_dir):
            continue

        plugin = _build_empty_plugin(directory_name, plugin_dir)

        missing_files = [
            required_file
            for required_file in REQUIRED_FILES
            if not os.path.isfile(os.path.join(plugin_dir, required_file))
        ]
        for missing_file in missing_files:
            plugin['validation_errors'].append(f"missing required file '{missing_file}'")

        metadata_path = os.path.join(plugin_dir, 'metadata.json')
        if os.path.isfile(metadata_path):
            try:
                with open(metadata_path, 'r', encoding='utf8') as file:
                    metadata = json.load(file)
            except json.JSONDecodeError as exc:
                plugin['validation_errors'].append(f"metadata.json is not valid JSON: {exc.msg}")
            else:
                if not isinstance(metadata, dict):
                    plugin['validation_errors'].append('metadata.json must contain a JSON object')
                else:
                    _validate_metadata(plugin, metadata)

        plugin['valid'] = len(plugin['validation_errors']) == 0
        discovered.append(plugin)

    return discovered


def get_proxy_target(plugin: Dict, proxied_path: str, query_string: bytes) -> str:
    if not plugin or not plugin['valid'] or not plugin['ui_url']:
        return ''

    parsed = urlsplit(plugin['ui_url'])
    base_path = parsed.path or '/'
    relative_path = proxied_path.lstrip('/')
    if relative_path:
        upstream_path = f"{base_path.rstrip('/')}/{relative_path}"
    else:
        upstream_path = base_path

    query = urlencode(parse_qsl(query_string.decode('utf8'), keep_blank_values=True))
    return urlunsplit((parsed.scheme, parsed.netloc, upstream_path, query, ''))
