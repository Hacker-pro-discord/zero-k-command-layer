"""Plot every case without extending a defeated team's curve beyond match end."""
import argparse
import json
import math
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot(directory):
    cases=json.loads((directory/'analysis.json').read_text(encoding='utf-8'))
    maps=list(dict.fromkeys(c['map'] for c in cases))
    datasets={c['case']:[json.loads(v) for v in (directory/(c['case']+'.jsonl')).read_text(encoding='utf-8').splitlines()] for c in cases}
    for field,title,ylabel in [('armyValue','Army value','Nominal metal x build completion'),('metalIncome','Metal income','Metal / game second'),('mexes','Mex control proxy','Owned mex frames'),('coverage','Player-perspective coverage','Fraction of sampled cells')]:
        fig,axes=plt.subplots(math.ceil(len(maps)/2),2,figsize=(13,3.4*math.ceil(len(maps)/2)),squeeze=False,sharex=True)
        for ax,name in zip(axes.flat,maps):
            for case in [c for c in cases if c['map']==name]:
                es=datasets[case['case']]
                if field=='coverage':
                    values=[e for e in es if e['kind']=='CLIENT']
                    for key,color in [('los','#1874ac'),('explored','#35814e'),('scoutVisited','#c58116')]:
                        ax.plot([v['time']/60 for v in values],[v.get(key,0) for v in values],color=color,alpha=.55,lw=1)
                    ax.set_ylim(0,1)
                else:
                    for team,color in [(0,'#1874ac'),(1,'#b44543')]:
                        values=[e for e in es if e['kind']=='METRIC' and e['team']==team]
                        ax.plot([v['time']/60 for v in values],[v.get(field,0) for v in values],color=color,alpha=.55,lw=1)
                    ax.set_ylim(bottom=0)
            if field!='coverage': ax.autoscale(axis='y'); ax.set_ylim(bottom=0)
            ax.set_title(name,fontsize=10);ax.set_xlim(0,20);ax.grid(alpha=.18);ax.set_xlabel('Game minutes');ax.set_ylabel(ylabel,fontsize=8)
        for ax in list(axes.flat)[len(maps):]: ax.set_visible(False)
        from matplotlib.lines import Line2D
        entries=[('Current LOS','#1874ac'),('Ever observed','#35814e'),('Scout-detachment visits','#c58116')] if field=='coverage' else [('Officer','#1874ac'),('Circuit Brutal','#b44543')]
        fig.legend([Line2D([0],[0],color=c) for _,c in entries],[s for s,_ in entries],loc='upper center',bbox_to_anchor=(.5,.965),ncol=len(entries),frameon=False)
        fig.suptitle(f'{directory.name}: {title}',fontsize=16,y=.995)
        fig.text(.5,.01,'One trace per case; curves stop at match end. Mex counts include construction frames. Coverage uses a 16x16 grid.',ha='center',fontsize=8)
        fig.tight_layout(rect=(0,.025,1,.94));fig.savefig(directory/f'curves_{field}.png',dpi=135);plt.close(fig)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);a=p.parse_args();plot(a.directory)
