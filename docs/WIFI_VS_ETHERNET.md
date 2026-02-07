# WiFi vs Ethernet: Technical Analysis

## Project Status Update

**Decision: WiFi (Wireless) Deployment**

After site assessment (15m from router, no tree obstruction), the project has pivoted from PoE Ethernet to WiFi connectivity with the following rationale.

---

## Original Analysis: 50m PoE Ethernet

At 50 meters through trees, WiFi is **not viable**:
- Signal loss: 40–65 dB (trees + distance + weather)
- Seasonal variation: ±25 dB (winter vs summer foliage)
- Reliability: 60–80% uptime vs Ethernet's 99.9%

**Original decision**: PoE Ethernet provides power + data in one cable with zero weather dependency.

---

## Revised Deployment: 15m WiFi

### Signal Strength (15m, Unobstructed)

| Factor | Loss (dB) | Notes |
|--------|-----------|-------|
| Free space path loss (2.4 GHz, 15 m) | 64 dB | 15 m unobstructed (FSPL ≈ 63.6 dB) |
| Wall penetration (1–2 walls) | 4 to 8 dB | Standard brick/wood |
| **Total 2.4 GHz path loss** | **68 to 72 dB** | ✅ Excellent signal margin |

**Expected performance:**
- Signal strength: −55 to −65 dBm (excellent to good)
- Upload speed: 10–20 Mbps (sufficient for image upload)
- Latency: 5–15 ms
- Reliability: >95% uptime

### Why WiFi works here
1. ✅ Short distance (15m vs original 50m)
2. ✅ No tree obstruction
3. ✅ Sufficient bandwidth for image uploads
4. ✅ Eliminates cable routing constraints

---

## Hardware Configuration (Current)

### Camera Unit
- **Raspberry Pi Zero 2 W H** (pre-soldered GPIO header)
- **Camera Module 3 NoIR** (night vision capable)
- **PIR motion sensor** (HC-SR501, GPIO-triggered)
- **IR LED spotlight** (850 nm, 12 V, motion-activated)
- **Relay module** (switches 12 V IR power) — *Supplier confirmation pending*
- **IP67 weatherproof case** — *Supplier confirmation pending*

### Power System (Solar)
- **30–50 W solar panel** (motion-activated IR budget)
- **12 V 10–20 Ah LiFePO4 battery**
- **MPPT charge controller** (10–20 A)
- **Buck converter** (12 V → 5 V USB-C)

### Connectivity
- **WiFi 802.11n (2.4 GHz)** — Built-in to Pi Zero 2 W
- **No Ethernet cable required** (solves building egress problem)

---

## Power Budget (Motion-Activated IR Night Vision)

### Daily Consumption
```
Daytime (12h):        6 Wh
Nighttime idle (12h): 6.6 Wh
Night motion (30 min): 2.4 Wh
Total daily:          ~15 Wh
```

### Solar Generation (50 W panel, Finland winter)
- December: 25–50 Wh/day
- January: 42 Wh/day
- **Status**: ✅ Adequate for motion-activated IR

---

## System Advantages vs PoE

| Aspect | PoE (50m) | WiFi (15m) |
|--------|-----------|-----------|
| Cable routing | Complex | ✅ None required |
| Building egress | Problem | ✅ Solved |
| Weather dependency | Zero | Minimal (2.4 GHz penetration) |
| Installation | Requires conduit | ✅ Simpler |
| Cost | €240+ (PoE switch) | Lower (standard router) |
| Future relocation | Difficult (cable) | ✅ Easy (WiFi) |

---

## Pending Items

- **Relay module**: Supplier confirmation in progress
- **Weatherproof case**: Sourcing IP67 junction box (160×120×80 mm minimum)

Once confirmed, full assembly instructions will be provided.

---

## Conclusion

WiFi at 15m unobstructed provides reliable connectivity without cable infrastructure, solving the original building egress constraint while maintaining system reliability and reducing installation complexity.