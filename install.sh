#!/bin/bash
# chrome-html-read 一键安装脚本
# - 把 chrome-tabs / chrome-read / chrome-search 复制到 ~/.local/bin
# - 把 SKILL.md 注册到 Claude Code / Codex / ZCode 的 skills 目录
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CHROME_SCRIPTS=(chrome-tabs chrome-read chrome-search)

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔧 安装 chrome-html-read ..."

# 1. 安装命令行脚本
mkdir -p "$BIN_DIR"
for s in "${CHROME_SCRIPTS[@]}"; do
  cp "$SCRIPT_DIR/scripts/$s" "$BIN_DIR/$s"
  chmod +x "$BIN_DIR/$s"
  echo -e "${GREEN}✓${NC} 安装 $BIN_DIR/$s"
done

# 2. 确保 ~/.local/bin 在 PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
  SHELL_RC="$HOME/.zshrc"
  [ -f "$HOME/.bashrc" ] && [ -z "${ZSH_VERSION:-}" ] && SHELL_RC="$HOME/.bashrc"
  echo '' >> "$SHELL_RC"
  echo '# chrome-html-read scripts' >> "$SHELL_RC"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
  echo -e "${YELLOW}⚠${NC} 已把 $BIN_DIR 加入 PATH(写入 $SHELL_RC)"
  echo -e "${YELLOW}  请运行: source $SHELL_RC  或重开终端${NC}"
fi

# 3. 注册 skill(可选)
register_skill() {
  local target_dir="$1"
  if [ -d "$(dirname "$target_dir")" ]; then
    mkdir -p "$target_dir"
    cp "$SCRIPT_DIR/SKILL.md" "$target_dir/SKILL.md"
    cp -r "$SCRIPT_DIR/scripts" "$target_dir/scripts" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} 注册 skill → $target_dir"
    return 0
  fi
  return 1
}

echo ""
echo "📦 注册 Skill ..."
# Claude Code
register_skill "$HOME/.claude/skills/chrome-html-read" || true
# Codex / ZCode
register_skill "$HOME/.agents/skills/chrome-html-read" || true
# Superpowers (codex)
register_skill "$HOME/.codex/superpowers/skills/chrome-html-read" || true

# 4. 检查 Chrome 的 JS-from-Apple-Events 是否开启
echo ""
echo "🔍 检查 Chrome 设置 ..."
TEST=$(osascript -e 'tell application "Google Chrome" to execute (active tab of front window) javascript "1+1"' 2>&1 || true)
if echo "$TEST" | grep -qi "已关闭\|disabled\|Apple Events"; then
  echo -e "${RED}✗${NC} Chrome 未开启「允许 Apple 事件中的 JavaScript」"
  echo -e "${YELLOW}  请手动开启:${NC}"
  echo -e "${YELLOW}  Chrome 菜单 → 查看(View) → 开发者(Developer) → 允许 Apple 事件中的 JavaScript${NC}"
else
  echo -e "${GREEN}✓${NC} Chrome JS-from-Apple-Events 已开启"
fi

echo ""
echo -e "${GREEN}✅ 安装完成!${NC}"
echo ""
echo "试试:"
echo "  chrome-tabs              # 看你开了哪些网页"
echo "  chrome-read 1.1          # 读取第 1 个窗口的第 1 个 tab"
echo "  chrome-read github       # 按关键字读取"
echo "  chrome-search login      # 在所有 tab 里搜"
