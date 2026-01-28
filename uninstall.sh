#!/bin/bash

TMUX_CONF="$HOME/.tmux.conf"
BACKUP_CONF="$HOME/.tmux.conf.uninstall.bak"
PLUGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🗑️  Uninstalling tmux-minimax-status..."

# 1. 备份配置 (安全第一)
cp "$TMUX_CONF" "$BACKUP_CONF"
echo "✅ Backup created at $BACKUP_CONF"

# 2. 移除配置 (核心逻辑)
# 使用 grep -v 反向筛选，移除所有包含 "tmux-minimax-status" 的行
# 这样会把 install.sh 写入的 注释行 和 status-right 配置行 都删掉
grep -v "tmux-minimax-status" "$BACKUP_CONF" > "$TMUX_CONF"

echo "✅ Configuration lines removed from $TMUX_CONF"

# 3. 恢复运行时状态 (不杀进程!)
# 检查 tmux 是否在运行
if pgrep -x "tmux" > /dev/null; then
    # 将右侧状态栏重置为 Tmux 经典的默认样式 (标题+时间+日期)
    # 这样用户能立刻看到插件消失了，变回了原来的样子
    tmux set -g status-right " \"#{=21:pane_title}\" %H:%M %d-%b-%y"
    
    # 重新加载配置文件
    tmux source "$TMUX_CONF"
    echo "✅ Runtime status bar reset (Tmux session kept alive)."
else
    echo "ℹ️  Tmux is not running, skipping runtime reset."
fi

# 4. 删除插件文件
# 因为我们正在运行这个脚本，直接删除自身目录可能会有一些警告，
# 所以我们只提示用户或者尝试移动到 /tmp
echo ""
echo "🎉 Uninstallation complete!"
echo "👉 To finish, please remove this directory:"
echo "   rm -rf $PLUGIN_DIR"
