# Setup Guide

Complete step-by-step guide to set up your birdhouse camera system from scratch.

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BIRDHOUSE VISION SYSTEM (WiFi)                   │
└─────────────────────────────────────────────────────────────────────┘

    🏡 OUTDOOR (Birdhouse)                   🏠 HOME (Indoor)
    ┌──────────────────┐                     ┌────────────────┐
    │  Camera Pi       │       WiFi (15m)    │  Home Router   │
    │  (Pi Zero 2 W)   │◄────────────────────►│  192.168.1.1   │
    │                  │                     └────────┬───────┘
    │  - NoIR Camera   │                              │ Ethernet
    │  - PIR Sensor    │                              ▼
    │  - IR LEDs       │         🌞 Solar            ┌────────────────┐
    │  - Relay Module  │            Panel (50W)      │  NAS Pi 4      │
    └──────────────────┘            Battery          │  (8GB RAM)     │
         │                          (12V 10Ah)       │  💾 1TB SSD    │
         │ Solar Cables              MPPT Controller │                │
         ▼                           Buck Converter  │  (Local storage│
    🔋 Extended Battery              (12V→5V)        │   before cloud)│
       (4-7 days autonomy)                           └────────────────┘
```

### Data Flow (Motion-Activated)

```
1. PIR Sensor → Detects motion (GPIO4 signal)
         ↓
2. Python script → Reads GPIO HIGH
         ↓
3. GPIO17 → Triggers relay
         ↓
4. IR LEDs → Turn ON (12V from battery)
         ↓
5. Camera Module → Captures image (NoIR, 12MP)
         ↓
6. Pi Zero → Saves locally (microSD backup)
         ↓
7. WiFi upload → Sends to home NAS Pi 4
         ↓
8. NAS Pi 4 → Stores on 1TB SSD (local storage)
         ↓
9. (Optional) → Cloud upload to AWS S3/Rekognition
         ↓
10. After 10s → Relay OFF, LEDs powerdown
```

### Hardware Connections - Camera Pi (Pi Zero 2 W H)

```
                    ┌──────────────────────────┐
                    │ Pi Zero 2 W (with header)│
                    │                          │
    NoIR Camera ────┤ CSI Port (ribbon cable)  │
    Module 3        │                          │
                    │                          │
                    │ GPIO Header (40-pin)     │
                    │ ┌──────────────────────┐ │
    PIR Sensor ─────┤ Pin 1 (3.3V)           │─┤
    VCC         ┌───┤ Pin 6 (GND)            │ │
    GND         │   │ Pin 7 (GPIO4) ◄───OUT  │ │
    OUT         │   │ Pin 11 (GPIO17) ◄─ IN1 │ │
                │   │ Pin 2 (5V)             │─┤─ Relay VCC
    Relay       │   │ Pin 9 (GND)            │─┤─ Relay GND
    Module ─────┘   │ Pin 11 (GPIO17) ─► IN1 │ │
                    │                        │ │
                    │ microSD Slot           │─┤─ microSD Card
                    └──────────────────────────┘
                    (All in weatherproof case)

Relay Output:
  NO ──► 12V IR LED Array
  COM ──► 12V Battery (-)
  IR LED (-) ──► Battery (-)
```

### Power System Connections

```
        ☀️ 50W Solar Panel
             │ (MC4)
             ↓
         ┌────────────┐
         │ MPPT 10A   │◄─── Battery (12V 10Ah)
         │ Controller │     (charging current)
         └────────────┘
             │ (to load)
             ↓
         ┌────────────┐
         │ Buck Conv. │ 12V → 5V 2.5A
         │ 12V-5V 3A  │
         └────────────┘
             │ USB-C
             ↓
        Pi Zero 2 W
        Power Input
```

### Network Topology (WiFi)

```
                    🌐 Home Router
                    192.168.1.1
                    (2.4 GHz WiFi)
                         │
            ┌────────────┼────────────┐
            │            │            │
        Camera Pi     NAS Pi 4      MacBook
        (WiFi)       (Ethernet)     (WiFi)
    192.168.1.101  192.168.1.100
    (Pi Zero 2 W)  (8GB + 1TB SSD)
     └──WiFi───────► stores images locally
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
- ✅ Raspberry Pi Zero 2 W H (with GPIO header)
- ✅ Camera Module 3 NoIR
- ✅ Kingston 32GB microSD card
- ✅ PIR Motion Sensor (HC-SR501)
- ✅ Relay Module (1-channel)
- ✅ IR LED Spotlight (850nm, 12V)

### NAS Unit (Home)
- ✅ Raspberry Pi 4 Model B (8GB)
- ✅ Kingston 32GB microSD card
- ✅ Kingston NV2 1TB SSD
- ✅ Axagon EEM2-UG2 USB 3.0 to NVMe adapter

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

This section covers configuring the Kingston NV2 SSD (via Axagon USB 3.0 adapter), installing Samba for network access, and setting up the data lifecycle management.

#### Data Lifecycle Overview

Before diving into configuration, understand how data flows through the system:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           COMPLETE DATA LIFECYCLE                               │
└─────────────────────────────────────────────────────────────────────────────────┘

  CAMERA PI                         NAS PI                           YOUR DEVICES
  ┌──────────┐                     ┌──────────┐                     ┌──────────┐
  │  1. PIR  │                     │          │                     │          │
  │  Detects │                     │   5. SSD │    [birdhouse]      │  Finder  │
  │  Motion  │                     │   Stores │◄──────────────────► │    or    │
  └────┬─────┘                     │   Image  │   Read/Write        │ Explorer │
       │                           │          │                     │          │
       ▼                           │          │   [birdhouse-guest] │  Family  │
  ┌──────────┐                     │          │◄──────────────────► │  Devices │
  │ 2. Capture                     │          │   Read-Only         │          │
  │   Image  │                     └────┬─────┘                     └──────────┘
  └────┬─────┘                          │
       │                                │
       ▼                                ▼
  ┌──────────┐    IMMEDIATE       ┌──────────┐
  │ 3. Save  │    rsync/SSH       │ 6. DAILY │
  │ to       │───────────────────►│ LIFECYCLE│
  │ microSD  │                    │ CHECK    │
  └────┬─────┘                    └────┬─────┘
       │                               │
       ▼                               ▼
  ┌──────────┐                   ┌───────────────────────────────┐
  │ 4. DELETE│                   │  Age > 365 days? → DELETE     │
  │ local    │                   │  Disk ≥ 95%?    → DELETE      │
  │ (success)│                   │                   OLDEST      │
  └──────────┘                   │                   until < 90% │
                                 └───────────────────────────────┘

  ════════════════════════════════════════════════════════════════════════════════
   RETENTION POLICY:
  ════════════════════════════════════════════════════════════════════════════════
   • NORMAL:    Delete captures older than 365 days
   • EMERGENCY: If disk ≥ 95%, delete oldest files until disk < 90%
   • PRIORITY:  Disk space check runs FIRST (prevents full disk)
```

#### Step 1: Connect and Identify the Kingston NV2 SSD

1. **Connect the Kingston NV2 SSD** via Axagon EEM2-UG2 adapter to a USB 3.0 port (blue port) on the NAS Pi

2. **SSH into the NAS Pi**:
   ```bash
   ssh birdhouse@birdhouse-nas.local
   ```

3. **Identify the SSD**:
   ```bash
   # List all block devices
   lsblk
   
   # You should see something like:
   # NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
   # sda           8:0    0 931.5G  0 disk 
   # └─sda1        8:1    0 931.5G  0 part 
   # mmcblk0     179:0    0  29.7G  0 disk 
   # ├─mmcblk0p1 179:1    0   512M  0 part /boot/firmware
   # └─mmcblk0p2 179:2    0  29.2G  0 part /
   
   # Verify it's the Kingston NV2 (should show ~1TB)
   sudo fdisk -l /dev/sda
   ```

#### Step 2: Format the SSD (ext4)

**⚠️ WARNING**: This will erase all data on the SSD!

```bash
# Create a new partition table and partition
sudo parted /dev/sda --script mklabel gpt
sudo parted /dev/sda --script mkpart primary ext4 0% 100%

# Format as ext4 with a label
sudo mkfs.ext4 -L birdhouse /dev/sda1

# Verify the format
sudo blkid /dev/sda1
# Should show: /dev/sda1: LABEL="birdhouse" UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" TYPE="ext4"
```

#### Step 3: Create Mount Point and Configure Auto-Mount

```bash
# Create the mount point directory
sudo mkdir -p /mnt/birdhouse

# Get the UUID of the partition (more reliable than /dev/sda1)
sudo blkid /dev/sda1 | grep -oP 'UUID="\K[^"]+'
# Copy this UUID for the next step

# Edit fstab to auto-mount on boot
sudo nano /etc/fstab
```

Add this line at the end of `/etc/fstab` (replace `YOUR-UUID-HERE` with the actual UUID):

```
UUID=YOUR-UUID-HERE  /mnt/birdhouse  ext4  defaults,nofail,x-systemd.device-timeout=30  0  2
```

**Mount options explained**:
- `defaults` — standard mount options (rw, suid, dev, exec, auto, nouser, async)
- `nofail` — boot continues even if SSD is disconnected (prevents boot failure)
- `x-systemd.device-timeout=30` — wait up to 30 seconds for USB device

```bash
# Test the mount (without rebooting)
sudo mount -a

# Verify it's mounted
df -h /mnt/birdhouse
# Should show ~932GB available

# Create directory structure
sudo mkdir -p /mnt/birdhouse/captures
sudo mkdir -p /mnt/birdhouse/logs

# Set ownership to birdhouse user
sudo chown -R birdhouse:birdhouse /mnt/birdhouse

# Verify permissions
ls -la /mnt/birdhouse
```

#### Step 4: Install and Configure Samba

```bash
# Install Samba
sudo apt update
sudo apt install -y samba samba-common-bin

# Backup original config
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Create Samba password for birdhouse user
sudo smbpasswd -a birdhouse
# Enter a password (can be different from SSH password)
# This is for the authenticated [birdhouse] share

# Enable the user
sudo smbpasswd -e birdhouse
```

Edit the Samba configuration:

```bash
sudo nano /etc/samba/smb.conf
```

Add the following at the end of the file:

```ini
#======================= Birdhouse Shares =======================

[birdhouse]
   comment = Birdhouse Captures (Authenticated)
   path = /mnt/birdhouse/captures
   browseable = yes
   read only = no
   writable = yes
   valid users = birdhouse
   create mask = 0644
   directory mask = 0755
   force user = birdhouse
   force group = birdhouse

[birdhouse-guest]
   comment = Birdhouse Captures (Guest Read-Only)
   path = /mnt/birdhouse/captures
   browseable = yes
   read only = yes
   guest ok = yes
   guest only = yes
   force user = nobody
   force group = nogroup
```

**Share comparison**:

```
┌───────────────────────────────────┬───────────────────────────────────┐
│       [birdhouse]                 │       [birdhouse-guest]           │
│       AUTHENTICATED               │       GUEST READ-ONLY             │
├───────────────────────────────────┼───────────────────────────────────┤
│                                   │                                   │
│  Access: Read + Write             │  Access: Read Only                │
│  Auth:   Username + Password      │  Auth:   None (open)              │
│  User:   birdhouse                │  User:   guest                    │
│                                   │                                   │
│  Use for:                         │  Use for:                         │
│  • Managing files                 │  • Quick viewing                  │
│  • Deleting captures              │  • Sharing with family            │
│  • Full admin access              │  • No risk of accidental delete   │
│                                   │                                   │
└───────────────────────────────────┴───────────────────────────────────┘
```

```bash
# Test the configuration
sudo testparm

# Restart Samba services
sudo systemctl restart smbd nmbd

# Enable Samba to start on boot
sudo systemctl enable smbd nmbd

# Check status
sudo systemctl status smbd
```

#### Step 5: Connect from Your Devices

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           CONNECTING TO NAS SHARE                               │
└─────────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────┐
  │           macOS (Finder)                │
  ├─────────────────────────────────────────┤
  │                                         │
  │  Authenticated Share (Read/Write):      │
  │  ─────────────────────────────────      │
  │  1. Open Finder                         │
  │  2. Press ⌘+K (Go → Connect to Server)  │
  │  3. Enter:                              │
  │     smb://birdhouse-nas.local/birdhouse │
  │  4. Click "Connect"                     │
  │  5. Select "Registered User"            │
  │  6. Enter credentials:                  │
  │     Username: birdhouse                 │
  │     Password: [your samba password]     │
  │  7. ✅ Check "Remember this password"   │
  │                                         │
  │  Guest Share (Read-Only):               │
  │  ────────────────────────               │
  │  1. Press ⌘+K                           │
  │  2. Enter:                              │
  │     smb://birdhouse-nas.local/          │
  │            birdhouse-guest              │
  │  3. Select "Guest"                      │
  │  4. Click "Connect"                     │
  │                                         │
  │  📁 Share appears in Finder sidebar     │
  │     under "Locations"                   │
  │                                         │
  └─────────────────────────────────────────┘

  ┌─────────────────────────────────────────┐
  │         Windows 10/11 (Explorer)        │
  ├─────────────────────────────────────────┤
  │                                         │
  │  Authenticated Share (Read/Write):      │
  │  ─────────────────────────────────      │
  │  1. Open File Explorer                  │
  │  2. Click address bar, type:            │
  │     \\birdhouse-nas.local\birdhouse     │
  │  3. Press Enter                         │
  │  4. Enter credentials:                  │
  │     Username: birdhouse                 │
  │     Password: [your samba password]     │
  │  5. ✅ Check "Remember my credentials"  │
  │                                         │
  │  Guest Share (Read-Only):               │
  │  ────────────────────────               │
  │  1. In address bar, type:               │
  │     \\birdhouse-nas.local\              │
  │            birdhouse-guest              │
  │  2. Press Enter (no password needed)    │
  │                                         │
  │  Map as Network Drive (Optional):       │
  │  ────────────────────────────────       │
  │  1. Right-click "This PC"               │
  │  2. Select "Map network drive"          │
  │  3. Choose drive letter (e.g., B:)      │
  │  4. Folder:                             │
  │     \\birdhouse-nas.local\birdhouse     │
  │  5. ✅ Check "Reconnect at sign-in"     │
  │  6. Click "Finish", enter credentials   │
  │                                         │
  │  📁 Drive appears in "This PC"          │
  │                                         │
  └─────────────────────────────────────────┘

  ┌─────────────────────────────────────────┐
  │            Troubleshooting              │
  ├─────────────────────────────────────────┤
  │                                         │
  │  Can't connect? Try IP address instead: │
  │                                         │
  │  macOS:   smb://192.168.1.100/birdhouse │
  │  Windows: \\192.168.1.100\birdhouse     │
  │                                         │
  │  Find NAS IP:                           │
  │  $ ping birdhouse-nas.local             │
  │                                         │
  │  Windows checks:                        │
  │  - Verify user/password are correct.    │
  │  - Allow File & Printer Sharing in      │
  │    Windows Defender Firewall.           │
  │  - Keep SMB2/SMB3 enabled; do NOT       │
  │    enable legacy SMB1 (deprecated,      │
  │    insecure).                           │
  └─────────────────────────────────────────┘
```

#### Step 6: Set Up Data Lifecycle Management

The lifecycle script handles automatic cleanup based on retention policy.

```bash
# Create scripts directory on NAS Pi
mkdir -p ~/scripts/nas

# Create the lifecycle cleanup script
nano ~/scripts/nas/lifecycle-cleanup.sh
```

Copy the lifecycle script from the project repository (see `scripts/nas/lifecycle-cleanup.sh`), then:

```bash
# Make it executable
chmod +x ~/scripts/nas/lifecycle-cleanup.sh

# Test run (dry-run mode)
~/scripts/nas/lifecycle-cleanup.sh --dry-run
```

#### Step 7: Install Systemd Timer for Daily Cleanup

```bash
# Create systemd service file
sudo nano /etc/systemd/system/birdhouse-lifecycle.service
```

Copy the versioned systemd service unit from the repository into `/etc/systemd/system/`:

```bash
sudo cp /path/to/birdhouse-vision/systemd/birdhouse-lifecycle.service /etc/systemd/system/birdhouse-lifecycle.service
```

```bash
# Create systemd timer file
sudo nano /etc/systemd/system/birdhouse-lifecycle.timer
```

Add:

```ini
[Unit]
Description=Daily Birdhouse Data Lifecycle Cleanup

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# Enable and start the timer
sudo systemctl daemon-reload
sudo systemctl enable birdhouse-lifecycle.timer
sudo systemctl start birdhouse-lifecycle.timer

# Verify timer is active
sudo systemctl list-timers | grep birdhouse

# Check timer status
sudo systemctl status birdhouse-lifecycle.timer
```

#### Step 8: Directory Structure

After setup, your SSD will have this structure:

```
/mnt/birdhouse/
├── captures/
│   ├── 2026/
│   │   ├── 01/
│   │   │   ├── 15/
│   │   │   │   ├── 2026-01-15_08-23-45_motion.jpg
│   │   │   │   ├── 2026-01-15_08-23-45_motion.json  (metadata)
│   │   │   │   ├── 2026-01-15_14-07-12_motion.jpg
│   │   │   │   └── ...
│   │   │   ├── 16/
│   │   │   └── ...
│   │   ├── 02/
│   │   └── ...
│   └── 2025/
│       └── ... (auto-deleted after 365 days)
└── logs/
    └── lifecycle.log
```

#### Lifecycle Retention Logic

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         DAILY LIFECYCLE CHECK (NAS PI)                          │
└─────────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │  START CLEANUP  │
                              │  (daily timer)  │
                              └────────┬────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │  Check disk     │
                              │  usage on SSD   │
                              └────────┬────────┘
                                       │
                         ┌─────────────┴─────────────┐
                         │                           │
                         ▼                           ▼
                ┌─────────────────┐        ┌─────────────────┐
                │  Disk ≥ 95%?   │        │  Disk < 95%     │
                │  EMERGENCY MODE │        │  NORMAL MODE    │
                └────────┬────────┘        └────────┬────────┘
                         │                          │
                         ▼                          ▼
                ┌─────────────────┐        ┌─────────────────┐
                │  Delete OLDEST  │        │  Delete files   │
                │  files first    │        │  older than     │
                │  until < 90%    │        │  365 DAYS       │
                └────────┬────────┘        └────────┬────────┘
                         │                          │
                         └──────────┬───────────────┘
                                    │
                                    ▼
                           ┌─────────────────┐
                           │  Log results    │
                           │  Exit           │
                           └─────────────────┘
```

#### Verify Everything Works

```bash
# Check SSD is mounted
df -h /mnt/birdhouse

# Check Samba is running
sudo systemctl status smbd

# Check timer is scheduled
sudo systemctl list-timers | grep birdhouse

# Test Samba from NAS Pi itself
smbclient -L localhost -U birdhouse

# View lifecycle logs (after first run)
cat /mnt/birdhouse/logs/lifecycle.log
```

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

### Windows Cannot Access Samba Share

1. **Enable File and Printer Sharing in Windows Firewall**:
   - Open **Windows Security** → **Firewall & network protection**
   - Click **Allow an app through firewall**
   - Find **File and Printer Sharing** and ensure both **Private** and **Public** are checked
   - Or run in elevated PowerShell:
     ```powershell
     Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True
     ```

2. **Windows can't resolve `.local` hostname**:
   - Use the IP address instead: `\\192.168.x.x\birdhouse`
   - Find IP: `ping birdhouse-nas.local` (from a device that resolves it)
   - Or check your router's DHCP client list

3. **Verify SMB2/SMB3 and Windows sharing settings**:
   - Ensure your NAS/Samba server is configured to allow SMB2/SMB3 (for example, `min protocol = SMB2` in `smb.conf`)
   - On Windows, open **Control Panel** → **Network and Sharing Center** → **Advanced sharing settings**
   - Under your active profile, make sure **Turn on network discovery** and **Turn on file and printer sharing** are selected

4. **Clear cached credentials** (if password changed):
   ```powershell
   # List saved credentials
   cmdkey /list
   
   # Delete specific credential
   cmdkey /delete:birdhouse-nas.local
   ```

### WiFi Not Connecting on Boot (Raspberry Pi OS Bookworm)

Raspberry Pi OS Bookworm uses **NetworkManager** instead of `wpa_supplicant`. If WiFi isn't saved:

1. **Check current connections**:
   ```bash
   nmcli connection show
   ```

2. **Connect and save WiFi**:
   ```bash
   # List available networks
   nmcli device wifi list
   
   # Connect (use single quotes if password has special characters)
   nmcli device wifi connect "YourSSID" password 'YourPassword'
   ```

3. **Verify autoconnect is enabled**:
   ```bash
   nmcli connection show "YourSSID" | grep autoconnect
   # Should show: connection.autoconnect: yes
   ```

4. **If connection exists but won't autoconnect**:
   ```bash
   nmcli connection modify "YourSSID" connection.autoconnect yes
   ```

5. **Check WiFi status after reboot**:
   ```bash
   nmcli device status
   # wifi should show "connected"
   
   ip addr show wlan0
   # Should show an IP address
   ```

### macOS Cannot Access Samba Share

1. **Use IP address if `.local` doesn't resolve**:
   - Finder → ⌘+K → `smb://192.168.x.x/birdhouse`

2. **Reset SMB credentials** (if password changed):
   - Open **Keychain Access**
   - Search for `birdhouse-nas`
   - Delete the saved password
   - Reconnect and enter new password

3. **SMB version mismatch**:
   ```bash
   # On the Pi, check Samba allows SMB2/3 (should be default)
   testparm -s 2>/dev/null | grep "server min protocol"
   ```

---

## Next Steps

Once both Pis are running:
1. ✅ Camera Pi: Test PIR sensor and camera module
2. ✅ NAS Pi: Connect Kingston NV2 SSD via Axagon adapter
3. ✅ Install project code (see [README.md](../README.md))
4. ✅ Configure WiFi networking (camera Pi to home router)
5. ✅ Deploy to birdhouse enclosure