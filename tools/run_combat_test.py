"""Launch a separate equal-army Zero-K test; never edits stock archives or an existing session."""
import argparse
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory', type=Path, required=True, help='Separate test data directory')
p.add_argument('--game', type=Path, required=True)
p.add_argument('--headless', action='store_true')
p.add_argument('--seconds', type=int, default=120)
p.add_argument('--production', action='store_true', help='Production smoke variant; adds an own factory, not an equal-army benchmark')
p.add_argument('--stress', action='store_true', help='400 units per side and four production factories; not an equal-army benchmark')
p.add_argument('--early-five', action='store_true', help='Five-unit early advance; controlled damage at 30s and healing at 50s, passive enemy')
p.add_argument('--cover-retreat', action='store_true', help='Ten mixed units, controlled mixed injuries at 30s, passive enemy')
p.add_argument('--map-control', action='store_true', help='Automatic map-wide startup against a scripted opponent')
p.add_argument('--thousand', action='store_true', help='1,000 units per side with four factories')
p.add_argument('--startup', action='store_true', help='Start with zero combat units, four factories, and use autonomous startup')
a = p.parse_args()
a.stress = a.stress or a.thousand
assert 30 <= a.seconds <= 600
root = Path(__file__).resolve().parents[1]
target = a.directory.resolve()
assert target != a.game.resolve() and a.game.resolve() not in target.parents, 'Use a separate directory outside the installed game'
assert (a.game/'games/zk-stable.sdz').exists()
mutator = target/'games/command_layer_combat.sdd'
(mutator/'LuaRules/Gadgets').mkdir(parents=True, exist_ok=True)
(mutator/'modinfo.lua').write_text("return {name='Command Layer Equal Armies Test',shortName='ZK',version='1',game='Zero-K',shortGame='ZK',mutator='1',modtype=1,depend={'Zero-K v1.14.8.0'}}", encoding='utf-8')
shutil.copyfile(root/'tests/combat_fixture.lua', mutator/'LuaRules/Gadgets/command_layer_fixture.lua')
shutil.copytree(root/'LuaUI', target/'LuaUI', dirs_exist_ok=True)
shutil.copyfile(root/'tests/combat_driver.lua', target/'LuaUI/Widgets/gui_command_layer_combat_qa.lua')
(target/'LuaUI/Config').mkdir(exist_ok=True)
config = target/'LuaUI/Config/ZK_data.lua'
if not config.exists():
    config.write_text('return {["Local Widgets Config"]={useLocalWidgets=true,useLocalWidgetsFirst=true}}', encoding='utf-8')
settings = target/'springsettings.cfg'
if not settings.exists():
    settings.write_text(f'SpringData = {a.game.as_posix()}\nLuaUI = 1\nSound = 0\nFullscreen = 0\nXResolutionWindowed = 1600\nYResolutionWindowed = 1000\n', encoding='utf-8')
with socket.socket() as s:
    s.bind(('127.0.0.1', 0))
    port = s.getsockname()[1]
script = f'''[GAME] {{
MapName=Absolution 2; GameType=Command Layer Equal Armies Test 1;
IsHost=1; MyPlayerName=CommandLayerCombatTest; StartPosType=0; HostIP=127.0.0.1; HostPort={port}; NumPlayers=1;
[PLAYER0] {{Name=CommandLayerCombatTest; Team=0; Spectator=0;}}
[TEAM0] {{TeamLeader=0; AllyTeam=0; RGBColor=0.2 0.6 1; Side=Random;}}
[TEAM1] {{TeamLeader=0; AllyTeam=1; RGBColor=1 0.3 0.2; Side=Random;}}
[ALLYTEAM0] {{NumAllies=0;}} [ALLYTEAM1] {{NumAllies=0;}}
[AI0] {{Name=ScriptedFightOpponent; ShortName=NullAI; Version=0.1; Team=1; Host=0;}}
[MODOPTIONS] {{startmetal=5000; startenergy=5000; cl_test_duration={a.seconds}; cl_test_exit={int(a.headless)}; cl_test_production={int(a.production or a.stress or a.startup)}; cl_test_stress={int(a.stress)}; cl_test_thousand={int(a.thousand)}; cl_test_startup={int(a.startup)}; cl_test_mapcontrol={int(a.map_control)}; cl_test_early={int(a.early_five or a.cover_retreat)}; cl_test_cover={int(a.cover_retreat)};}}
}}'''
(target/'test.txt').write_text(script, encoding='utf-8')
engine = a.game/'engine/win64/2025.06.21'/('spring-headless.exe' if a.headless else 'spring.exe')
args = [str(engine), '--write-dir', str(target), '--config', str(settings), str(target/'test.txt')]
process = subprocess.Popen(args, cwd=target, creationflags=subprocess.CREATE_NO_WINDOW if a.headless and os.name=='nt' else 0)
(target/'launch.json').write_text(json.dumps({'pid': process.pid, 'seconds': a.seconds, 'headless': a.headless}, indent=2), encoding='utf-8')
print(f'New test PID {process.pid}; logs: {target / "infolog.txt"}')
