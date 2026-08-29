---
name: open-source-article-manager
description: 管理「开源导览」公众号文章资产——把定稿文章提交到 dolfly/open-source 的 pages 分支（黄金来源），通过 GitHub Pages（open-source.cofire.cn）发布，并与 Multica Issue 双向跟踪。当用户需要「整理文章到 github」「把文章发布到开源导览仓库」「同步文章与 Multica/GitHub Issue」「维护 pages 分支与 GitHub Pages」时使用。
---

# 开源导览 · 文章管理技能

本技能把公众号「开源导览」的文章生产、版本管理与发布标准化，全部基于私有仓库
**dolfly/open-source**，可被 `git clone` 后直接安装/更新。

## 分支模型（核心约定）

| 分支 | 用途 |
|------|------|
| `main` | **脚本 / 技能** 存储跟踪分支。本 `SKILL.md`、`scripts/` 在此维护。不含文章内容。 |
| `pages` | **文章内容** 跟踪分支。定稿文章、配图在此提交；仓库对该分支开启 GitHub Pages，域名 `open-source.cofire.cn`。发布走此分支。 |

> 黄金来源原则：文章内容的**最终可靠来源**是 `pages` 分支的 `articles/**` 文件；
> Multica Issue 与 GitHub Issue 均为选题/跟踪视图，可在任一处创建，通过 `github_issue` 编号关联。

## 目录结构（pages 分支）

```
articles/
  <版块>/            # 如 心路历程
    <年份>/<月份>/   # 如 2026/08
      <NN>_<标题>.md
      <NN>_<标题>/images/   # 该篇配图
images/              # 全局配图备用目录
CNAME                # open-source.cofire.cn
scripts/             # 同步脚本（同 main）
```

## 文章文件规范

每篇 md 顶部 YAML frontmatter：

```yaml
---
title: "标题"
author: 瀚创社
section: 心路历程
column: "首发第 N 期"
topic: "主题"
suggested_publish: "周一 21:00"
source_issue: BPS-6
---
```

## 发布流程

1. 在 `pages` 分支写稿：`articles/<版块>/<年>/<月>/<NN>_<标题>.md`，配图提交到同目录 `images/`（**配图必须入库**）。
2. 提交并 push `pages` 分支 → GitHub Pages 自动更新 `open-source.cofire.cn`。
3. 选题/跟踪：每篇在 Multica 建 issue，编号回写 `github_issue` metadata；如需 GitHub Issue 跟踪，正文仅放「标题 + 原始文件链接」（见下）。
4. 审核通过后发布到公众号草稿箱（由「baoyu-post-to-wechat」等技能执行）。

## 同步脚本（scripts/）

- `sync_push.sh <multica_issue_id> [文章md路径]`：把文章写入 `pages` 分支并提交推送，
  在 `dolfly/open-source` 创建/更新对应 GitHub Issue（正文=标题+原始文件链接），
  回写 `github_issue` metadata，并按 Multica 状态开/关 GitHub Issue。
- `sync_pull.sh` / `sync_status.sh`：按 `github_issue` 编号双向对齐 Multica 与 GitHub 的状态
  （Multica `done/cancelled`→GitHub closed；GitHub closed→Multica done）。

原始文件链接模板（pages 分支）：
`https://raw.githubusercontent.com/dolfly/open-source/pages/articles/<版块>/<年>/<月>/<NN>_<标题>.md`

## 安装 / 更新

```bash
git clone git@github.com:dolfly/open-source.git
# 技能文件即仓库根目录 SKILL.md；按宿主技能系统要求放入技能目录即可
```

更新：`git -C open-source pull` 后重新安装。
