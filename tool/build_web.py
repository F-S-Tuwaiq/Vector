#!/usr/bin/env python3

import base64
import json
from pathlib import Path
import subprocess
import sys
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]

def validate_config(path):
    values = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        key, separator, value = line.partition('=')
        if not separator:
            raise ValueError('Invalid .env entry')
        values[key.strip()] = value.strip().strip('\"\'')
    if set(values) != {'SUPABASE_URL', 'SUPABASE_ANON_KEY'}:
        raise ValueError('The web .env must contain only the two public Supabase settings')
    url = urlparse(values['SUPABASE_URL'])
    if url.scheme != 'https' or not url.hostname or 'PASTE_' in values['SUPABASE_URL']:
        raise ValueError('Set a real HTTPS SUPABASE_URL before building')
    key = values['SUPABASE_ANON_KEY']
    if key.startswith('sb_publishable_') and len(key) > len('sb_publishable_'):
        return
    try:
        payload = key.split('.')[1]
        claims = json.loads(base64.urlsafe_b64decode(payload + '=' * (-len(payload) % 4)))
    except (IndexError, ValueError):
        raise ValueError('Set a public Supabase anon or publishable key before building') from None
    if claims.get('role') != 'anon':
        raise ValueError('Only a public anon key may be included in a web build')

if __name__ == '__main__':
    try:
        validate_config(ROOT / '.env')
    except (OSError, ValueError) as error:
        sys.exit(f'Web build stopped: {error}')
    subprocess.run(
        ['flutter', 'build', 'web', '--release', '--base-href', '/Vector/'],
        cwd=ROOT, check=True,
    )
    validate_config(ROOT / 'build/web/assets/.env')
    (ROOT / 'build/web/.nojekyll').touch()
