#!/usr/bin/env bash
# sync_push.sh — 将一篇 Multica 文章 issue 同步到仓库文件 + GitHub Issue
#
# 用法: ./scripts/sync_push.sh <multica_issue_id> [github_issue_number]
# 说明: 黄金来源为仓库文件；本脚本负责把文章写入仓库并提交，
#       再在 dolfly/open-source 创建/更新对应 GitHub Issue，并把 issue 编号
#       回写到 Multica issue 的 metadata(github_issue)。
set -euo pipefail

REPO="dolfly/open-source"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISSUE_ID="${1:-}"
GH_ISSUE="${2:-}"

[ -z "$ISSUE_ID" ] && { echo "用法: sync_push.sh <multica_issue_id> [github_issue_number]" >&2; exit 1; }

# 1) 读取 Multica issue 标题
TITLE=$(multica issue get "$ISSUE_ID" --output json | python3 -c "import json,sys;print(json.load(sys.stdin)['title'])")

# 2) 从仓库定位该文章文件（约定: articles/<版块>/<年>/<月>/<NN>_*.md）
ART=$(find "$ROOT/articles" -type f -name "*.md" | head -1)
[ -f "$ART" ] || { echo "未找到仓库文章文件，请先定稿入库" >&2; exit 1; }

# 3) 提交仓库（黄金来源）
git -C "$ROOT" add "$ART"
git -C "$ROOT" commit -m "content: $TITLE (from $ISSUE_ID)" || echo "无新变更"

# 4) 创建/更新 GitHub Issue
BODY=$(cat "$ART")
if [ -z "$GH_ISSUE" ]; then
  GH_ISSUE=$(gh issue create --repo "$REPO" --title "$TITLE" --body "$BODY" --label "心路历程" --json number | python3 -c "import json,sys;print(json.load(sys.stdin)['number'])")
  echo "created github issue #$GH_ISSUE"
else
  gh issue edit "$GH_ISSUE" --repo "$REPO" --title "$TITLE" --body "$BODY"
  echo "updated github issue #$GH_ISSUE"
fi

# 5) 回写 metadata
multica issue metadata set "$ISSUE_ID" --key github_issue --value "$GH_ISSUE"
echo "done: multica $ISSUE_ID <-> github #$GH_ISSUE"
