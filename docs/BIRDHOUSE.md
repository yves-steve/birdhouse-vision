# The Birdhouse

Before setting up cameras and sensors, you need a birdhouse! This guide covers buying options in Finland and DIY building resources.

## Quick Links

| Need | Resource |
|------|----------|
| 🛒 Buy ready-made | [Purchase Options](#buying-a-birdhouse) |
| 🔨 Build your own | [DIY Resources](#building-your-own) |
| 📷 Camera fit | [Camera-Ready Requirements](#camera-ready-requirements) |
| 🪵 Materials | [Finnish Suppliers](#diy-materials--suppliers) |

---

## Buying a Birdhouse

### Finnish Retailers

Ready-made birdhouses suitable for camera installation:

| Retailer | Product | Price | Hole Size | Dimensions | Language | Link |
|----------|---------|-------|-----------|------------|----------|------|
| Biltema | Fir wood birdhouse | €9.95 | 50mm | 18×19×43cm | EN/FI | [View](https://www.biltema.fi/en-fi/leisure/garden/birds/birdhouses/birdhouse-43-cm-2000054661) |
| Zooplus | TIAKI Log Cabin | €8.99 | - | 17×12.5×26cm | EN | [View](https://www.zooplus.com/shop/birds/wild_birds/bird_houses/2146795?activeVariant=2146795.0) |
| Zooplus | TIAKI Green Box | €11.99 | - | 16×13.5×26cm | EN | [View](https://www.zooplus.com/shop/birds/wild_birds/bird_houses/2151030?activeVariant=2151030.0) |
| Kärkkäinen | Painted birdhouse | €15.95 | 28mm | - | EN/FI | [View](https://www.karkkainen.com/en-en/homemade-birdhouse) |

### What to Look For

When buying a birdhouse for camera installation:

- ✅ **Interior space**: Minimum 15×15×25cm for camera module + Pi enclosure
- ✅ **Access panel**: Rear or side opening for maintenance and cable routing
- ✅ **Entrance hole**: Size determines which birds visit (see [Species Guide](#entrance-hole-sizes))
- ✅ **Wood thickness**: ≥13mm for insulation (Finnish winters!)
- ✅ **Drainage**: Small holes in floor to prevent water accumulation
- ✅ **Untreated interior**: No paint/varnish inside (toxic to birds)

### Entrance Hole Sizes

| Hole Diameter | Species (Finnish/English) |
|---------------|---------------------------|
| 26-28mm | Sinitiainen / Blue Tit, Kuusitiainen / Coal Tit |
| 32mm | Talitiainen / Great Tit, Kirjosieppo / Pied Flycatcher |
| 34mm | Punarinta / Robin |
| 45-50mm | Kottarainen / Starling |
| 80-100mm | Telkkä / Goldeneye (duck) |

---

## Building Your Own

### Finnish Resources (Suomenkielinen)

**BirdLife Finland** (Suomen BirdLife) provides comprehensive guides:

| Resource | Finnish Name | Description |
|----------|--------------|-------------|
| [Main Guide](https://www.birdlife.fi/lintuharrastus/linnunpontot/) | Linnunpöntöt | Overview of nest boxes (*linnunpönttö* = nest box) |
| Templates & Dimensions | Mallit ja mitat | Species-specific measurements |
| Materials & Building | Materiaalit ja rakentaminen | Wood types, tools, construction tips |
| Mounting & Maintenance | Ripustaminen ja huolto | How to hang and clean your box |
| Predator Protection | Näädältä suojattu linnunpönttö | Marten-proof designs |

> 💡 **Finnish Vocabulary**
> - *linnunpönttö* – nest box / birdhouse
> - *pesälaatikko* – nesting box
> - *sisäänkäyntiaukko* – entrance hole
> - *pesäpohja* – nest floor
> - *puhdistusluukku* – cleaning hatch

### English Resources

If you prefer English instructions:

| Resource | Organization | Description |
|----------|--------------|-------------|
| [Nest Box Plans](https://www.rspb.org.uk/helping-nature/nest-box-plans) | RSPB (UK) | Downloadable PDF plans for various species |
| [Build a Birdhouse](https://www.audubon.org/news/how-build-birdhouse) | Audubon (US) | Step-by-step guide with diagrams |
| [Instructables](https://www.instructables.com/howto/birdhouse/) | Community | DIY projects with photos |

### Recommended DIY Dimensions

For a camera-ready birdhouse compatible with this project:

```
        ┌────────────────────┐
        │    Removable Lid   │
        │   (for cleaning)   │
        └────────────────────┘
                 │
        ┌────────▼───────────┐
        │                    │  ← 30-35cm height (interior)
        │   ┌──────────┐     │
        │   │  Camera  │     │  ← Mount camera near roof,
        │   │  Module  │     │    angled down at entrance
        │   └──────────┘     │
        │                    │
        │       ○            │  ← Entrance hole (species-specific)
        │                    │
        │   [ Nest area ]    │  ← 15×15cm minimum floor space
        │                    │
        └────────┬───────────┘
                 │
        ┌────────▼───────────┐
        │   Drainage holes   │
        │    (3-4 × 6mm)     │
        └────────────────────┘
        
Interior width:  15-18cm
Interior depth:  15-18cm
Interior height: 30-35cm
Wall thickness:  15-20mm (untreated wood)
```

### Cable Routing

Plan for the PoE cable before building:

```
        ┌─────────────────────────┐
        │         Roof            │
        │                    ●────┼──── Cable entry (rear, top)
        └─────────────────────────┘     Sealed with silicone
        │                         │
        │    Camera + Pi mount    │
        │    ┌───────────────┐    │
        │    │ Weatherproof  │    │
        │    │   enclosure   │────┼──── Cable runs down inside
        │    └───────────────┘    │     wall (hidden)
        │                         │
```

---

## Camera-Ready Requirements

### Minimum Interior Dimensions

To fit the Raspberry Pi + Camera Module 3 + weatherproof enclosure:

| Component | Dimensions | Notes |
|-----------|------------|-------|
| Pi Camera Module 3 | 25×24×11.5mm | Sensor only |
| Camera + ribbon cable | ~100mm reach | Standard 15cm cable recommended |
| Weatherproof Pi enclosure | ~90×60×30mm | Varies by model |
| **Total camera assembly** | ~120×70×50mm | Allow extra clearance |

**Recommendation**: Interior width/depth of at least **15cm** to fit camera assembly without blocking the nest area.

### Access Panel Considerations

Your birdhouse needs easy access for:

1. **Annual cleaning** (remove old nests after breeding season)
2. **Camera maintenance** (adjust angle, clean lens)
3. **Cable routing** (PoE cable entry point)
4. **SD card access** (if not using network storage)

**Best design**: Hinged or removable roof/side panel with weather seal.

### Mounting the Camera

Position the camera to capture birds at the entrance:

```
Side View:
                    ┌─────┐
                    │Cam 3│ ← Angled 30-45° down
                    └──┬──┘
                       │
                       ▼
    ════════════════════════════  ← Entrance level
                       ●
                    Entrance
                      hole
```

- Mount camera **10-15cm above** the entrance hole
- Angle lens **30-45° downward** to capture arriving birds
- Use **wide-angle** setting if available (Camera Module 3 has 75° FoV)
- Ensure **no IR reflection** from internal surfaces

---

## DIY Materials & Suppliers

### Finnish Hardware Stores

For building materials (wood, screws, hinges):

| Store | Specialty | Website |
|-------|-----------|---------|
| K-Rauta | General hardware, wood | [k-rauta.fi](https://www.k-rauta.fi) |
| Bauhaus | Building materials | [bauhaus.fi](https://www.bauhaus.fi) |
| Stark | Wood, tools | [stark-suomi.fi](https://www.stark-suomi.fi) |
| Puuilo | Budget hardware | [puuilo.fi](https://www.puuilo.fi) |
| Motonet | Outdoor/DIY | [motonet.fi](https://www.motonet.fi) |

### Recommended Materials

| Material | Finnish Term | Notes |
|----------|--------------|-------|
| Untreated pine | Käsittelemätön mänty | Most common, affordable |
| Untreated spruce | Käsittelemätön kuusi | Lighter weight |
| Plywood (exterior) | Vaneri (ulkokäyttö) | For roof, at least 12mm |
| Galvanized screws | Sinkityt ruuvit | Rust-resistant |
| Brass hinges | Messinki saranat | For access panel |
| Silicone sealant | Silikoni tiiviste | For cable entry waterproofing |

### Wood Treatment

- **Interior**: Leave **untreated** (paint/varnish is toxic to birds)
- **Exterior**: Use bird-safe wood preservative or linseed oil (*pellavaöljy*)
- **Roof**: Can use tar paper (*kattohuopa*) for extra weatherproofing

---

## Species-Specific Designs

### Common Finnish Garden Birds

| Species | Finnish Name | Hole (mm) | Floor (cm) | Height (cm) | Mounting |
|---------|--------------|-----------|------------|-------------|----------|
| Blue Tit | Sinitiainen | 26-28 | 12×12 | 25-28 | 2-4m, tree/wall |
| Great Tit | Talitiainen | 32 | 12×12 | 25-28 | 2-4m, tree/wall |
| Pied Flycatcher | Kirjosieppo | 32-34 | 12×12 | 25-28 | 2-5m, tree |
| Starling | Kottarainen | 45-50 | 15×15 | 30-35 | 3-5m, tree/building |
| House Sparrow | Varpunen | 32-34 | 14×14 | 25-30 | Under eaves |

> 📚 **More species**: See [BirdLife Finland's complete guide](https://www.birdlife.fi/lintuharrastus/linnunpontot/)

---

## Next Steps

Once you have your birdhouse ready:

1. → [HARDWARE.md](HARDWARE.md) – Electronics and components to order
2. → [SETUP.md](SETUP.md) – Software installation and configuration
3. → [COSTS.md](COSTS.md) – Budget tracking for the full project
