#!/bin/bash
#
# tmux-minimax-status
#
# Author: [DuALz Yu]
# License: MIT
#

# --- Constants ---
# Default Claude Code config path
CLAUDE_CONFIG="$HOME/.claude/settings.json"
# MiniMax Coding Plan Remains API
MINIMAX_API_URL="https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains"

# Icons & Colors
ICON_MAIN="📊"
ICON_TIME="⏳"
COLOR_WARN="#[fg=red]"
COLOR_GOOD="#[fg=cyan]"
COLOR_RESET="#[fg=default]"

# --- 1. Dependency Check ---
if ! command -v jq &> /dev/null; then
    echo "jq missing"
    exit 1
fi

# --- 2. Auto-Detect API Key ---
# Priority 1: Environment Variable
API_KEY="$MINIMAX_API_KEY"

# Priority 2: Claude Code Config
if [[ -z "$API_KEY" && -f "$CLAUDE_CONFIG" ]]; then
    API_KEY=$(jq -r '.env.ANTHROPIC_AUTH_TOKEN // empty' "$CLAUDE_CONFIG")
fi

# Validation
if [[ -z "$API_KEY" || "$API_KEY" == "null" || "$API_KEY" == "MINIMAX_API_KEY" ]]; then
    echo "No Key"
    exit 1
fi

# --- 3. Query API ---
RESPONSE=$(curl -s --location "$MINIMAX_API_URL" \
    --header "Authorization: Bearer $API_KEY" \
    --header 'Content-Type: application/json')

# --- 4. Parse & Display ---
# Logic: Calculate percentage and hours
RESULT=$(echo "$RESPONSE" | jq -r '
    .model_remains[0] | 
    if . then
        (.current_interval_total_count - .current_interval_usage_count) as $left |
        (.current_interval_total_count) as $total |
        (( $left / $total ) * 100) as $pct |
        (.remains_time / 1000 / 3600 | floor) as $hours |
        
        {pct: $pct, h: $hours}
    else
        empty
    end
')

if [[ -n "$RESULT" ]]; then
    PCT=$(echo "$RESULT" | jq '.pct')
    HOURS=$(echo "$RESULT" | jq '.h')

    # Alert: Red if usage < 10%
    if (( $(echo "$PCT < 10" | bc -l) )); then
        COLOR="$COLOR_WARN"
    else
        COLOR="$COLOR_GOOD"
    fi

    # Output: 📊 12.5% ⏳ 4h
    printf "${COLOR}%s %.1f%% ${COLOR_RESET}%s %.0fh" "$ICON_MAIN" "$PCT" "$ICON_TIME" "$HOURS"
else
    echo "Err"
fi
