---
title: 开源导览 · 心路历程
---

# 开源导览 · 心路历程

「开源导览」公众号「心路历程」专栏的文章资产（黄金来源 = `pages` 分支，由 GitHub Pages 自动发布）。

## 文章列表

{% assign posts = site.pages | where_exp: "p", "p.url contains '/articles/'" %}
{% assign posts = posts | where_exp: "p", "p.url contains '_meta' | not" %}
{% assign posts = posts | sort: "url" %}
{% for p in posts %}
- [{{ p.title }}]({{ p.url | relative_url }})
{% endfor %}

---

> 站点由 Jekyll 构建，源文件位于 [dolfly/open-source](https://github.com/dolfly/open-source) 的 `pages` 分支。
