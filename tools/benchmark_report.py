"""Offline analysis; never connects scorekeeper data to the running Officer."""
import argparse
import collections
import csv
import json
from pathlib import Path
from benchmark import summarize

def analyze(directory, output):
    output.mkdir(parents=True, exist_ok=True)
    rows=[]; details=[]
    for path in sorted(directory.glob('*/summary.json')):
        old=json.loads(path.read_text(encoding='utf-8'))
        case=json.loads((path.parent/'case.json').read_text(encoding='utf-8'))
        s=summarize(path.parent,case,old['wallSeconds'],old['outcome']=='HARNESS_TIMEOUT')
        if old['outcome'].startswith('ABORTED'): s['outcome']=old['outcome']; s['abortReason']=old.get('abortReason',''); path.write_text(json.dumps(s,indent=2),encoding='utf-8')
        events=[json.loads(line) for line in (path.parent/'events.jsonl').read_text(encoding='utf-8').splitlines() if line]
        clients=[e for e in events if e['kind']=='CLIENT']; metrics=[e for e in events if e['kind']=='METRIC']
        own=s['final'].get('0',{}); enemy=s['final'].get('1',{})
        states=collections.Counter(e.get('state','UNASSIGNED') for e in clients)
        defense=collections.Counter(e.get('defense','NONE') for e in clients)
        lost=collections.Counter()
        for e in events:
            if e['kind']=='LOSS' and e.get('team')==0: lost[e['unit']]+=e['value']
        notes=[]
        if s['outcome']=='INVALID': notes.append('Harness/controller invalid: '+ '; '.join(s['errors'])[:400])
        if s['outcome']=='CENSORED': notes.append('No native winner before the game-time cap.')
        if own.get('metalIncome',0)<enemy.get('metalIncome',0)*.6: notes.append('Final income below 60% of opponent; expansion survival/capture deficit.')
        if own.get('armyValue',0)<enemy.get('armyValue',0)*.5: notes.append('Final combat value below half of opponent.')
        if own.get('lost',0)>own.get('killed',0)*2: notes.append('Lost more than twice attributed killed value; inspect engagements and builder exposure.')
        if own.get('metal',0)>1000: notes.append('Over 1,000 metal stored at end; spending/build-capacity bottleneck suspected.')
        if sum(v for k,v in defense.items() if k in ('DEFENDING','RECOVERING','ESCORTING RECOVERY'))>len(clients)*.6: notes.append('Defense/recovery occupied over 60% of samples; possible response saturation.')
        first_army=next((e['time'] for e in metrics if e['team']==0 and e['army']>=5),None)
        row=dict(case=s['id'],map=s['map'],side=s['side'],factory=s['factory'],outcome=s['outcome'],seconds=round(s['gameSeconds'],1),killed=round(own.get('killed',0)),lost=round(own.get('lost',0)),ownIncome=round(own.get('metalIncome',0),1),enemyIncome=round(enemy.get('metalIncome',0),1),ownMex=own.get('mexes',0),enemyMex=enemy.get('mexes',0),ownArmyValue=round(own.get('armyValue',0)),enemyArmyValue=round(enemy.get('armyValue',0)),firstFiveCreatedSeconds=first_army,firstFiveReadySeconds=next((e['time'] for e in clients if e.get('readyArmy',0)>=5),None),explored=max((e.get('explored',0) for e in clients),default=0),scoutVisited=max((e.get('scoutVisited',0) for e in clients),default=0))
        rows.append(row)
        decisions=[e for e in events if e['kind']=='OFFICER_EVENT']
        checkpoints={}
        for second in (120,300,600,900,1200):
            if s['gameSeconds'] < second: continue
            checkpoints[str(second)]={str(team):next((e for e in reversed(metrics) if e['team']==team and e['time']<=second+1),{}) for team in (0,1)}
        own_curve=[e for e in metrics if e['team']==0]
        peaks={key:max((e.get(key,0) for e in own_curve),default=0) for key in ('armyValue','army','mexes','metalIncome','factories','builders')}
        detail=dict(row,diagnosticIndicators=notes,states=dict(states),defenseStates=dict(defense),lossesByUnit=dict(lost),decisionCounts=dict(collections.Counter(e['category'] for e in decisions)),checkpoints=checkpoints,ownPeaks=peaks,finalOwn=own,finalEnemy=enemy)
        details.append(detail)
        # Preserve all curves/decisions, including legitimate player telemetry and offline score data.
        (output/(s['id']+'.jsonl')).write_text('\n'.join(json.dumps(e) for e in events)+'\n',encoding='utf-8')
    (output/'analysis.json').write_text(json.dumps(details,indent=2),encoding='utf-8')
    if rows:
        with (output/'matches.csv').open('w',newline='',encoding='utf-8') as f:
            w=csv.DictWriter(f,fieldnames=rows[0].keys());w.writeheader();w.writerows(rows)
    counts=collections.Counter(r['outcome'] for r in rows)
    lines=['# Benchmark results', '',f'Completed cases: {len(rows)}. Outcomes: {dict(counts)}.', '', 'Diagnostic indicators below are hypotheses from telemetry, not proven causal explanations. Time limits are censored, not wins.', '', '[Match table](matches.csv) · [Detailed analysis](analysis.json). Plot files, when generated: army, income, mexes and coverage.', '', '| Map / factory / side | Result | Killed / lost | Final mexes (ours/enemy) |', '|---|---|---:|---:|']
    for r in rows: lines.append(f"| {r['map']} / {r['factory']} / {r['side']} | {r['outcome']} | {r['killed']} / {r['lost']} | {r['ownMex']}/{r['enemyMex']} |")
    for d in details:
        lines.extend(['',f"## {d['case']}",'', ' '.join(d['diagnosticIndicators']) or 'No automatic diagnostic flag; review the full timeline.', '', f"Largest own losses by unit value: {sorted(d['lossesByUnit'].items(),key=lambda v:-v[1])[:5]}."])
        five=d['checkpoints'].get('300')
        if five:
            a,z=five['0'],five['1']
            lines.extend(['',f"At five minutes: income {a.get('metalIncome',0):.1f}/{z.get('metalIncome',0):.1f}, mexes {a.get('mexes',0)}/{z.get('mexes',0)}, combat value {a.get('armyValue',0):.0f}/{z.get('armyValue',0):.0f} (ours/opponent)."])
        lines.extend(['',f"Own peak mexes: {d['ownPeaks']['mexes']}; peak combat value: {d['ownPeaks']['armyValue']:.0f}. Full timestamped Officer messages are retained as OFFICER_EVENT records in the case JSONL."])
    (output/'REPORT.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print(dict(counts),flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);p.add_argument('output',type=Path);a=p.parse_args();analyze(a.directory,a.output)
