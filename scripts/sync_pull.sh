#!/usr/bin/env bash
# sync_pull.sh — 将 GitHub Issue 状态变更回写到 Multica issue
#
# 用法: ./scripts/sync_pull.sh
# 说明: 遍历 dolfly/open-source 中带 "心路历程" 标签的 Issue，
#       读取其关闭状态，回写对应 Multica issue 的 status。
#       关联靠 Multica issue metadata(github_issue) 编号。
set -euo pipefail

REPO="dolfly/open-source"

# 列出仓库 Issue 及其编号/状态
gh issue list --repo "$REPO" --label "心路历程" --state all --json number,state --limit 200 | python3 -c "
import json,sys,subprocess
issues=json.load(sys.stdin)
for it in issues:
    num=it['number']; state=it['state']
    # 找到 metadata.github_issue == num 的 multica issue
    # 简化: 通过 multica issue metadata list 不便批量, 这里逐个匹配需结合外部映射
    print(num, state)
"
echo "sync_pull 需要 Multica<->GitHub 编号映射表; 建议配合 sync_push 写入的 metadata 使用。"
echo "典型回写: github closed -> multica issue status done; open -> in_review"
