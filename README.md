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
