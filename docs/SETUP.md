# Setup Guide

Complete step-by-step guide to set up your birdhouse camera system from scratch.

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         BIRDHOUSE VISION SYSTEM                         │
└─────────────────────────────────────────────────────────────────────────┘

    🏡 OUTDOOR (Birdhouse)              🏠 HOME (Indoor)            ☁️  CLOUD
    ┌──────────────────┐                ┌──────────────┐          ┌──────────┐
    │  Camera Pi       │   Cat6 Cable   │   NAS Pi     │  WiFi    │   AWS    │
    │  (Pi 4 8GB)      │◄──────────────►│  (Pi 4 4GB)  │◄────────►│Rekognition│
    │                  │   PoE Power    │              │          │          │
    │  - Camera Module │                │  - 1TB SSD   │          └──────────┘
    │  - PIR Sensor    │                │  - Storage   │
    │  - PoE+ HAT      │                │  - Processing│
    │  - Weatherproof  │                └──────────────┘
    └──────────────────┘
         │
         │ Motion Detected
         ▼
    🐦 Bird Activity
       Captured & Stored
```

### Data Flow

```
1. PIR Sensor → Detects Motion
         ↓
2. Camera Module → Captures Image (1080p)
         ↓
3. Camera Pi → Saves Locally (microSD)
         ↓
4. Network Transfer → Sends to NAS Pi (via PoE Ethernet)
         ↓
5. NAS Pi → Stores on 1TB SSD
         ↓
6. AWS Rekognition → Identifies Bird Species
         ↓
7. Results → Stored & Available for Review
```

### Hardware Connections - Camera Pi

```
                    ┌─────────────────────────────┐
                    │   Raspberry Pi 4 (8GB)      │
                    │                             │
    Camera ─────────┤ CSI Port                    │
    Module 3        │                             │
                    │                 GPIO Pins   │──── PIR Motion
                    │                             │     Sensor (3 pins)
                    │                             │
                    │                 Ethernet    │──── Cat6 Cable
    PoE+ HAT ───────┤ 40-pin Header   Port (PoE)  │     (Data + Power)
    (sits on top)   │                             │
                    │                             │
                    │ microSD Slot                │──── 32GB microSD
                    └─────────────────────────────┘
                             (All enclosed in weatherproof enclosure)
```

### Hardware Connections - NAS Pi

```
                    ┌─────────────────────────────┐
                    │   Raspberry Pi 4 (4GB)      │
                    │                             │
                    │                             │
    USB-C ──────────┤ USB-C Port    USB 3.0 Ports │──── Samsung T7
    Power (15W)     │                             │     1TB SSD
                    │                             │
                    │                 Ethernet    │──── Home Network
                    │                 Port        │     (Router)
                    │                             │
                    │                             │
                    │ microSD Slot                │──── 32GB microSD
                    └─────────────────────────────┘
                             (Standard case, indoor placement)
```

### Network Topology

```
                        Home Router/Switch
                        (192.168.1.1)
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                │              │              │
        PoE Injector    NAS Pi (WiFi)   MacBook Pro
        (Ethernet)      192.168.1.100   (WiFi/Setup)
                │
                │ Cat6 (50m)
                │ PoE Power
                │
         Camera Pi (PoE)
         192.168.1.101
         (birdhouse-camera.local)
```

## Table of Contents
1. [Hardware Prerequisites](#hardware-prerequisites)
2. [Flashing Raspberry Pi OS](#flashing-raspberry-pi-os)
3. [Initial Pi Configuration](#initial-pi-configuration)
4. [Software Installation](#software-installation)
5. [AWS Setup](#aws-setup)

---

## Hardware Prerequisites

Before you begin, ensure you have received:

### Camera Unit (Birdhouse)
- ✅ Raspberry Pi 4 Model B 8GB
- ✅ Camera Module 3
- ✅ Kingston 32GB microSD card
- ✅ PoE+ HAT
- ✅ PIR Motion Sensor

### NAS Unit (Home)
- ✅ Raspberry Pi 4 Model B 4GB
- ✅ Kingston 32GB microSD card
- ✅ Samsung T7 Shield 1TB SSD

### Tools
- ✅ MacBook Pro (for flashing OS)
- ✅ microSD to SD adapter (if using built-in SD slot) OR USB-C card reader

---

## Flashing Raspberry Pi OS

You need to flash **two** microSD cards - one for the camera Pi and one for the NAS Pi.

### Step 1: Download Raspberry Pi Imager

**On macOS:**

```bash
# Option 1: Using Homebrew (recommended)
brew install --cask raspberry-pi-imager

# Option 2: Download from official website
# Visit: https://www.raspberrypi.com/software/
```

**On Windows:**

```powershell
# Option 1: Using winget (Windows 10/11)
winget install RaspberryPiFoundation.RaspberryPiImager

# Option 2: Using Chocolatey
choco install rpi-imager

# Option 3: Download installer from official website
# Visit: https://www.raspberrypi.com/software/
# Download: imager_latest.exe and run installer
```

### Step 2: Prepare Your microSD Card

1. **Insert microSD card**:
   
   **macOS:**
   - **MacBook Pro 2021+**: Use the microSD to SD adapter (included with Kingston card) and insert into built-in SD slot
   - **MacBook Pro 2016-2020**: Use USB-C card reader
   
   **Windows:**
   - Insert microSD card into USB-C card reader
   - Windows should auto-detect and assign a drive letter (e.g., D:, E:)

2. **Verify the card is detected**:
   
   **macOS:**
   ```bash
   diskutil list
   # Look for your microSD card (usually 32GB size)
   # Note the disk identifier (e.g., /dev/disk4)
   ```
   
   **Windows:**
   ```powershell
   # Open PowerShell or Command Prompt
   Get-Disk
   # Or use Disk Management (Win+X → Disk Management)
   # Look for ~32GB removable disk
   ```

### Step 3: Flash Raspberry Pi OS (Camera Unit)

1. **Launch Raspberry Pi Imager**
   
   **macOS:**
   ```bash
   open -a "Raspberry Pi Imager"
   ```
   
   **Windows:**
   - Search for "Raspberry Pi Imager" in Start Menu, or
   - Run from desktop shortcut

2. **Choose Device**: Select `Raspberry Pi 4`

3. **Choose OS**: 
   - Click `Raspberry Pi OS (other)`
   - Select `Raspberry Pi OS Lite (64-bit)` 
   - **Why Lite?** No desktop GUI needed, saves resources, faster boot

4. **Choose Storage**: Select your microSD card

5. **Configure OS Settings** (IMPORTANT):
   - Click the ⚙️ gear icon (OS Customization)
   - **General Tab**:
     - ✅ Set hostname: `birdhouse-camera`
     - ✅ Set username: `birdhouse` (password: create a strong password)
     - ✅ Configure wireless LAN (your WiFi SSID and password)
     - ✅ Set locale: `Europe/Helsinki`, keyboard layout: `us`
   - **Services Tab**:
     - ✅ Enable SSH
     - ✅ Select **"Allow public-key authentication only"** (recommended)
       
       When you select public-key authentication, Raspberry Pi Imager will generate a new SSH key pair for you. You'll be prompted to save the key — **save it directly to your password manager** (e.g., Bitwarden) rather than storing it locally on your machine.
       
       **Using Bitwarden for SSH Key Management (Recommended):**
       
       This approach keeps your private keys secure in your password vault, with no keys stored on your local filesystem.
       
       1. **In Raspberry Pi Imager**: Select "Allow public-key authentication only"
       2. **When prompted to save the key**: 
          - Bitwarden will offer to save the SSH key
          - Choose **"SSH Key"** as the item type in Bitwarden
          - Save both the private key and public key
          - Add a descriptive name (e.g., "Birdhouse NAS Pi SSH Key")
       3. **Copy the public key**: Paste it into the Raspberry Pi Imager's public key field
       4. **Enable Bitwarden SSH Agent**:
          - Open Bitwarden desktop app
          - Go to **Settings → SSH Agent**
          - Enable **"Enable SSH Agent"**
          - On Windows: Also enable **"Use OpenSSH agent"** for system integration
       
       **How it works when connecting:**
       ```
       You run: ssh username@birdhouse-nas.local
                    ↓
       Bitwarden prompts: "Allow SSH connection using [key name]?"
                    ↓
       You approve → Bitwarden provides the key → Connection established
       ```
       
       **🔒 Benefits of this approach:**
       - **No local key files** — Private keys stay encrypted in your Bitwarden vault
       - **Cross-device access** — Connect from any device where Bitwarden is installed
       - **Approval prompts** — You explicitly authorize each connection
       - **Automatic key rotation** — Easy to manage and revoke keys from Bitwarden
       
       **Alternative: Generate keys manually (if not using a password manager)**
       
       If you prefer to manage keys locally:
       
       **Windows (PowerShell):**
       ```powershell
       # Generate Ed25519 key (recommended - secure and fast)
       ssh-keygen -t ed25519 -C "your_email@example.com"
       
       # When prompted for passphrase, CREATE ONE for extra security
       
       # View your public key to copy into Raspberry Pi Imager
       Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
       ```
       
       **macOS/Linux:**
       ```bash
       # Generate Ed25519 key
       ssh-keygen -t ed25519 -C "your_email@example.com"
       
       # View your public key
       cat ~/.ssh/id_ed25519.pub
       ```
       
       If generating keys locally, store your private key and passphrase in a password manager as backup.
       
     - ⚠️ **Alternative**: Use password authentication (less secure, simpler for testing)
   - Click **Save**

6. **Write**:
   - Click `Write`
   - Confirm (this will erase the microSD card)
   - Wait 3-5 minutes for writing and verification
   - **Windows**: May need to click "Yes" on User Account Control prompt
   - Eject card when complete

### Step 4: Flash Raspberry Pi OS (NAS Unit)

**Repeat Step 3** with these changes:
- Use the **second microSD card**
- Set hostname: `birdhouse-nas`
- Same username: `birdhouse` (same password for consistency)
- Same WiFi configuration

### Step 5: Label Your Cards

**IMPORTANT**: Label your microSD cards to avoid confusion!
- Card 1: **"CAMERA"** (hostname: birdhouse-camera)
- Card 2: **"NAS"** (hostname: birdhouse-nas)

---

## Initial Pi Configuration

### Boot and Connect

#### Camera Pi (Initial Setup)

1. **Insert microSD card** into Raspberry Pi 4 (8GB model)
2. **Power on** (use USB-C power supply for initial setup)
3. **Wait 60-90 seconds** for first boot
4. **Find the Pi on your network**:
   
   **macOS:**
   ```bash
   # Try .local hostname (Bonjour/mDNS)
   ping birdhouse-camera.local
   
   # Or scan your network (requires nmap: brew install nmap)
   sudo nmap -sn 192.168.1.0/24 | grep -i raspberry
   
   # Or use arp (built-in, may not show devices that haven't communicated recently)
   # Look for Raspberry Pi MAC addresses:
   # b8:27:eb (older models), dc:a6:32, e4:5f:01 (newer models)
   arp -a | grep -iE "(b8:27:eb|dc:a6:32|e4:5f:01)"
   ```
   
   **Windows:**
   ```powershell
   # Try .local hostname (Windows 10+ supports mDNS)
   ping birdhouse-camera.local
   
   # Or use your router's admin page to find the IP
   # Usually: http://192.168.1.1 or http://192.168.0.1
   
   # Or scan network (if nmap installed)
   nmap -sn 192.168.1.0/24
   ```

5. **SSH into the Pi**:
   
   **macOS/Windows (PowerShell or Windows Terminal):**
   ```bash
   ssh username@birdhouse-camera.local
   ```
   
   **If using Bitwarden SSH Agent:**
   - Ensure Bitwarden desktop app is **open and unlocked**
   - When you run the SSH command, Bitwarden will prompt: "Allow SSH connection?"
   - Approve the connection → you're in!
   
   **If using local keys:** Connection happens automatically (no password prompt)
   
   **If using password auth:** Enter the password you set during OS customization
   
   **Troubleshooting SSH with Bitwarden:**
   - If connection fails with "Permission denied (publickey)":
     - Check Bitwarden is running and unlocked
     - Verify SSH Agent is enabled in Bitwarden Settings → SSH Agent
     - Restart your terminal after enabling the SSH agent
   
   **Windows (if OpenSSH not available):**
   - Install OpenSSH: Settings → Apps → Optional Features → Add OpenSSH Client
   - Or use PuTTY: Download from https://putty.org/
     - For PuTTY with key auth: Convert private key to .ppk format using PuTTYgen

#### First Login Tasks (Camera Pi)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Enable camera interface
sudo raspi-config
# Navigate to: Interface Options → Camera → Enable → Finish

# Reboot
sudo reboot
```

#### NAS Pi (Initial Setup)

Repeat the same process:
```bash
# SSH into NAS Pi
ssh birdhouse@birdhouse-nas.local

# Update system
sudo apt update && sudo apt upgrade -y

# Reboot
sudo reboot
```

---

## Software Installation

### Camera Pi Setup

Coming soon...
- Python 3.9+ installation
- Camera module testing
- Motion sensor configuration
- AWS credentials setup

### NAS Pi Setup

Coming soon...
- Configure Samsung T7 SSD
- Install Samba for network storage
- Set up automatic backup

---

## AWS Setup

Coming soon...
- AWS account creation
- IAM user configuration
- Rekognition API access
- Cost monitoring setup

---

## Troubleshooting

### microSD Card Not Detected

**macOS:**
```bash
# Check if card reader is working
system_profiler SPUSBDataType | grep -i card

# Force re-mount
diskutil list
diskutil unmountDisk /dev/diskX
```

**Windows:**
```powershell
# Check in Disk Management
# Press Win+X → Disk Management
# Look for ~32GB removable disk

# Assign drive letter if needed
# Right-click on disk → Change Drive Letter and Paths

# Or use diskpart
diskpart
list disk
# If disk shows but no volume, may need to format
```

### Cannot Connect via SSH

1. **Check Pi is on network**:
   ```bash
   ping birdhouse-camera.local
   ```

2. **Find IP directly from router** (if .local doesn't work)

3. **Verify SSH is enabled**:
   - Re-flash microSD card
   - Ensure "Enable SSH" was checked in OS customization

### Camera Not Detected

```bash
# Primary test on modern Raspberry Pi OS (libcamera stack)
libcamera-hello

# A preview window should appear if the camera is working.

# Optional: legacy stack diagnostic (only meaningful if legacy camera stack is enabled)
vcgencmd get_camera
# On legacy stack, this should show: supported=1 detected=1
# If not, check ribbon cable connection
# Ensure blue side faces USB ports
```

---

## Next Steps

Once both Pis are running:
1. ✅ Camera Pi: Test camera module
2. ✅ NAS Pi: Connect Samsung T7 SSD
3. ✅ Install project code (see [README.md](../README.md))
4. ✅ Configure networking for PoE
5. ✅ Deploy to birdhouse enclosure