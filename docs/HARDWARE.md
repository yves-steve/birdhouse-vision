
### **docs/HARDWARE.md**
```markdown
# Hardware Bill of Materials

Complete hardware list with Finnish supplier links and current prices (January 2026).

## Core Components

### Bird Camera Unit (Birdhouse)

| Component | Specification | Supplier | SKU/Link | Price | Status |
|-----------|--------------|----------|----------|-------|--------|
| **Raspberry Pi 4 Model B 8GB** | ARM Cortex-A72, 1.5GHz | [Farnell.fi](https://fi.farnell.com) | 3369503 | €90.92 | ✅ In Stock (5,790) |
| **Camera Module 3** | 12MP, 1080p, autofocus | [Verkkokauppa.com](https://www.verkkokauppa.com/fi) | - | €39.99 | ✅ In Stock |
| **PoE+ HAT** | 802.3at, 25W | [Electrokit.com](https://www.electrokit.com/en/raspberry-pi-poehat) | - | €35-40 | ✅ In Stock |
| **PIR Motion Sensor** | HC-SR501 | [Vapaakauppa.net](https://www.vapaakauppa.net/saadettava-pir-liiketunnistin-hc-sr501.html) | - | €5-8 | ✅ Available |
| **MicroSD Card** | Kingston 32GB High Endurance | [Verkkokauppa.com](https://www.verkkokauppa.com/fi/product/543269) | 543269 | €20.99 | ✅ In Stock |
| **Weatherproof Enclosure** | IP67, ~15×10×8cm | [Partco.fi](https://www.partco.fi) | - | €30-40 | ✅ Available |
| **Cable Glands** | M16, IP67 rated | [Partco.fi](https://www.partco.fi) | - | €10-15 | ✅ Available |

**Subtotal Camera Unit: ~€232-255**

## Development Tools

### SD Card Reader (for MacBook Pro)

#### Option 1: For MacBook Pro with Built-in SD Slot (2021+ M1/M2/M3 models)

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **microSD to SD Adapter** | Included with Kingston microSD cards | - | Free (included) | ✅ - |

**Note:** MacBook Pro 14" and 16" (2021 and newer) have built-in SD card slots. The Kingston High Endurance microSD cards listed above include a microSD to SD adapter in the package. Simply insert the microSD card into the adapter, then insert into your MacBook's built-in SD slot.

#### Option 2: For MacBook Pro without SD Slot (2016-2020 USB-C only models)

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **Anker USB-C SD Card Reader** | USB 3.0, UHS-I, USB-C connector | [Verkkokauppa.com](https://www.verkkokauppa.com) | €15-25 | ✅ Available |
| **Kingston USB-C microSD Reader** | USB 3.2, UHS-II support | [Verkkokauppa.com](https://www.verkkokauppa.com) | €12-18 | ✅ Available |
| **SanDisk microSD Reader** | USB-C, compact design | [Power.fi](https://www.power.fi) | €10-15 | ✅ Available |

**Note:** For flashing Raspberry Pi OS images to microSD cards from MacBook Pro (USB-C only). Choose a reader with UHS-I or UHS-II support for faster write speeds. All are plug-and-play with macOS.

#### HDMI Cable for Initial Setup

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **Micro HDMI to HDMI Cable** | 1-2m, for Pi 4 HDMI output | [Verkkokauppa.com](https://www.verkkokauppa.com) | €8-12 | ✅ Available |

**Note:** Raspberry Pi 4 uses micro HDMI ports (not full-size HDMI). Required for initial OS setup and troubleshooting. Can be shared between camera Pi and NAS Pi.

### Home NAS/Processing Unit

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **Raspberry Pi 4 Model B 4GB** | For NAS duties | [Multitronic.fi](https://www.multitronic.fi/fi/products/2379301) | €81.90 | ✅ Available |
| **MicroSD Card** | Kingston 32GB High Endurance (for OS) | [Verkkokauppa.com](https://www.verkkokauppa.com/fi/product/543269) | €20.99 | ✅ In Stock |
| **Official Power Supply** | USB-C, 15W | Verkkokauppa.com | €15-20 | ✅ Available |
| **Case** | Standard Pi 4 case | Verkkokauppa.com | €8-12 | ✅ Available |
| **Cat6 Network Cable** | 1m patch cable | [Verkkokauppa.com](https://www.verkkokauppa.com) | €3-5 | ✅ Available |

#### Storage Options (choose one)

| Option | Component | Specification | Supplier | Price | Status |
|--------|-----------|--------------|----------|-------|--------|
| **A** | **Samsung T7 Shield 500GB SSD** | USB 3.2 portable SSD (USB-C) | [Verkkokauppa.com](https://www.verkkokauppa.com/fi) | €79-89 | ✅ Available |
| **A** | **Samsung T7 Shield 1TB SSD** | USB 3.2 portable SSD (USB-C) | [Verkkokauppa.com](https://www.verkkokauppa.com/fi/product/1003900) | €148.99 | ⚠️ 2-4 weeks |
| **B** | **Kingston A400 960GB SSD** | 2.5" SATA III, 500/450 MB/s R/W | [Jimms.fi](https://www.jimms.fi) | €55-65 | ✅ Available |
| **B** | **SATA to USB 3.0 Adapter** | USB 3.0, UASP support | [Jimms.fi](https://www.jimms.fi) | €10-15 | ✅ Available |

**Option A (Portable USB SSD):** Plug-and-play, compact, no adapter needed. Higher cost per GB. The Samsung T7 includes both USB-C to USB-C and USB-C to USB-A cables in the box, so it connects directly to the Pi 4's USB 3.0 Type-A ports.

**Option B (SATA SSD + Adapter) - Recommended:** Best value for money. The Kingston A400 960GB offers nearly 1TB storage at a fraction of the cost of portable SSDs. Requires a SATA to USB 3.0 adapter cable (~€12). The 500/450 MB/s speeds are more than sufficient for the Pi 4's USB 3.0 interface.

**Note:** The Raspberry Pi 4 has 2× USB 3.0 Type-A ports (blue) and 2× USB 2.0 Type-A ports. Always connect your SSD to one of the USB 3.0 ports for best performance (~400 MB/s vs ~40 MB/s on USB 2.0).

**Subtotal NAS Unit:**
- With 500GB portable SSD: ~€208-230
- With 1TB portable SSD: ~€278-289
- With Kingston A400 960GB + adapter: ~€195-215

**Note:** The NAS Pi connects to home router via short Cat6 cable (1m). The outdoor camera Pi uses the 50m Cat6 cable listed in Networking & Power section.

### Networking & Power

| Component | Specification | Supplier | Price | Notes |
|-----------|--------------|----------|-------|-------|
| **PoE Injector** | 802.3af/at, 48V | [Verkkokauppa.com](https://www.verkkokauppa.com/fi) | €15-25 | - |
| **Cat6 Outdoor Cable** | 50m, direct burial | [Taloon.com](https://www.taloon.com) | €40-50 | UV resistant |
| **RJ45 Connectors** | Weatherproof IP67 | [Partco.fi](https://www.partco.fi) | €12-15 | For outdoor connection |

**Subtotal Networking: ~€67-90**

## Finnish Supplier Details

### 🇫🇮 Farnell Finland (fi.farnell.com)
- **Official Raspberry Pi Distributor**
- Free shipping on orders over €75 (ex VAT) = €93 with VAT
- Delivery: 3-5 business days to Posti pickup
- Industrial component focus
- Trade accounts available

**Recommended for:** Raspberry Pi boards (best prices)

### 🇫🇮 Verkkokauppa.com
- **Finland's largest electronics retailer**
- Free shipping on orders over €100
- Posti Smartpost pickup available
- 14-day return policy
- Location: Tammiston kauppatie 7, Vantaa

**Recommended for:** Cameras, HATs, accessories, portable SSDs

### 🇫🇮 Jimms.fi
- **Popular Finnish PC and electronics retailer**
- Free shipping on orders over €100
- Wide selection of PC components, storage drives, and adapters
- Good stock of SSDs and accessories
- Posti and Matkahuolto pickup available

**Recommended for:** SATA SSDs, SATA to USB adapters, PC components

### 🇫🇮 Multitronic.fi
- **5 stores across Finland** (Vaasa, Pietarsaari, Jyväskylä, Lappeenranta, Ahvenanmaa)
- Competitive Pi board pricing
- "Available from supplier" = 1-3 day wait

**Recommended for:** Alternative Pi boards if Farnell out of stock

### 🇫🇮 Data-Systems.fi (Espoo)
- Industrial/business focus
- Good Pi stock levels
- Location: Kuusiniementie 8, Espoo

### 🇫🇮 Elektrolinna.fi (Hämeenlinna)
- Small electronics specialty shop
- May have niche components
- Contact for availability

### 🇫🇮 Partco.fi (Helsinki)
- **Electronics components specialist**
- Good stock of sensors, enclosures, connectors
- Free shipping on orders over €100
- Location: Atomitie 5, Helsinki

**Recommended for:** PIR sensors, enclosures, cable glands, connectors

### 🇫🇮 Taloon.com
- **Building supplies and cables**
- Wide range of outdoor-rated cables
- Nationwide delivery

**Recommended for:** Cat6 outdoor cables, weatherproof supplies

### 🇫🇮 Vapaakauppa.net
- **Finnish electronics hobbyist shop**
- Good prices on sensors and modules
- Fast domestic shipping

**Recommended for:** PIR sensors, Arduino/Raspberry Pi accessories

### 🇩🇰 Electrokit.com (Sweden/Denmark)
- **Nordic electronics specialist**
- Good Raspberry Pi accessory stock including PoE HATs
- Ships to Finland, reasonable shipping costs
- Often better availability than Finnish retailers

**Recommended for:** PoE HATs, Raspberry Pi accessories when out of stock locally

## Total Project Cost

| Category | Cost Range (EUR) |
|----------|------------------|
| Bird Camera Unit | €240-270 |
| NAS Unit (with Kingston A400 960GB) | €195-215 |
| NAS Unit (with 1TB portable SSD) | €278-305 |
| Networking & Power | €67-90 |
| Development Tools | €8-12 |
| **Hardware Total (budget)** | **€510-587** |
| **Hardware Total (premium)** | **€593-677** |
| | |
| **Recurring (Year 1):** | |
| Electricity (6 kWh/month) | €14.40 |
| AWS Rekognition | €3.60 |
| **Annual Recurring** | **€18** |

### Cost Optimization

**Savings from mix-and-match strategy:**
- Pi 4 8GB from Farnell (€90.92) vs Verkkokauppa (€109.99) = **Save €19**
- Multitronic Pi 4 4GB (€81.90) vs others = **Save €8-20**

**Budget Option:**
- Use Pi 4 4GB for NAS instead of 8GB: Save €20
- Use Kingston A400 960GB + adapter instead of 1TB portable SSD: Save €80-90
- **Minimum viable: ~€510**

## Alternative Components

### If Out of Stock

| Primary | Alternative | Supplier | Price Difference |
|---------|------------|----------|------------------|
| Pi 4 8GB (Farnell) | Pi 4 8GB (Verkkokauppa) | Verkkokauppa | +€19 |
| Pi 4 8GB | Pi 5 8GB | Data-Systems | +€24 (faster!) |
| Camera Module 3 | Pi HQ Camera | Verkkokauppa | +€20 (better quality) |
| PoE+ HAT (Verkkokauppa) | PoE+ HAT | Electrokit.com | -€5 (better availability) |
| PIR Motion Sensor HC-SR501 (Vapaakauppa.net) | PIR Sensor (Partco) | Partco.fi | ≈same price (check current listing) |

## Purchasing Strategy

### Recommended Order Sequence

**Order 1 - Farnell.fi (Week 1):**
- 1× Raspberry Pi 4 8GB (€90.92)
- Small items to reach free shipping threshold (€93+)

**Order 2 - Verkkokauppa.com (Week 1):**
- 1× Camera Module 3 (€39.99)
- 2× Kingston microSD 32GB (€20.99 each) - one for camera Pi, one for NAS Pi
- 1× PoE Injector (~€20)
- 1× Micro HDMI to HDMI Cable (~€10)
- 1× Cat6 1m patch cable (~€4)
- (Optional) 1× Samsung T7 500GB/1TB (~€85/€149) if choosing portable SSD
- Total: €116-265 → Free shipping (orders over €100)

**Order 3 - Jimms.fi (Week 1):**
- 1× Kingston A400 960GB SSD (~€60)
- 1× SATA to USB 3.0 adapter (~€12)
- Total: ~€72 (or add items to reach €100 free shipping)

**Order 4 - Electrokit.com (Week 1):**
- 1× PoE+ HAT (~€37)
- Ships from Nordic warehouse

**Order 4 - Vapaakauppa.net (Week 1):**
- 1× PIR Motion Sensor HC-SR501 (~€6)

**Order 5 - Partco.fi (Week 1):**
- 1× Weatherproof Enclosure (~€35)
- 1× Cable Glands set (~€12)
- Total: ~€47 (consider adding RJ45 connectors or other Partco items to approach the ~€100 free-shipping threshold)

**Order 7 - Taloon.com (Week 1):**
- 1× Cat6 Outdoor Cable 50m (~€45)

### Delivery Timeline

- **Week 1**: Order from all Finnish suppliers
- **Week 2**: Receive in-stock items (Pi 4, Camera, microSD, sensors, cables)
- **Week 3-4**: Receive backorder items (SSD)

**Can start development** with Pi 4 + Camera + microSD while waiting for PoE components.

## Notes

- All prices include 24% Finnish VAT
- Prices accurate as of January 19, 2026
- Check supplier websites for current stock levels
- Consider ordering PoE components early (2-4 week lead time)