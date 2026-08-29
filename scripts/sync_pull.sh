#!/usr/bin/env bash
# sync_pull.sh — 将 GitHub Issue 状态变更回写到 Multica issue
#
# 用法: ./scripts/sync_pull.sh
# 说明: 遍历 dolfly/open-source 中带 "心路历程" 标签的 Issue，
#       按 Multica issue metadata(github_issue) 编号匹配，
#       将已关闭的 GitHub Issue 对应 Multica issue 置为 done。
# 依赖: gh 已登录；multica CLI 可用。
set -euo pipefail

REPO="dolfly/open-source"

gh issue list --repo "$REPO" --label "心路历程" --state all --limit 200 --json number,state,title 2>/dev/null | python3 - "$REPO" <<'PY'
import json,sys,subprocess
repo=sys.argv[1]
issues=json.load(sys.stdin)
for it in issues:
    num=it['number']; state=it['state']
    # 找到 metadata.github_issue == num 的 multica issue
    out=subprocess.run(["multica","issue","list","--output","json"],
                       capture_output=True,text=True).stdout
    try:
        all_issues=json.load(__import__('io').StringIO(out))
    except Exception:
        all_issues=[]
    for mi in all_issues:
        md=mi.get('metadata') or {}
        if str(md.get('github_issue',''))==str(num):
            new_status="done" if state=="CLOSED" else "in_review"
            subprocess.run(["multica","issue","status",mi['id'],new_status],
                           capture_output=True)
            print(f"github #{num} ({state}) -> multica {mi['id']} = {new_status}")
PY
echo "sync_pull 完成"
