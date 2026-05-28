#!/usr/bin/env python3
import json
import os
import subprocess
from collections import defaultdict, OrderedDict

REPORT_DIR = 'reports'
os.makedirs(REPORT_DIR, exist_ok=True)

def load_json(path):
    b = open(path,'rb').read()
    for enc in ('utf-8','utf-16','utf-16-le'):
        try:
            return json.loads(b.decode(enc))
        except Exception:
            pass
    raise RuntimeError('Failed to decode JSON')

data = load_json('gitinspector_report.json')

def write_md(path, title, headers, rows):
    with open(path,'w',encoding='utf-8') as f:
        f.write(f'# {title}\n\n')
        f.write('| ' + ' | '.join(headers) + ' |\n')
        f.write('| ' + ' | '.join(['---']*len(headers)) + ' |\n')
        for r in rows:
            f.write('| ' + ' | '.join(str(x) for x in r) + ' |\n')

# 1) Individual Contribution Summary
authors = []
if 'authors' in data:
    for a in data['authors']:
        name = a.get('name') or a.get('author')
        commits = a.get('commits',0)
        added = a.get('added',0)
        removed = a.get('removed',0)
        files = a.get('files',0)
        contrib = a.get('contribution', '')
        authors.append((name, commits, added, removed, files, contrib))
else:
    # fallback: build from git log
    out = subprocess.check_output(['git','shortlog','-sne'], text=True, encoding='utf-8', errors='replace')
    for line in out.splitlines():
        parts = line.strip().split('\t')
        if len(parts)>=2:
            commits = parts[0].strip()
            name = parts[1].strip()
            authors.append((name, commits, '', '', '', ''))

# Enhance with LOC added/removed and files modified using git --numstat
def compute_loc_stats():
    stats = defaultdict(lambda: {'commits':0,'added':0,'removed':0,'files':set()})
    # use a stable separator to avoid formatting/wrapping issues
    cmd = ['git','log','--no-merges','--pretty=format:==COMMIT==%H%x01%an%x01%ae','--numstat']
    out = subprocess.check_output(cmd, text=True, encoding='utf-8', errors='replace')
    cur_author = None
    for line in out.splitlines():
        if line.startswith('==COMMIT=='):
            meta = line[len('==COMMIT=='):]
            parts = meta.split('\x01')
            if len(parts) >= 3:
                cur_author_name = parts[1]
                cur_author_email = parts[2]
                cur_author = cur_author_name
                stats[cur_author]['commits'] += 1
                # ensure combined key exists
                combined = f"{cur_author_name} <{cur_author_email}>"
                _ = stats[combined]
            continue
        # numstat lines: added \t removed \t file
        if cur_author and line.strip():
            parts = line.split('\t')
            if len(parts) >= 3:
                added_s, removed_s, fname = parts[0], parts[1], parts[2]
                try:
                    added = int(added_s)
                except:
                    added = 0
                try:
                    removed = int(removed_s)
                except:
                    removed = 0
                stats[cur_author]['added'] += added
                stats[cur_author]['removed'] += removed
                stats[cur_author]['files'].add(fname)
    return stats

loc_stats = compute_loc_stats()
with open(os.path.join(REPORT_DIR,'loc_stats_debug.txt'),'w',encoding='utf-8') as dbg:
    for k,v in loc_stats.items():
        dbg.write(f"KEY: {k} -> commits={v['commits']} added={v['added']} removed={v['removed']} files={len(v['files'])}\n")

new_authors = []
for a in authors:
    name = a[0]
    commits = a[1]
    added = a[2]
    removed = a[3]
    files = a[4]
    contrib = a[5]
    if isinstance(commits, str) and commits.isdigit():
        commits = int(commits)
    # try matching several key forms and pick the one with most commits
    short_name = name.split('<')[0].strip()
    email_form = name if '<' in name and '>' in name else None
    candidates = []
    for k in (short_name, name, email_form):
        if k and k in loc_stats:
            candidates.append((k, loc_stats[k]['commits']))
    chosen = None
    if candidates:
        # pick candidate with highest commits
        chosen = max(candidates, key=lambda x: x[1])[0]
    if chosen:
        added = loc_stats[chosen]['added']
        removed = loc_stats[chosen]['removed']
        files = len(loc_stats[chosen]['files'])
        commits = loc_stats[chosen]['commits']
    new_authors.append((name, commits, added, removed, files, contrib))
authors = new_authors

write_md(os.path.join(REPORT_DIR,'contribution_summary.md'), 'Individual Contribution Summary', ['Member','Commits','LOC Added','LOC Removed','Files Modified','Contribution %'], authors)

# 2) Contribution Timeline (per week)
timeline_rows = []
timeline_headers = ['Week']
if 'timeline' in data and data['timeline']:
    # timeline likely is list of periods with per-author counts
    periods = data['timeline']
    authors_order = []
    for p in periods:
        for k in p.get('changes',{}).keys():
            if k not in authors_order:
                authors_order.append(k)
    timeline_headers += authors_order + ['Notes']
    for idx,p in enumerate(periods, start=1):
        row = [f'Week {idx}']
        for a in authors_order:
            row.append(p.get('changes',{}).get(a,0))
        row.append('')
        timeline_rows.append(row)
else:
    # fallback: compute commits per week per author using ISO week (YYYY-Www)
    out = subprocess.check_output(['git','log','--no-merges','--date=format:%Y-W%V','--pretty=%ad%x09%an'], text=True, encoding='utf-8', errors='replace')
    weeks = OrderedDict()
    authors_set = []
    for line in out.splitlines():
        if '\t' not in line:
            continue
        week, author = line.split('\t',1)
        if author not in authors_set:
            authors_set.append(author)
        weeks.setdefault(week, defaultdict(int))[author]+=1
    timeline_headers += authors_set + ['Notes']
    for idx,(wk,v) in enumerate(weeks.items(), start=1):
        row = [wk]
        for a in authors_set:
            row.append(v.get(a,0))
        row.append('')
        timeline_rows.append(row)

write_md(os.path.join(REPORT_DIR,'contribution_timeline.md'), 'Contribution Timeline (Weekly)', timeline_headers, timeline_rows)

# 3) Code Ownership Map (responsibilities)
ownership_rows = []
if 'responsibilities' in data and data['responsibilities']:
    for entry in data['responsibilities']:
        path = entry.get('file') or entry.get('path')
        owner = entry.get('owner') or entry.get('author')
        percent = entry.get('ownership', '')
        notes = entry.get('notes','')
        ownership_rows.append((path, f"{owner} ({percent}%)" if percent else owner, notes))
else:
    # fallback: use git blame ownership per top-level folders
    folders = ['lib','assets']
    for folder in folders:
        try:
            out = subprocess.check_output(['git','ls-files',folder], text=True, encoding='utf-8', errors='replace')
        except subprocess.CalledProcessError:
            continue
        counts = defaultdict(int)
        total = 0
        for fpath in out.splitlines():
            bl = subprocess.check_output(['git','blame','--line-porcelain',fpath], text=True, encoding='utf-8', errors='replace')
            for l in bl.splitlines():
                if l.startswith('author '):
                    counts[l.split(' ',1)[1]]+=1
                    total+=1
        if total>0:
            top = max(counts.items(), key=lambda x:x[1])
            ownership_rows.append((f'/{folder}/', f'{top[0]} ({int(top[1]/total*100)}%)', ''))

write_md(os.path.join(REPORT_DIR,'code_ownership.md'), 'Code Ownership Map', ['File / Folder','Owner (%)','Notes'], ownership_rows)

# 4) Summary of Pull Requests (approx from merge commits)
prs = []
try:
    merges = subprocess.check_output(['git','log','--merges','--pretty=%H%x1f%an%x1f%s'], text=True, encoding='utf-8', errors='replace')
    for line in merges.splitlines():
        parts = line.split('\x1f')
        if len(parts)>=3:
            h, author, subject = parts[:3]
            prnum = ''
            import re
            m = re.search(r"#(\d+)", subject)
            if m:
                prnum = '#'+m.group(1)
            prs.append((prnum or h[:7], subject, author, '', ''))
except Exception:
    pass

write_md(os.path.join(REPORT_DIR,'pull_requests.md'), 'Summary of Pull Requests', ['PR #','Title','Author','Reviewer','Lines Changed'], prs)

print('Reports written to', REPORT_DIR)
