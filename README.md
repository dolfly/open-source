# 开源导览 · 文章仓库（private）

公众号「开源导览」内容资产的版本化管理仓库，同时是一个可安装的文章管理技能。

## 分支模型

- **`main`**：脚本 / 技能存储跟踪分支。含 `SKILL.md`（本技能）、`scripts/` 同步脚本。**不含文章内容**。
- **`pages`**：文章内容跟踪分支。定稿文章与配图在此提交；对该分支开启 GitHub Pages，域名 `open-source.p.diele.me`，发布走此分支。

## 黄金来源与跟踪

- 文章内容的**最终可靠来源**是 `pages` 分支的 `articles/**` 文件；配图必须一并入库。
- Multica Issue 与 GitHub Issue 为选题/跟踪视图，通过 `github_issue` 编号关联。
- 详见仓库根 `SKILL.md`。

## 目录结构（pages 分支）

```
articles/<版块>/<年份>/<月份>/<NN>_<标题>.md
articles/<版块>/<年份>/<月份>/<NN>_<标题>/images/   # 配图
CNAME            # open-source.p.diele.me
scripts/         # 同步脚本
```

## 同步脚本

- `scripts/sync_push.sh <multica_issue_id> [文章md]`：写 `pages` 分支 + 建/更 GitHub Issue（正文=标题+原始文件链接）+ 回写 metadata + 状态同步。
- `scripts/sync_status.sh`：按 `github_issue` 双向对齐 Multica / GitHub 状态。

> GitHub Pages：`pages` 分支、`/` 路径，自定义域 `open-source.p.diele.me`。
