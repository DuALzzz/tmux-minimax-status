#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMUX_CONF="$HOME/.tmux.conf"
MARKER="# --- tmux-minimax-status ---"

echo "📦 Installing tmux-minimax-status..."

# Dependency Check
if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is required. Please install it (sudo apt install jq)."
    exit 1
fi

# Backup
cp "$TMUX_CONF" "$TMUX_CONF.bak"

# Ensure scripts are executable
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# Remove existing plugin config if present (for updates)
if grep -q "$MARKER" "$TMUX_CONF"; then
    echo "🔄 Updating existing installation..."
    grep -v "$MARKER" "$TMUX_CONF" | grep -v "status-interval 60" | grep -v "minimax_status.sh" > "$TMUX_CONF.tmp" && mv "$TMUX_CONF.tmp" "$TMUX_CONF"
fi

# Append configuration
echo "" >> "$TMUX_CONF"
echo "$MARKER" >> "$TMUX_CONF"
echo "set -g status-interval 60" >> "$TMUX_CONF"
echo "set -g status-right \"#($SCRIPT_DIR/scripts/minimax_status.sh) | %H:%M\"" >> "$TMUX_CONF"

echo "✅ Configuration added to $TMUX_CONF"
echo "🔄 Reloading tmux..."
tmux source "$TMUX_CONF" 2>/dev/null || true
echo "🎉 Done! Check your status bar."
