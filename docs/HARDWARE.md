
# Hardware Bill of Materials

Complete hardware list with Finnish suppliers (February 2026).

## WiFi Deployment (15m, Unobstructed) - CURRENT BUILD

### Camera Unit (Birdhouse) - Night Vision Capable

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **Raspberry Pi Zero 2 W H** | 1GHz quad-core, WiFi, pre-soldered header | Verkkokauppa / Partco | €19.90 | ✅ In Stock |
| **Camera Module 3 NoIR** | 12MP, no IR filter (night vision) | Verkkokauppa | €30.90 | ✅ In Stock |
| **Camera Cable (15cm)** | Pi Zero compatible | Verkkokauppa | €4.90 | ✅ In Stock |
| **PIR Motion Sensor** | HC-SR501, 3.3V | Partco.fi | €7.50 | ✅ Available |
| **IR LED Spotlight** | 850nm, 12V 3W | Partco.fi / Electro:Kit | €15-18 | ✅ Available |
| **Relay Module** | 1-channel, 3.3V-compatible trigger | Partco.fi / Electro:Kit | €5.90 | ✅ Available |
| **MicroSD Card** | Kingston 32GB | Verkkokauppa | €9.90 | ✅ In Stock |
| **IP67 Weatherproof Case** | Junction box ~160×120×80mm | Partco.fi / Biltema | €12-15 | ✅ Available |
| **Cable Glands** | M12/M16, IP67 | Partco.fi / Biltema | €8-10 | ✅ Available |
| **Jumper Wires** | Female-female, 20cm | Partco.fi | €3.50 | ✅ In Stock |

**Subtotal Camera Unit: ~€118-130**

**Component Notes:**
- **NoIR Camera**: "No Infrared filter" - removes the IR-blocking filter found in normal cameras. Allows the camera to see infrared light from IR LEDs for night vision (images appear black & white at night).
- **PIR Motion Sensor**: Passive Infrared sensor. Detects motion by sensing changes in infrared radiation (body heat). Triggers camera and IR LEDs when birds approach.
- **IR LED Spotlight**: Infrared light emitting diode. Emits 850nm wavelength light (invisible to birds and humans) that illuminates the scene for the NoIR camera at night.
- **Relay Module**: Electronic switch that lets the Pi's low-voltage GPIO (3.3V logic) control high-voltage devices (12V IR LEDs). **IMPORTANT**: Raspberry Pi GPIO pins are 3.3V logic and are NOT 5V tolerant. Ensure your relay module has a 3.3V-compatible trigger input, or use a proper level shifter/transistor driver circuit to avoid damaging the Pi.
- **IP67 Weatherproof Case**: Ingress Protection rating 67 = dust-tight and protected against water immersion up to 1 meter for 30 minutes. Essential for outdoor use.
- **Cable Glands**: Waterproof cable entry points for the weatherproof case. Seal around wires to maintain IP67 rating.
- **Jumper Wires**: Pre-crimped wires for connecting PIR sensor and relay to Pi's GPIO header pins. No soldering required.

### Power System (Solar - Motion-Activated IR)

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **Solar Panel** | 50W monocrystalline | Biltema | €55.00 | ✅ In Stock |
| **LiFePO4 Battery** | 12V 10Ah (120Wh) | Vapaakauppa.net | €50.00 | ✅ Available |
| **MPPT Charge Controller** | 10A, 12V | Partco.fi | €22.00 | ✅ Available |
| **Buck Converter** | 12V→5V 2.5A USB-C | Partco.fi | €15.00 | ✅ Available |
| **MC4 Connectors** | Panel to controller | Biltema | €8.00 | ✅ Available |
| **Solar Mount** | Adjustable angle | Biltema | €8.00 | ✅ Available |

**Subtotal Power System: ~€158**

**Component Notes:**
- **LiFePO4 Battery**: Lithium Iron Phosphate battery chemistry. Safer than standard lithium-ion, works in cold weather (Finland winters), lasts 3000+ charge cycles (5-10 years lifespan).
- **MPPT Charge Controller**: Maximum Power Point Tracking controller. Intelligently adjusts solar panel voltage to extract maximum power and charge battery efficiently (20-30% more efficient than basic controllers).
- **Buck Converter**: Voltage step-down converter. Converts 12V battery power to 5V USB-C for powering the Raspberry Pi Zero. More efficient than linear regulators (less heat waste).
- **MC4 Connectors**: Industry-standard weatherproof solar panel connectors. Snap-lock design, IP67 rated, UV resistant. Used to connect solar panel to MPPT controller.

### Home Storage (NAS at Router)

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **Raspberry Pi 4 Model B (8GB)** | Home NAS server | Verkkokauppa | €90.92 | ✅ In Stock |
| **USB-C Power Supply** | Official Pi PSU, 5V 3A | Verkkokauppa | €9.90 | ✅ In Stock |
| **1TB NVMe SSD** | Kingston NV2 | Jimms.fi | €79.90 | ✅ In Stock |
| **USB 3.0 to NVMe Adapter** | Axagon EEM2-UG2 | Jimms.fi | €20.00 | ✅ Available |
| **MicroSD Card** | Kingston 32GB (boot) | Verkkokauppa | €9.90 | ✅ In Stock |
| **Cooling** | Passive aluminum case | Verkkokauppa | €12.90 | ✅ In Stock |

**Subtotal Home NAS: ~€223**

**Component Notes:**
- **Pi 4 Model B (8GB)**: More powerful Pi model for running file server (NAS = Network Attached Storage). Receives images over WiFi from camera Pi, stores locally before optional cloud upload.
- **NVMe SSD**: Non-Volatile Memory Express solid-state drive. Much faster than SD cards or USB flash drives (2000+ MB/s read/write). Stores 1TB = ~500,000 bird images.
- **USB 3.0 Adapter**: Connects NVMe SSD to Pi 4's USB port. USB 3.0 provides 5Gbps transfer speed (vs 480Mbps on USB 2.0).

## Total Project Cost

| Category | Cost |
|----------|------|
| **Camera Unit (WiFi + Night Vision)** | **€118-130** |
| **Power System (Solar)** | **€158** |
| **Home NAS (Optional)** | **€223** |
| **Hardware Total (Complete System)** | **€499-511** |
| **Hardware Total (Camera Only)** | **€276-313** |
| **Recurring (Annual):** | |
| Electricity (Pi 4 NAS at home) | €10-15 |
| Electricity (solar camera) | €0-5 |
| **Annual Cost** | **€10-20** |

---

## Finnish Suppliers

### 🇫🇮 Verkkokauppa.com
- Finland's largest electronics retailer
- Free shipping €100+
- Location: Tammiston kauppatie 7, Vantaa
- **Recommended for:** Pi Zero, NoIR camera, microSD

### 🇫🇮 Jimms.fi
- Computer parts & electronics specialist
- Free shipping €150+
- Location: Kuopio (online nationwide)
- **Recommended for:** NVMe SSDs, USB adapters, PC components

### 🇫🇮 Partco.fi (Helsinki)
- Electronics components specialist
- Free shipping €100+
- Location: Atomitie 5, Helsinki
- **Recommended for:** PIR, IR LEDs, relays, enclosures, glands

### 🇫🇮 Vapaakauppa.net
- Electronics hobbyist shop
- Competitive battery/sensor prices
- **Recommended for:** LiFePO4 batteries, PIR sensors

### 🇫🇮 Biltema
- Building/DIY supplies
- Solar panels, mounts, weatherproof boxes
- Multiple locations
- **Recommended for:** Solar panels, junction boxes, MC4 connectors

### 🇫🇮 Bauhaus
- Building & DIY
- Weatherproof enclosures, sealants
- **Recommended for:** IP67 cases, weatherproofing

### 🇸🇪 Electro:Kit (Nordic, ships to Finland)
- Nordic electronics specialist
- **Recommended for:** Pi Zero, IR LEDs, relays (stock alternatives)