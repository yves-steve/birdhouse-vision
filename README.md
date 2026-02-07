# 🐦 Birdhouse Vision

AI-powered bird camera system using Raspberry Pi, motion detection, and AWS Rekognition.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.9+-green.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%20Zero%202%20W-red.svg)
![Status](https://img.shields.io/badge/status-in%20development-yellow.svg)

<!-- TODO: Add photo of birdhouse setup once built -->
<!-- ![Birdhouse Camera](docs/images/birdhouse-hero.jpg) -->

## Why This Project?

I wanted to see what birds visit my garden birdhouse without disturbing them. Commercial smart cameras are expensive, cloud-dependent, and not designed for birdhouses. So I built my own:

- **Privacy-first** – Images stored locally on your own NAS, not someone else's cloud
- **Cost-effective** – ~€500-510 one-time, ~€10-20/year electricity (NAS Pi 4)
- **Hackable** – Full control over the software, camera settings, and AI integration
- **Educational** – Learn about Raspberry Pi, solar power, WiFi networking, and cloud AI

## How It Works

```
🏡 OUTDOOR (Birdhouse)               🏠 HOME (Indoor)              ☁️ CLOUD (Optional)
┌──────────────────┐                 ┌──────────────┐            ┌──────────┐
│  Camera Pi       │     WiFi        │  Home Router │            │   AWS    │
│  (Pi Zero 2 W)   │◄───────────────►│ 192.168.1.1  │            │Rekognition│
│                  │   (15m range)   └──────┬───────┘            │          │
│  📷 NoIR Camera  │                        │ Ethernet           │  🤖 AI   │
│  🔍 PIR Sensor   │                        ▼                    │          │
│  💡 IR LEDs      │                 ┌──────────────┐   WiFi     │          │
│  🔋 Solar Panel  │                 │   NAS Pi 4   │◄──────────►│          │
│     Battery      │                 │  (8GB RAM)   │            │          │
└──────────────────┘                 │ 💾 1TB SSD   │            └──────────┘
       ▲                             └──────────────┘
       │ 12V Power
       ☀️ Solar (50W)
```

1. **PIR sensor** detects motion near the birdhouse entrance
2. **NoIR Camera Module** captures high-resolution images (day & night)
3. **IR LEDs** illuminate at night for black & white night vision
4. Image transfers over **WiFi** to home NAS Pi 4 (15m range)
5. **NAS Pi 4** stores images locally on 1TB SSD
6. **AWS Rekognition** identifies bird species (optional cloud upload)
7. **Solar panel + battery** provides power year-round for camera

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🔍 Smart Detection | PIR sensor triggers capture only when birds are present |
| 📷 12MP NoIR Camera | High-quality autofocus images, day & night vision capable |
| 🌙 Night Vision | Motion-activated IR LEDs for black & white night capture |
| 📡 WiFi Connectivity | 15m wireless range, no cable routing needed |
| ☀️ Solar Powered | 50W panel + 12V battery, 4-7 days autonomy |
| 🌧️ Weatherproof | IP67 enclosure survives Finnish winters |
| 🤖 AI Species ID | AWS Rekognition identifies bird species (optional) |
| 💾 Local NAS Storage | WiFi upload to home Pi 4 with 1TB SSD (~500k images) |
| 💰 Low Running Cost | ~€10-20/year (NAS Pi 4 electricity, optional AWS) |

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/yves-steve/birdhouse-vision.git
cd birdhouse-vision

# Install dependencies
pip install -r requirements.txt

# Test camera capture (on Raspberry Pi)
python src/capture/camera.py
```

📖 **Full setup guide**: [docs/SETUP.md](docs/SETUP.md)

## 📖 Documentation

| Document | What's Inside |
|----------|---------------|
| [SETUP.md](docs/SETUP.md) | Complete setup guide: OS flashing, WiFi config, GPIO wiring |
| [HARDWARE.md](docs/HARDWARE.md) | Complete BOM with Finnish supplier links, component explanations |
| [BIRDHOUSE.md](docs/BIRDHOUSE.md) | Physical birdhouse options, DIY guides, battery placement |
| [COSTS.md](docs/COSTS.md) | Budget tracking (itemized costs, see file for totals) |
| [WIFI_VS_ETHERNET.md](docs/WIFI_VS_ETHERNET.md) | WiFi deployment guide (15m range, signal analysis) |

## 🗺️ Roadmap

| Phase | Status | Description |
|-------|--------|-------------|
| Hardware Research | ✅ Done | Component selection, WiFi vs PoE analysis |
| Camera Module | ✅ Done | NoIR camera with night vision capability |
| Solar Power System | ✅ Done | 50W panel, 12V battery, MPPT controller |
| Motion Detection | 🔄 In Progress | PIR sensor + relay for IR LED control |
| WiFi Upload | ⏳ Planned | Image transfer to home NAS/cloud |
| AWS Integration | ⏳ Planned | Rekognition for species ID (optional) |
| Web Gallery | ⏳ Planned | Browse captured images |
| Notifications | ⏳ Planned | Telegram/email alerts |
| Statistics | ⏳ Planned | Bird visit patterns dashboard |

## 🛠️ Development

### Prerequisites

- Raspberry Pi Zero 2 W with Camera Module 3 NoIR
- Python 3.9+
- AWS account (free tier works for testing, optional)

### Project Structure

```
birdhouse-vision/
├── src/
│   ├── capture/       # Camera capture and motion handling
│   ├── detection/     # PIR sensor + IR LED control
│   └── upload/        # WiFi upload to NAS/cloud (optional)
├── scripts/
│   ├── camera/        # Camera Pi automation scripts
│   └── nas/           # Optional NAS storage scripts
├── config/examples/   # Configuration templates
├── systemd/           # Systemd service and timer units
├── docs/              # Documentation
└── requirements.txt   # Python dependencies
```

### Running Tests

```bash
# Coming soon
pytest tests/
```

## ❓ FAQ

<details>
<summary><b>Why WiFi instead of PoE Ethernet?</b></summary>

WiFi is simpler and more flexible for this deployment:
- No cable routing through building walls (egress constraint)
- 15m unobstructed distance = excellent WiFi signal strength
- Easier relocation if needed
- Solar power eliminates need for PoE power delivery
- See [WIFI_VS_ETHERNET.md](docs/WIFI_VS_ETHERNET.md) for technical analysis
</details>

<details>
<summary><b>Why Pi Zero 2 W instead of Raspberry Pi 4?</b></summary>

Pi Zero 2 W is perfect for this use case:
- 80% less power consumption (15Wh/day vs 73Wh/day)
- Smaller solar panel needed (50W vs 100W)
- Sufficient performance for camera capture and motion detection
- €117 cheaper total system cost
- Compact size fits easily in birdhouse
</details>

<details>
<summary><b>Does it work at night?</b></summary>

Yes! The NoIR (No Infrared filter) camera combined with motion-activated 850nm IR LEDs provides clear black & white night vision. IR light is invisible to birds and humans, so it doesn't disturb wildlife.
</details>

<details>
<summary><b>Can I use a different cloud AI service?</b></summary>

Yes! The architecture is modular. You could swap AWS Rekognition for:
- Google Cloud Vision
- Azure Computer Vision
- Local inference with TensorFlow Lite (no cloud needed)
- Or skip AI entirely and just save images
</details>

<details>
<summary><b>What birds can it identify?</b></summary>

AWS Rekognition can identify most common bird species. Accuracy depends on image quality and how much of the bird is visible. Works best with clear, well-lit shots. Night vision images also work well for identification.
</details>

<details>
<summary><b>How long does the battery last?</b></summary>

With a 50W solar panel and 12V 10Ah battery:
- **Summer (May-Aug)**: Continuous operation with surplus charging
- **Winter (Dec-Jan)**: 4-7 days autonomy even without sun
- Motion-activated IR LEDs use minimal power (~30 min/night average)
</details>

## 🔒 Security

This repository includes automated security scanning for shell scripts:

- **ShellCheck Analysis**: All `.sh` and `.bash` files are checked for common issues and best practices
- **Malicious Pattern Detection**: Scans for potentially dangerous patterns like:
  - Remote code execution attempts
  - Suspicious downloads and data exfiltration
  - Credential theft patterns
  - System modification commands
  - Obfuscated or encoded commands

The security workflow runs automatically on all pull requests. If you're contributing shell scripts, ensure they pass the security checks. False positives (like legitimate SSH usage) are expected and will be manually reviewed.

## 🤝 Contributing

Contributions are welcome! Whether it's:
- 🐛 Bug reports
- 💡 Feature suggestions
- 📝 Documentation improvements
- 🔧 Code contributions

Please feel free to open an issue or submit a pull request.

**Note**: All shell scripts (`.sh`, `.bash`) will be automatically scanned for security issues. The workflow may flag false positives - these are reviewed manually during the PR process.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Raspberry Pi Foundation](https://www.raspberrypi.org/) for excellent hardware and documentation
- [picamera2](https://github.com/raspberrypi/picamera2) library maintainers
- Finnish bird watching community for inspiration
