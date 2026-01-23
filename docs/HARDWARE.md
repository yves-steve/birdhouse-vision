
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

**Subtotal Camera Unit: ~€240-270**

### Home NAS/Processing Unit

| Component | Specification | Supplier | Price | Status |
|-----------|--------------|----------|-------|--------|
| **Raspberry Pi 4 Model B 4GB** | For NAS duties | [Multitronic.fi](https://www.multitronic.fi/fi/products/2379301) | €81.90 | ✅ Available |
| **Samsung T7 Shield 1TB SSD** | USB 3.2, rugged | [Verkkokauppa.com](https://www.verkkokauppa.com/fi/product/1003900) | €148.99 | ⚠️ 2-4 weeks |
| **Official Power Supply** | USB-C, 15W | Verkkokauppa.com | €15-20 | ✅ Available |
| **Case** | Standard Pi 4 case | Verkkokauppa.com | €8-12 | ✅ Available |

**Subtotal NAS Unit: ~€255-280**

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

**Recommended for:** Cameras, HATs, accessories, SSDs

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
| NAS Unit | €255-280 |
| Networking & Power | €67-90 |
| **Hardware Total** | **€562-640** |
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
- Skip Samsung T7 SSD, use external HDD: Save €60-90
- **Minimum viable: ~€430**

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
- 1× Kingston microSD 32GB (€20.99)
- 1× Samsung T7 1TB (€148.99)
- 1× PoE Injector (~€20)
- Total: €229.97 → Free shipping

**Order 3 - Electrokit.com (Week 1):**
- 1× PoE+ HAT (~€37)
- Ships from Nordic warehouse

**Order 4 - Vapaakauppa.net (Week 1):**
- 1× PIR Motion Sensor HC-SR501 (~€6)

**Order 5 - Partco.fi (Week 1):**
- 1× Weatherproof Enclosure (~€35)
- 1× Cable Glands set (~€12)
- Total: ~€47 (consider adding RJ45 connectors or other Partco items to approach the ~€100 free-shipping threshold)

**Order 4 - Taloon.com (Week 1):**
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