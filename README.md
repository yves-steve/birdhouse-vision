# 🐦 Birdhouse Vision

AI-powered bird camera system using Raspberry Pi, motion detection, and AWS Rekognition.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.9+-green.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%204-red.svg)
![Status](https://img.shields.io/badge/status-in%20development-yellow.svg)

<!-- TODO: Add photo of birdhouse setup once built -->
<!-- ![Birdhouse Camera](docs/images/birdhouse-hero.jpg) -->

## Why This Project?

I wanted to see what birds visit my garden birdhouse without disturbing them. Commercial smart cameras are expensive, cloud-dependent, and not designed for birdhouses. So I built my own:

- **Privacy-first** – Images stored locally on my own NAS, not someone else's cloud
- **Cost-effective** – ~€500-600 one-time vs €200+/year for commercial solutions
- **Hackable** – Full control over the software, camera settings, and AI integration
- **Educational** – Learn about Raspberry Pi, PoE networking, and cloud AI

## How It Works

```
🏡 OUTDOOR (Birdhouse)              🏠 HOME (Indoor)              ☁️ CLOUD
┌──────────────────┐                ┌──────────────┐            ┌──────────┐
│  Camera Pi       │   Cat6 Cable   │   NAS Pi     │   WiFi     │   AWS    │
│  (Pi 4 8GB)      │◄──────────────►│  (Pi 4 4GB)  │◄──────────►│Rekognition│
│                  │   PoE Power    │              │            │          │
│  📷 Camera       │                │  💾 Storage  │            │  🤖 AI   │
│  🔍 PIR Sensor   │                │  ⚡ Processing│            └──────────┘
│  🔌 PoE+ HAT     │                └──────────────┘
└──────────────────┘
```

1. **PIR sensor** detects motion near the birdhouse entrance
2. **Camera Module 3** captures a high-resolution image
3. Image transfers over **PoE Ethernet** to the indoor NAS Pi
4. **AWS Rekognition** identifies the bird species
5. Results stored locally with a **web gallery** for browsing

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🔍 Smart Detection | PIR sensor triggers capture only when birds are present |
| 📷 12MP Camera | High-quality autofocus images, even in low light |
| 🔌 Single Cable | PoE delivers power + data through one Cat6 cable |
| 🌧️ Weatherproof | IP67 enclosure survives Finnish winters |
| 🤖 AI Species ID | AWS Rekognition identifies bird species automatically |
| 💾 Local Storage | 1TB SSD – your data stays with you |
| 💰 Low Running Cost | ~€18/year (electricity + AWS) |

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
| [SETUP.md](docs/SETUP.md) | OS flashing, SSH setup, software installation |
| [HARDWARE.md](docs/HARDWARE.md) | Complete BOM with Finnish supplier links & prices |
| [COSTS.md](docs/COSTS.md) | Budget tracking and running costs |
| [WIFI_VS_ETHERNET.md](docs/WIFI_VS_ETHERNET.md) | Why PoE beats WiFi for outdoor cameras |

## 🗺️ Roadmap

| Phase | Status | Description |
|-------|--------|-------------|
| Hardware Research | ✅ Done | Component selection, supplier sourcing |
| Camera Module | ✅ Done | Basic capture with picamera2 |
| Motion Detection | 🔄 In Progress | PIR sensor integration |
| AWS Integration | ⏳ Planned | Rekognition for species ID |
| Web Gallery | ⏳ Planned | Browse captured images |
| Notifications | ⏳ Planned | Telegram/email alerts |
| Statistics | ⏳ Planned | Bird visit patterns dashboard |

## 🛠️ Development

### Prerequisites

- Raspberry Pi 4 with Camera Module 3
- Python 3.9+
- AWS account (free tier works for testing)

### Project Structure

```
birdhouse-vision/
├── src/capture/       # Camera and motion detection
├── scripts/           # Utility scripts
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
<summary><b>Why two Raspberry Pis instead of one?</b></summary>

The outdoor camera Pi needs to be low-power and weatherproof. Keeping storage and processing indoors means:
- Less heat in the enclosure
- Easier SSD access for maintenance
- Camera Pi can be powered entirely via PoE
- If the outdoor unit fails, your data is safe indoors
</details>

<details>
<summary><b>Why PoE instead of WiFi?</b></summary>

PoE is more reliable than WiFi for outdoor use:
- No WiFi signal issues through walls/distance
- Single cable for power + data
- More stable connection in bad weather
- See [WIFI_VS_ETHERNET.md](docs/WIFI_VS_ETHERNET.md) for details
</details>

<details>
<summary><b>Can I use a different cloud AI service?</b></summary>

Yes! The architecture is modular. You could swap AWS Rekognition for:
- Google Cloud Vision
- Azure Computer Vision
- Local inference with TensorFlow Lite (no cloud needed)
</details>

<details>
<summary><b>What birds can it identify?</b></summary>

AWS Rekognition can identify most common bird species. Accuracy depends on image quality and how much of the bird is visible. Works best with clear, well-lit shots.
</details>

<details>
<summary><b>Does it work at night?</b></summary>

The Camera Module 3 has good low-light performance but no infrared. For night vision, you'd need to add IR LEDs and use the NoIR camera variant (a future enhancement).
</details>

## 🤝 Contributing

Contributions are welcome! Whether it's:
- 🐛 Bug reports
- 💡 Feature suggestions
- 📝 Documentation improvements
- 🔧 Code contributions

Please feel free to open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Raspberry Pi Foundation](https://www.raspberrypi.org/) for excellent hardware and documentation
- [picamera2](https://github.com/raspberrypi/picamera2) library maintainers
- Finnish bird watching community for inspiration
