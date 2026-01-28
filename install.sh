cat > install.sh << 'EOF'
#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMUX_CONF="$HOME/.tmux.conf"

echo "📦 Installing tmux-minimax-status..."

# Dependency Check
if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is required. Please install it (sudo apt install jq)."
    exit 1
fi

# Backup
cp "$TMUX_CONF" "$TMUX_CONF.bak"

# Append configuration
echo "" >> "$TMUX_CONF"
echo "# --- tmux-minimax-status ---" >> "$TMUX_CONF"
echo "set -g status-interval 300" >> "$TMUX_CONF"
echo "set -g status-right \"#($SCRIPT_DIR/scripts/minimax_status.sh) | %H:%M\"" >> "$TMUX_CONF"

echo "✅ Configuration added to $TMUX_CONF"
echo "🔄 Reloading tmux..."
tmux source "$TMUX_CONF"
echo "🎉 Done! Check your status bar."
EOF
chmod +x install.sh
