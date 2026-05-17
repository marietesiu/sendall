#!/usr/bin/env bash
# sendall installer — Arch Linux, Debian/Ubuntu, Fedora, macOS
# Run from inside the cloned repo: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_TARGET="/usr/local/bin/sendall"

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
BLD='\033[1m'
RST='\033[0m'

echo ""
echo -e "${BLD}sendall installer${RST}"
echo "────────────────────────────────"

# ── Detect OS ─────────────────────────────────────────────────────────────────
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/arch-release ]]; then
    OS="arch"
elif [[ -f /etc/debian_version ]]; then
    OS="debian"
elif [[ -f /etc/fedora-release ]]; then
    OS="fedora"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo -e "Detected OS : ${GRN}${OS}${RST}"

# ── Python 3 ──────────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo -e "${YLW}Python 3 not found — installing...${RST}"
    case "$OS" in
        arch)   sudo pacman -Sy --noconfirm python ;;
        debian) sudo apt-get install -y python3 ;;
        fedora) sudo dnf install -y python3 ;;
        macos)  brew install python3 ;;
        *)      echo -e "${RED}Please install Python 3 manually then re-run.${RST}"; exit 1 ;;
    esac
fi
echo -e "Python 3    : ${GRN}OK${RST}"

# ── libnotify (Linux only, for notify-send) ───────────────────────────────────
if [[ "$OS" == "arch" || "$OS" == "debian" || "$OS" == "fedora" || "$OS" == "linux" ]]; then
    if ! command -v notify-send &>/dev/null; then
        echo -e "${YLW}notify-send not found — installing libnotify...${RST}"
        case "$OS" in
            arch)   sudo pacman -Sy --noconfirm libnotify ;;
            debian) sudo apt-get install -y libnotify-bin ;;
            fedora) sudo dnf install -y libnotify ;;
        esac
    fi
    echo -e "notify-send : ${GRN}OK${RST}"
fi

# ── Install script to PATH ────────────────────────────────────────────────────
echo "Installing sendall to ${BIN_TARGET}..."
chmod +x "$SCRIPT_DIR/sendall"
sudo ln -sf "$SCRIPT_DIR/sendall" "$BIN_TARGET"
echo -e "sendall bin : ${GRN}OK${RST}"

# ── Enable receiving by default ───────────────────────────────────────────────
touch "$HOME/.sendall_enabled"

# ── Auto-start receiver daemon ────────────────────────────────────────────────
# We register it as a system service so it survives reboots.

if [[ "$OS" == "macos" ]]; then
    # macOS: LaunchAgent plist
    PLIST_DIR="$HOME/Library/LaunchAgents"
    PLIST="$PLIST_DIR/com.sendall.listener.plist"
    PYTHON_PATH="$(command -v python3)"
    SENDALL_PATH="$BIN_TARGET"

    mkdir -p "$PLIST_DIR"
    cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.sendall.listener</string>
    <key>ProgramArguments</key>
    <array>
        <string>${PYTHON_PATH}</string>
        <string>${SENDALL_PATH}</string>
        <string>--listen</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/sendall.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/sendall.err</string>
</dict>
</plist>
PLIST

    # Unload existing if present, then load fresh
    launchctl unload "$PLIST" 2>/dev/null || true
    launchctl load "$PLIST"
    echo -e "LaunchAgent : ${GRN}installed and started${RST}"

elif [[ "$OS" == "arch" || "$OS" == "debian" || "$OS" == "fedora" || "$OS" == "linux" ]]; then
    # Linux: systemd user service
    SERVICE_DIR="$HOME/.config/systemd/user"
    SERVICE="$SERVICE_DIR/sendall.service"
    PYTHON_PATH="$(command -v python3)"

    mkdir -p "$SERVICE_DIR"
    cat > "$SERVICE" <<SERVICE
[Unit]
Description=sendall LAN notification listener
After=network.target

[Service]
ExecStart=${PYTHON_PATH} ${BIN_TARGET} --listen
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
SERVICE

    systemctl --user daemon-reload
    systemctl --user enable --now sendall
    echo -e "systemd     : ${GRN}service enabled and started${RST}"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GRN}${BLD}✓ sendall installed!${RST}"
echo ""
echo -e "  ${BLD}Send a message:${RST}       sendall 192.168.1.42 Hey, lunch is ready!"
echo -e "  ${BLD}Stop receiving:${RST}       sendall --stop"
echo -e "  ${BLD}Start receiving:${RST}      sendall --start"
echo -e "  ${BLD}Check status:${RST}         sendall --status"
echo ""
echo "  Receiving is ON by default."
echo ""
