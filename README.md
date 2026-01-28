# tmux-minimax-status 📊

A lightweight Tmux status bar plugin designed for **MiniMax Coding Plan** users.

It perfectly complements the **Claude Code** workflow by **automatically reading the API Key** from your local Claude configuration, displaying real-time token balance and expiration time in your terminal.


## ✨ Features

* **⚡️ Zero Config**: Automatically detects `~/.claude/settings.json`. No need to set the key twice.
* **🎯 Precise Monitoring**: Shows remaining percentage (e.g., 12.5%) and remaining hours.
* **🚨 Smart Alert**: Icon turns red when balance drops below 10%.
* **📱 Mobile Optimized**: Compact output designed for Termius/SSH on mobile devices.

## 📦 Requirements

* `jq` (Command-line JSON processor)
* `curl`

## 🚀 Installation

1. Clone the repo:
```bash
git clone https://github.com/DuALzzz/tmux-minimax-status.git ~/.tmux/plugins/tmux-minimax-status
```

2.Run the installer:
```bash
cd ~/.tmux/plugins/tmux-minimax-status
./install.sh
``` 

## ⚙️ Configuration

* **Auto Mode**: Works out-of-the-box if you use **Claude Code**.
* **Manual Mode**: Set `export MINIMAX_API_KEY="YOUR_API_KEY"` in your `.zshrc` or `.bashrc`.

## 📄 License

MIT License
