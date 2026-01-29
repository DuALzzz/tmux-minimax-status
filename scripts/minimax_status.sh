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
COLOR_BAD="#[fg=red]"
COLOR_GOOD="#[fg=colour208]"
COLOR_RESET="#[fg=default]"
# Warn when usage exceeds this percentage
USAGE_WARN_THRESHOLD=90

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
# Logic: Calculate usage percentage and remaining time
RESULT=$(echo "$RESPONSE" | jq -r '
    .model_remains[0] |
    if . then
        (.current_interval_usage_count / .current_interval_total_count * 100) as $usage |
        (.remains_time / 1000 / 60 | floor) as $minutes |

        {usage: $usage, minutes: $minutes}
    else
        empty
    end
')

if [[ -n "$RESULT" ]]; then
    USAGE=$(echo "$RESULT" | jq '.usage')
    MINUTES=$(echo "$RESULT" | jq '.minutes')

    # Alert: Red if usage exceeds threshold
    if (( $(echo "$USAGE > $USAGE_WARN_THRESHOLD" | bc -l) )); then
        COLOR="$COLOR_BAD"
    else
        COLOR="$COLOR_GOOD"
    fi

    # Format time: show minutes if < 60, otherwise show hours
    if (( MINUTES < 60 )); then
        TIME_STR="${MINUTES}m"
    else
        TIME_STR="$((MINUTES / 60))h"
    fi

    # Output: 📊 12.5% ⏳ 4h or 📊 12.5% ⏳ 30m
    printf "${COLOR}%s %.1f%% ${COLOR_RESET}%s %s" "$ICON_MAIN" "$USAGE" "$ICON_TIME" "$TIME_STR"
else
    echo "Err"
fi
