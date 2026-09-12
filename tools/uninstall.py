"""Remove only unchanged files belonging to this local widget package."""
from pathlib import Path
import argparse
import hashlib

p = argparse.ArgumentParser()
p.add_argument('--game', default=r'C:\common_attachment\Steam\steamapps\common\Zero-K')
p.add_argument('--dry-run', action='store_true')
a = p.parse_args()
root = Path(__file__).resolve().parents[1]
target = Path(a.game).resolve()
if not (target / 'games/zk-stable.sdz').is_file():
    raise SystemExit('Not the verified Zero-K data directory')
for src in (root / 'LuaUI/Widgets').rglob('*.lua'):
    dest = (target / src.relative_to(root)).resolve()
    if not dest.is_relative_to(target):
        raise SystemExit('Refusing path outside game directory')
    if not dest.exists():
        continue
    if hashlib.sha256(src.read_bytes()).digest() != hashlib.sha256(dest.read_bytes()).digest():
        print('Retained modified file:', dest)
        continue
    print('Would remove:' if a.dry_run else 'Removing:', dest)
    if not a.dry_run:
        dest.unlink()
print('Unrelated widgets and native configuration retained.')
