"""Reproducible normal-start Circuit Brutal campaign; isolated log-only scorekeeper."""
from __future__ import annotations
import argparse, concurrent.futures, hashlib, json, os, re, shutil, socket, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AI = '1052188CircuitAIBrutal64'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def records(path):
    result = []
    for line in path.read_text(encoding='utf-8', errors='replace').splitlines() if path.exists() else []:
        match = re.search(r'\[CL-BENCH-([A-Z_]+)\] (\{.*\})', line)
        if match:
            try: result.append({'kind': match[1], **json.loads(match[2])})
            except json.JSONDecodeError: pass
        officer = re.search(r'\[f=(-?\d+)\].*?\[CommandLayer\] ([A-Z_]+): (.*)', line)
        if officer:
            result.append({'kind': 'OFFICER_EVENT', 'time': max(0, int(officer[1])) / 30,
                           'category': officer[2], 'message': officer[3]})
    return result

def summarize(target, case, elapsed, timeout=False):
    data = records(target/'infolog.txt')
    text = (target/'infolog.txt').read_text(encoding='utf-8', errors='replace') if (target/'infolog.txt').exists() else ''
    results = [v for v in data if v['kind'] in ('RESULT','CLIENT_RESULT')]
    errors = [l for l in text.splitlines() if ('Error in ' in l and 'Shutdown' not in l) or ('Failed to load:' in l and any(w in l for w in ('gui_command_layer','gui_cl_benchmark'))) or any(t in l for t in ('Failed to load the Skirmish AI','error = 201','error 201','EVENT_INIT','failed to handle event'))]
    metrics = [v for v in data if v['kind']=='METRIC']
    if not any(v['kind']=='CLIENT' for v in data): errors.append('Missing player-perspective telemetry')
    if not any(v.get('team')==1 and v.get('army',0)+v.get('builders',0)+v.get('factories',0)>0 for v in metrics): errors.append('Enemy never became active')
    outcome = 'INVALID' if errors or not metrics else 'CENSORED'
    if results and outcome != 'INVALID':
        winners = results[0].get('winners', [])
        outcome = 'WIN' if case['side'] in winners else 'LOSS' if 1-case['side'] in winners else 'DRAW'
    if timeout: outcome = 'HARNESS_TIMEOUT'
    final = {str(v['team']):v for v in metrics}
    summary = dict(case, outcome=outcome, wallSeconds=elapsed, gameSeconds=max((v.get('time',0) for v in data),default=0), final=final, errors=errors)
    (target/'events.jsonl').write_text('\n'.join(json.dumps(v) for v in data)+'\n', encoding='utf-8')
    (target/'summary.json').write_text(json.dumps(summary,indent=2), encoding='utf-8')
    return summary

def run_case(case, args, snapshot):
    target=(args.directory/case['id']).resolve()
    if (target/'summary.json').exists() and not args.rerun:
        return json.loads((target/'summary.json').read_text())
    target.mkdir(parents=True, exist_ok=True)
    mutator=target/'games/command_layer_benchmark.sdd'
    (mutator/'LuaRules/Gadgets').mkdir(parents=True,exist_ok=True)
    (mutator/'modinfo.lua').write_text("return {name='Command Layer Benchmark',shortName='ZK',version='1',game='Zero-K',shortGame='ZK',modtype=1,depend={'Zero-K v1.14.8.0'}}",encoding='utf-8')
    shutil.copyfile(snapshot/'tests/benchmark_observer.lua',mutator/'LuaRules/Gadgets/cl_benchmark_observer.lua')
    shutil.copytree(snapshot/'LuaUI',target/'LuaUI',dirs_exist_ok=True)
    shutil.copyfile(snapshot/'tests/benchmark_driver.lua',target/'LuaUI/Widgets/gui_cl_benchmark_driver.lua')
    (target/'LuaUI/Config').mkdir(exist_ok=True)
    (target/'LuaUI/Config/ZK_data.lua').write_text('return {["Local Widgets Config"]={useLocalWidgets=true,useLocalWidgetsFirst=true}}',encoding='utf-8')
    settings=target/'springsettings.cfg'
    settings.write_text(f'SpringData = {args.game.as_posix()}\nLuaUI = 1\nSound = 0\nFullscreen = 0\n',encoding='utf-8')
    with socket.socket() as s: s.bind(('127.0.0.1',0)); port=s.getsockname()[1]
    a,b=case['starts'][case['side']],case['starts'][1-case['side']]
    script=f'''[GAME] {{
MapName={case['map']}; GameType=Command Layer Benchmark 1; IsHost=1; MyPlayerName=CommandLayerBenchmark;
StartPosType=3; FixedRNGSeed={case['seed']}; RecordDemo=1; HostIP=127.0.0.1; HostPort={port}; NumPlayers=1;
[PLAYER0] {{Name=CommandLayerBenchmark; Team=0; Spectator=0;}}
[TEAM0] {{TeamLeader=0; AllyTeam={case['side']}; Side=Random; RGBColor=0.2 0.6 1; StartPosX={a[0]}; StartPosZ={a[1]}; start_x={a[0]}; start_z={a[1]};}}
[TEAM1] {{TeamLeader=0; AllyTeam={1-case['side']}; Side=Random; RGBColor=1 0.3 0.2; StartPosX={b[0]}; StartPosZ={b[1]}; start_x={b[0]}; start_z={b[1]};}}
[ALLYTEAM0] {{NumAllies=0;}} [ALLYTEAM1] {{NumAllies=0;}}
[AI0] {{Name=CircuitBrutal; ShortName={args.ai}; Version=stable; Team=1; Host=0; [OPTIONS] {{cheating=0; ally_aware=1; comm_merge=1; disabledunits=; config_file=behaviour+block_map+build_chain+commander+economy+factory+response; profile=default;}} }}
[MODOPTIONS] {{fixedstartpos=1; setaispawns=0; shuffle=off; maxspeed={args.speed}; cl_bench_case={case['id']}; cl_bench_factory={case['factory']}; cl_bench_duration={args.seconds}; cl_bench_speed={args.speed};}}
}}'''
    (target/'test.txt').write_text(script,encoding='utf-8')
    (target/'case.json').write_text(json.dumps(case,indent=2),encoding='utf-8')
    engine=args.game/'engine/win64/2025.06.21/spring-headless.exe'
    started=time.monotonic()
    proc=subprocess.Popen([str(engine),'--write-dir',str(target),'--config',str(settings),str(target/'test.txt')],cwd=target,creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
    (target/'process.json').write_text(json.dumps({'pid':proc.pid}),encoding='utf-8')
    timeout=False
    try: proc.wait(timeout=args.wall_timeout)
    except subprocess.TimeoutExpired: timeout=True; proc.terminate(); proc.wait(timeout=30)
    summary=summarize(target,case,time.monotonic()-started,timeout)
    print(json.dumps({'case':case['id'],'outcome':summary['outcome'],'seconds':summary['gameSeconds']}),flush=True)
    return summary

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--game',type=Path,required=True); p.add_argument('--directory',type=Path,required=True)
    p.add_argument('--split',choices=['train','holdout'],default='train'); p.add_argument('--map-id'); p.add_argument('--case-limit',type=int)
    p.add_argument('--seconds',type=int,default=1200); p.add_argument('--speed',type=int,default=20); p.add_argument('--jobs',type=int,default=3)
    p.add_argument('--wall-timeout',type=int,default=1800); p.add_argument('--ai',default=AI); p.add_argument('--rerun',action='store_true')
    args=p.parse_args(); args.game=args.game.resolve(); args.directory=args.directory.resolve()
    assert args.directory!=args.game and args.game not in args.directory.parents
    assert 60<=args.seconds<=3600 and 1<=args.speed<=20 and 1<=args.jobs<=3
    maps=json.loads((ROOT/'tests/benchmark_maps.json').read_text())
    cases=[]
    for m in maps:
        if m['split']!=args.split or args.map_id and m['id']!=args.map_id: continue
        for factory in m['factories']:
            for side in [0,1]: cases.append(dict(m,id=f"{m['id']}-{factory}-s{side}",side=side,factory=factory,seed=1729+side+97*m['factories'].index(factory)))
    if args.case_limit: cases=cases[:args.case_limit]
    args.directory.mkdir(parents=True,exist_ok=True)
    snapshot=args.directory/'source'
    if not snapshot.exists():
        shutil.copytree(ROOT/'LuaUI',snapshot/'LuaUI'); (snapshot/'tests').mkdir()
        for name in ['benchmark_driver.lua','benchmark_observer.lua']: shutil.copyfile(ROOT/'tests'/name,snapshot/'tests'/name)
        metadata={'created':time.time(),'cases':cases,'seconds':args.seconds,'speed':args.speed,'ai':args.ai,'files':{str(f.relative_to(snapshot)):digest(f) for f in snapshot.rglob('*') if f.is_file()},'engineSha256':digest(args.game/'engine/win64/2025.06.21/spring-headless.exe'),'aiSha256':digest(args.game/'AI/Skirmish'/args.ai/'stable/SkirmishAI.dll'),'aiFiles':{str(f.relative_to(args.game/'AI/Skirmish'/args.ai)):digest(f) for f in (args.game/'AI/Skirmish'/args.ai).rglob('*') if f.is_file()}}
        (args.directory/'manifest.json').write_text(json.dumps(metadata,indent=2),encoding='utf-8')
    metadata=json.loads((args.directory/'manifest.json').read_text(encoding='utf-8'))
    if metadata['cases']!=cases or metadata['seconds']!=args.seconds or metadata['speed']!=args.speed or metadata['ai']!=args.ai:
        raise SystemExit('Existing campaign parameters differ; use a new directory')
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures=[pool.submit(run_case,c,args,snapshot) for c in cases]; results=[]
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result()); (args.directory/'results.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
    print('CAMPAIGN COMPLETE',len(results),flush=True)

if __name__=='__main__': main()
