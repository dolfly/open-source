#!/usr/bin/env bash
# sync_status.sh — 双向同步 Multica issue 与 GitHub issue 的状态
#
# 用法: ./scripts/sync_status.sh
# 约定: 通过 Multica issue 的 metadata(github_issue) 编号关联两侧。
#   Multica done/cancelled  -> GitHub closed
#   Multica 其他状态         -> GitHub open
#   GitHub closed            -> Multica done（仅在当前非终态时回写）
# 依赖: gh 已登录；multica CLI 可用。
set -euo pipefail

REPO="dolfly/open-source"
TMP=$(mktemp)
multica issue list --output json > "$TMP"

python3 - "$REPO" "$TMP" <<'PY'
import json,sys,subprocess
repo,tmp=sys.argv[1],sys.argv[2]
data=json.load(open(tmp))
DONE={'done','cancelled'}
for it in data['issues']:
    md=it.get('metadata') or {}
    ghn=md.get('github_issue')
    if not ghn:
        continue
    mstatus=it['status']
    r=subprocess.run(["gh","issue","view",str(ghn),"--repo",repo,"--json","state"],
                     capture_output=True,text=True)
    if r.returncode!=0:
        print(f"skip {it['id']} gh#{ghn}: 无法读取"); continue
    gstate=json.loads(r.stdout)['state']
    if mstatus in DONE and gstate!='CLOSED':
        subprocess.run(["gh","issue","close",str(ghn),"--repo",repo],capture_output=True)
        print(f"multica {it['id']}({mstatus}) -> close github #{ghn}")
    elif mstatus not in DONE and gstate=='CLOSED':
        subprocess.run(["gh","issue","reopen",str(ghn),"--repo",repo],capture_output=True)
        print(f"multica {it['id']}({mstatus}) -> reopen github #{ghn}")
    if gstate=='CLOSED' and mstatus not in DONE:
        subprocess.run(["multica","issue","status",it['id'],"done"],capture_output=True)
        print(f"github #{ghn}(closed) -> multica {it['id']} = done")
PY
rm -f "$TMP"
echo "sync_status 完成"
