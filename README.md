# chrome-html-read 🌐

> Read content from your **already-open Chrome tabs** and bring it into your AI agent / LLM.
> No scraping. No re-login. No headless browser.

一个 macOS 上的小工具集 + Skill,让 AI(Claude Code / Codex / Cursor / ZCode / 任何终端 LLM)能**直接读取你浏览器里已经打开的网页内容**——包括你已登录的、需要 session/cookie 才能访问的页面。

底层是 AppleScript + Chrome 的「允许 Apple 事件中的 JavaScript」能力,纯本地、纯读取、零网络。

## ✨ 为什么需要它

传统的"让 AI 读网页"方案有几个痛点:

| 痛点 | 传统方案 | chrome-html-read |
|------|---------|------------------|
| 需要登录的页面 | curl/WebFetch 拿不到 | ✅ 复用你的登录态 |
| SPA / 动态渲染 | 拿到的是空壳 HTML | ✅ 拿到渲染后的 DOM |
| 内网 / 付费内容 | 外部服务访问不到 | ✅ 本机直接读 |
| 隐私 | 把 URL 发给第三方 | ✅ 内容只在你本机 |

## 🚀 快速开始

### 1. 安装

```bash
git clone https://github.com/freedom-shen/chrome-html-read.git
cd chrome-html-read
./install.sh
```

### 2. 开启 Chrome 的 JS 权限(一次性)

Chrome 菜单栏 → **查看 → 开发者 → 允许 Apple 事件中的 JavaScript**

> 英文菜单: `View → Developer → Allow JavaScript from Apple Events`

### 3. 用起来

```bash
# 列出所有打开的 tab
chrome-tabs

# 读取某个 tab 的正文(默认 innerText)
chrome-read 1.5              # 第 1 窗口第 5 tab
chrome-read "browser-use"    # 按关键字匹配

# 读取并截断(喂给 LLM 时推荐)
chrome-read 2.3 --max 8000

# 在所有 tab 里搜索关键字
chrome-search "登录"
```

## 📖 命令参考

### `chrome-tabs` — 列出打开的标签

```bash
chrome-tabs                  # 标题 + URL,带编号 [win.tab]
chrome-tabs --urls           # 只列 URL
chrome-tabs --json           # JSON 格式
chrome-tabs "github"         # 按关键字过滤
```

### `chrome-read` — 读取指定 tab 内容

```bash
chrome-read 2.3              # 第 2 窗口第 3 tab 的正文
chrome-read browser-use      # 关键字匹配第一个命中
chrome-read 2.3 html         # 输出完整 outerHTML
chrome-read 2.3 --copy       # 复制到剪贴板
chrome-read 2.3 --max 8000   # 截断到 8000 字符(防 token 爆炸)
```

### `chrome-search` — 跨 tab 搜索

```bash
chrome-search "Tuya"         # 搜所有 tab,带上下文
chrome-search error --urls   # 只输出命中的 URL
```

## 🤖 作为 Skill 使用

本仓库的 `SKILL.md` 遵循 [Superpowers](https://github.com/obra/superpowers) 的 Skill 规范,安装后会自动注册到:

- `~/.claude/skills/chrome-html-read/` — Claude Code
- `~/.agents/skills/chrome-html-read/` — Codex / ZCode
- `~/.codex/superpowers/skills/chrome-html-read/` — Superpowers

注册后,在 Claude Code / ZCode 里你可以直接说:

- "看看我浏览器里打开了哪些网页"
- "读一下我现在开的那个 GitHub 仓库页面"
- "在我打开的网页里搜一下'部署文档'"
- "总结一下我当前看的这篇文章"

Agent 会自动调用 `chrome-tabs` / `chrome-read` 完成任务。

## 🔒 安全与隐私

- **纯读取**: 三个脚本都不会点击、输入、导航,只读 DOM。
- **纯本地**: 内容通过 AppleScript 在本机传递,不发送任何外部服务。
- **复用 session**: 因为读的是你已打开的浏览器,所以登录态天然可用。
- **不含 telemetry**: 没有任何埋点、上报。

## 🛠 工作原理

```
你的 Chrome (已登录、已渲染)
       │
       │  AppleScript (osascript)
       ▼
chrome-* 脚本 (本机执行)
       │
       │  stdout
       ▼
你的 AI agent / LLM
```

关键 API 是 Chrome 的 `execute [tab] javascript "..."` AppleScript 命令,需要在 Chrome 里手动开启权限(见上文)。

## 📋 系统要求

- **macOS**(用了 AppleScript)
- **Google Chrome**(不支持 Safari/Edge/Firefox,它们的 AppleScript 字典不同)
- 任何支持 shell 命令的 AI agent(Claude Code / Codex / ZCode / Cursor 等)

## ❓ 常见问题

<details>
<summary><b>报错:"通过 AppleScript 执行 JavaScript 的功能已关闭"</b></summary>

Chrome 没开 JS-from-Apple-Events。菜单: **查看 → 开发者 → 允许 Apple 事件中的 JavaScript**。

</details>

<details>
<summary><b>读到的内容是旧的 / 不完整</b></summary>

某些 SPA 页面 tab 切换后会休眠。先在 Chrome 里手动激活那个 tab 让它刷新,再读。或者用 `chrome-read <idx> html` 看看是不是 DOM 还没渲染。

</details>

<details>
<summary><b>tab 编号变了</b></summary>

tab 顺序会随开关变化。每次读取前不确定的话,先跑一次 `chrome-tabs` 确认编号。

</details>

<details>
<summary><b>能支持 Safari 吗?</b></summary>

技术上可以,Safari 的 AppleScript 字典也支持 `do JavaScript`,但需要在 Safari → 开发 → 允许远程自动化。本仓库暂不提供,欢迎 PR。

</details>

## 📄 License

MIT
