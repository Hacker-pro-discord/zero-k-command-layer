"""Compare frozen campaigns without treating caps as wins or filling missing matches."""
import argparse
import collections
import csv
import json
import statistics
from pathlib import Path


def compare(baseline, candidate, output):
    before = {r['case']: r for r in json.loads((baseline/'analysis.json').read_text(encoding='utf-8'))}
    after = {r['case']: r for r in json.loads((candidate/'analysis.json').read_text(encoding='utf-8'))}
    output.mkdir(parents=True, exist_ok=True)
    rows = []
    for key in sorted(before.keys() | after.keys()):
        row = {'case': key}
        for label, source in (('baseline', before), ('candidate', after)):
            r = source.get(key)
            row[label+'Outcome'] = r['outcome'] if r else 'NOT_RUN'
            row[label+'Seconds'] = r['seconds'] if r else None
            row[label+'Trade'] = r['killed']/r['lost'] if r and r['lost'] else None
            for metric in ('explored', 'scoutVisited', 'firstFiveReadySeconds'):
                row[label+metric[0].upper()+metric[1:]] = r.get(metric) if r else None
            checkpoint = r.get('checkpoints', {}).get('300', {}) if r else {}
            ours, enemy = checkpoint.get('0', {}), checkpoint.get('1', {})
            row[label+'IncomeRatio300'] = ours['metalIncome']/enemy['metalIncome'] if enemy.get('metalIncome') else None
            row[label+'Mexes300'] = ours.get('mexes')
        rows.append(row)
    if rows:
        with (output/'paired.csv').open('w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=rows[0]); writer.writeheader(); writer.writerows(rows)
    lines = ['# Frozen training comparison', '',
             'These are paired scenarios, not identical opponent decisions: Circuit internal randomness is uncontrolled. Caps are censored. No missing case or post-defeat interval is imputed.', '',
             '| Phase | Completed | Outcomes | Median nominal killed/lost | Median income ratio at 300s |',
             '|---|---:|---|---:|---:|']
    for label, source in (('baseline', before), ('candidate', after)):
        valid = [r for r in rows if r[label+'Outcome'] in ('WIN', 'LOSS', 'DRAW', 'CENSORED')]
        def median(key):
            values = [r[label+key] for r in valid if r[label+key] is not None]
            return f'{statistics.median(values):.2f}' if values else 'unavailable'
        lines.append(f"| {label} | {len(source)} | {dict(collections.Counter(r['outcome'] for r in source.values()))} | {median('Trade')} | {median('IncomeRatio300')} |")
    lines += ['', 'Nominal losses include unfinished unit frames; this is not exact resource expenditure. Five-minute income ratios include only games still running then. Medians summarize this sample and do not establish statistical significance.', '',
              '[Every paired scenario](paired.csv). Detailed phase reports retain curves, checkpoints, compositions, losses and timestamped decisions.']
    (output/'COMPARISON.md').write_text('\n'.join(lines)+'\n', encoding='utf-8')


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('baseline', 'candidate', 'output'): p.add_argument(name, type=Path)
    a = p.parse_args(); compare(a.baseline, a.candidate, a.output)
