#!/usr/bin/env bash
# sync_push.sh — 将一篇 Multica 文章 issue 同步到仓库文件 + GitHub Issue
#
# 用法: ./scripts/sync_push.sh <multica_issue_id> [article_md_path]
# 约定: 黄金来源为仓库 articles/** 文件。本脚本把文章写入仓库并提交推送，
#       在 dolfly/open-source 创建/更新对应 GitHub Issue，并把 issue 编号
#       回写到 Multica issue 的 metadata(github_issue)。
#
# 依赖: gh 已登录（GITHUB_TOKEN 或 gh auth）且对 dolfly/open-source 有写权限；
#       multica CLI 可用。
set -euo pipefail

REPO="dolfly/open-source"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISSUE_ID="${1:-}"
ART="${2:-}"

[ -z "$ISSUE_ID" ] && { echo "用法: sync_push.sh <multica_issue_id> [article_md_path]" >&2; exit 1; }

# 1) 读取 Multica issue 标题
TITLE=$(multica issue get "$ISSUE_ID" --output json | python3 -c "import json,sys;print(json.load(sys.stdin)['title'])")

# 2) 定位文章文件（未显式指定时按标题在仓库内查找）
if [ -z "$ART" ]; then
  ART=$(grep -rl "^title: \"${TITLE#【心路历程】}\"\|^title: \"${TITLE}\"" "$ROOT/articles" 2>/dev/null | head -1 || true)
  [ -z "$ART" ] && ART=$(find "$ROOT/articles" -name "*.md" | head -1)
fi
[ -f "$ART" ] || { echo "未找到仓库文章文件: $ART" >&2; exit 1; }

# 3) 提交仓库（黄金来源）并推送
git -C "$ROOT" add "$ART"
git -C "$ROOT" commit -m "content: $TITLE (from $ISSUE_ID)" || echo "无新变更，跳过提交"
git -C "$ROOT" push origin main 2>/dev/null || echo "推送失败（可稍后手动 push）"

# 4) 创建/更新 GitHub Issue（编号从返回的 URL 解析，兼容无 --json 的 gh）
EXISTING=$(multica issue metadata list "$ISSUE_ID" --output json 2>/dev/null | python3 -c "import json,sys;d=json.load(sys.stdin);print(d.get('github_issue',''))" 2>/dev/null)
if [ -n "$EXISTING" ]; then
  gh issue edit "$EXISTING" --repo "$REPO" --title "$TITLE" --body-file "$ART" >/dev/null
  GH_ISSUE="$EXISTING"
  echo "updated github issue #$GH_ISSUE"
else
  URL=$(gh issue create --repo "$REPO" --title "$TITLE" --label "心路历程" --body-file "$ART")
  GH_ISSUE=$(echo "$URL" | grep -oE '/issues/[0-9]+' | grep -oE '[0-9]+')
  echo "created github issue #$GH_ISSUE"
fi

# 5) 回写 metadata
multica issue metadata set "$ISSUE_ID" --key github_issue --value "$GH_ISSUE"
echo "done: multica $ISSUE_ID <-> github #$GH_ISSUE"
