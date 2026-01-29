# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`tmux-minimax-status` is a lightweight tmux status bar plugin that displays MiniMax Coding Plan token usage (percentage and remaining hours) by reading the API key from local Claude configuration.

## Commands

```bash
# Install the plugin
./install.sh

# Uninstall the plugin
./uninstall.sh
```

## Architecture

The plugin integrates with tmux via `~/.tmux.conf`:

```
status-right: #($PLUGIN_DIR/scripts/minimax_status.sh)
```

**Key scripts:**
- `install.sh` - Appends tmux configuration and sources `~/.tmux.conf`
- `uninstall.sh` - Removes plugin lines from `~/.tmux.conf` and resets status bar
- `scripts/minimax_status.sh` - Core logic that:
  1. Detects API key (env var `MINIMAX_API_KEY` first, then `~/.claude/settings.json`)
  2. Queries `https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains`
  3. Parses JSON response to calculate usage % and remaining hours
  4. Outputs tmux-format string with color (cyan=normal, red=usage > 90%)

**Dependencies:** `jq`, `curl`, `bc`
