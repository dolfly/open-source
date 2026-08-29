# 开源导览 · 文章仓库（private）

公众号「开源导览」内容资产的版本化管理仓库。

## 定位与同步原则

- **黄金来源（Golden Source）**：本仓库中的 `articles/**` 文件是文章内容的**最终可靠来源**，所有修订通过 git 提交留痕。
- **选题与跟踪来源**：Multica Issue（BPS-*）与 GitHub Issue 均为**选题来源与跟踪视图**，可在任一处创建跟踪任务，通过 `github_issue` 编号互相关联。
- 发布流程：仓库定稿 → 推送 GitHub（Issue 跟踪）→ 审核 → 微信草稿箱发布。

## 目录结构

```
articles/
  <版块>/
    <年份>/
      <月份>/
        <NN>_<标题>.md     # NN 与 Multica 子任务编号对齐
scripts/
  sync_push.sh             # Multica/GitHub Issue → 仓库文件 + GitHub Issue
  sync_pull.sh             # GitHub Issue 变更 → 回写 Multica metadata
```

## 文章文件规范

每篇 md 顶部含 YAML frontmatter：

```yaml
title: "标题"
author: 瀚创社
section: 心路历程
column: "首发第 N 期"
topic: "主题"
suggested_publish: "周一 21:00"
source_issue: BPS-6
```

## 同步脚本

- `scripts/sync_push.sh <multica_issue_id> [github_issue_number]`：将文章写入仓库并提交，并在 `dolfly/open-source` 创建/更新对应 GitHub Issue，编号回写 Multica issue 的 `github_issue` metadata。
- `scripts/sync_pull.sh`：读取 `dolfly/open-source` 的 Issue 状态变更（如关闭），回写 Multica issue 状态。

> 同步依赖 `gh` 已登录且对 `dolfly/open-source` 有写权限。
