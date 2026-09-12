"""Copy only this project's uniquely named local widget files; never stock files."""
from pathlib import Path
import argparse, shutil
p=argparse.ArgumentParser(); p.add_argument('--game',default=r'C:\common_attachment\Steam\steamapps\common\Zero-K'); a=p.parse_args()
root=Path(__file__).resolve().parents[1]; target=Path(a.game).resolve()
assert (target/'games/zk-stable.sdz').exists(), 'Not the verified Zero-K data directory'
for f in (root/'LuaUI/Widgets').rglob('*.lua'):
    rel=f.relative_to(root); dest=target/rel
    assert f.name=='gui_command_layer.lua' or 'CommandLayer' in rel.parts
    dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(f,dest)
print('Installed local Command Layer files only:',target/'LuaUI/Widgets/gui_command_layer.lua')
