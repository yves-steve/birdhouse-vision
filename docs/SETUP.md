# Setup Guide

Complete step-by-step guide to set up your birdhouse camera system from scratch.

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
     - ✅ Use password authentication (for now)
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
   
   # Or use arp (built-in, less reliable)
   # Look for Raspberry Pi MAC addresses (b8:27:eb, dc:a6:32, e4:5f:01)
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
   ssh birdhouse@birdhouse-camera.local
   # Enter the password you set during OS customization
   ```
   
   **Windows (if SSH not available):**
   - Install OpenSSH: Settings → Apps → Optional Features → Add OpenSSH Client
   - Or use PuTTY: Download from https://putty.org/

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
# Test camera connection
vcgencmd get_camera

# Should show: supported=1 detected=1

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