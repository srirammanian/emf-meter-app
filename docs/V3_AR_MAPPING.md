# EMF Meter V3.0 - AR Spatial Mapping Feature

**Date:** January 28, 2026  
**Status:** Concept  
**Priority:** High  
**Tier:** Premium Feature (IAP)

---

## 🎯 Feature Overview

Add augmented reality-based spatial mapping to visualize EMF field intensity across a physical space. Users can walk through a room while the app tracks their position and builds a 2D heat map showing EMF sources and intensity distribution.

**Tagline:** "See where the EMF is coming from, not just how strong it is."

---

## 💡 Core Concept

### Problem
Current EMF apps (including V2.0) only show the current reading at your exact location. Users can't:
- Identify the source direction
- Map multiple sources in a room
- Visualize field distribution spatially
- Rule out interference systematically (paranormal investigation use case)

### Solution
Use device AR capabilities (ARKit/ARCore) to:
1. Track user position and orientation as they move
2. Sample EMF readings continuously
3. Build a spatial heat map
4. Visualize as a vintage-style 2D radar map

---

## 🎮 Visual Design

### Aesthetic Direction
**Vintage Radar / CRT Terminal Style**

Options:
1. **Green Phosphor Radar** - Classic oscilloscope green on black
2. **Amber CRT Terminal** - Retro computer monitor aesthetic  
3. **Blue Blueprint** - Technical drawing style
4. **Multi-color Heat Map** - Modern heat map overlay on floor plan

**Recommended:** Green phosphor radar for consistency with vintage Geiger counter theme

### UI Elements
- Top-down 2D map view of scanned area
- User position indicator (pulsing dot)
- EMF intensity visualized as:
  - Color gradient (green → yellow → orange → red)
  - Contour lines (like topographic maps)
  - Grid cells with intensity values
- Identified "hot spots" marked with icons
- Scan progress indicator
- "Clear Map" and "Export Map" buttons

---

## 🛠️ Technical Implementation

### AR Framework
| Platform | Technology | Min Version |
|----------|-----------|-------------|
| iOS | ARKit | iOS 13.0+ |
| Android | ARCore | Android 7.0+ (API 24) |

### Data Collection

**Sampling Strategy:**
```
while (user_is_scanning) {
    position = AR.getCurrentPosition()  // (x, y, z) in meters
    orientation = AR.getOrientation()   // (pitch, yaw, roll)
    emf_reading = magnetometer.getCurrentReading()
    
    data_point = {
        position: position,
        timestamp: now(),
        emf_magnitude: emf_reading.magnitude,
        emf_vector: emf_reading.vector
    }
    
    spatial_map.add(data_point)
}
```

**Sampling Rate:** 10-20 samples per second

### Spatial Mapping

**Approach 1: Grid-Based Voxels**
- Divide scanned area into 3D voxels (e.g., 10cm × 10cm × 10cm)
- Average EMF readings within each voxel
- Generate 2D heat map by projecting to floor plane

**Approach 2: Point Cloud Interpolation**
- Store raw position + reading data points
- Use interpolation (kriging, inverse distance weighting) to generate smooth heat map
- More accurate but computationally expensive

**Recommended:** Start with grid-based, add interpolation in V3.1

### Heat Map Generation

**Color Mapping:**
```
EMF Range (µT)    Color        RGB
─────────────────────────────────
0 - 0.5          Safe (Green)   #00FF00
0.5 - 2          Low (Yellow)   #FFFF00
2 - 10           Moderate (Orange) #FF8800
10+              High (Red)     #FF0000
```

**Rendering:**
- Use Metal (iOS) / OpenGL ES (Android) for performance
- Render as texture overlay on AR camera feed
- Option to toggle between:
  - AR overlay (heat map on live camera)
  - 2D top-down map view
  - 3D volumetric view (future)

### Source Detection

**Algorithm:**
```python
def detect_sources(spatial_map):
    # Find local maxima in the field
    hot_spots = find_local_maxima(spatial_map, threshold=10µT)
    
    # Cluster nearby hot spots
    clusters = cluster_nearby_points(hot_spots, distance=0.5m)
    
    # Estimate source position and strength
    sources = []
    for cluster in clusters:
        centroid = calculate_centroid(cluster)
        strength = max_reading_in_cluster(cluster)
        sources.append(EMFSource(position=centroid, strength=strength))
    
    return sources
```

---

## 📱 User Flow

### Scanning Mode

1. **Start Scan**
   - User taps "AR Map" button
   - Camera opens with AR overlay
   - Instructions: "Move slowly through the room"

2. **Collect Data**
   - User walks around room, moving device slowly
   - Real-time feedback:
     - Current EMF reading displayed
     - Scanned area outline shown on floor
     - Data points collected indicator (e.g., "347 points")

3. **Generate Map**
   - User taps "Finish Scan"
   - Processing indicator (2-5 seconds)
   - Map view opens

### Map View

**Controls:**
- 🔄 Rotate map
- 🔍 Zoom in/out
- 📸 Screenshot
- 💾 Save session
- 📤 Export (CSV/PDF)
- 🗑️ Clear and rescan

**Information Panel:**
- Scan date/time
- Room dimensions (estimated)
- Number of sources detected
- Strongest source location & intensity
- Average field strength

---

## 🎁 Premium Feature Positioning

### Why Premium?

✅ **High Value:**
- Unique differentiator (no competitor has this)
- Solves real user problem
- Appeals to serious users willing to pay

✅ **Computationally Expensive:**
- AR processing requires significant resources
- Heat map generation is CPU/GPU intensive
- Justified as premium tier

✅ **Professional Use Case:**
- Paranormal investigators (equipment investment justification)
- EMF consultants (professional tool)
- Facility managers (safety compliance)

### Pricing Recommendation

**Option 1: Separate AR Mapping IAP**
- EMF Meter Pro (existing): $4.99
- AR Spatial Mapping Add-on: $9.99
- Bundle: $12.99 (save $2)

**Option 2: Ultra Tier**
- EMF Meter Free
- EMF Meter Pro: $4.99 (recording, history, export)
- EMF Meter Ultra: $14.99 (Pro + AR Mapping)

**Recommended:** Option 2 - Ultra tier positions as premium professional tool

---

## 🚀 Implementation Phases

### Phase 1: Proof of Concept (2-3 weeks)
- [ ] ARKit/ARCore integration
- [ ] Basic position tracking
- [ ] Simple grid-based heat map
- [ ] Prototype visualization

### Phase 2: MVP (4-6 weeks)
- [ ] Refined heat map generation
- [ ] Vintage radar-style UI
- [ ] Source detection algorithm
- [ ] Save/load scanned maps
- [ ] Basic export (screenshot)

### Phase 3: Polish (2-3 weeks)
- [ ] Performance optimization
- [ ] Advanced visualizations
- [ ] PDF report generation with floor plan
- [ ] Onboarding tutorial
- [ ] App Store assets

### Phase 4: Launch (1 week)
- [ ] Beta testing
- [ ] Final bug fixes
- [ ] App Store submission
- [ ] Marketing materials

**Total Estimated Timeline:** 10-14 weeks

---

## 🎯 Success Metrics

**Adoption:**
- 15% of Pro users upgrade to Ultra (or purchase AR add-on)
- 30% of new users try AR scanning within first week

**Engagement:**
- Average 3 scans per week per active user
- 50% of scans result in saved session

**Revenue:**
- AR feature contributes 40% of total IAP revenue
- $5-8 average revenue per paying user (ARPPU)

---

## 🔮 Future Enhancements (V3.1+)

### Advanced Features
- **3D Volumetric Rendering:** Show EMF field in 3D space with depth
- **Multi-floor Mapping:** Stack maps for multi-story buildings
- **Source Classification:** AI to identify device types (router, microwave, etc.)
- **Time-Lapse Mode:** Watch EMF patterns change over time
- **Collaborative Mapping:** Multiple users scan same space, merge data
- **EMF "Ghosts":** Historical overlay showing where sources used to be

### AR Enhancements
- **Occlusion:** Heat map renders behind real objects using LiDAR
- **Annotations:** User can tag and label sources
- **Guided Scanning:** AR arrows show where to move for better coverage
- **Mesh Integration:** Generate floor plan from AR room mesh

### Data Science
- **Pattern Recognition:** Identify common EMF signatures
- **Recommendations:** "Move bed 1.5m left to reduce exposure by 40%"
- **Comparison Tool:** Compare rooms, track changes over time

---

## 🎨 Marketing Messaging

**Headlines:**
- "See the invisible fields around you"
- "Map EMF sources like never before"
- "Professional-grade spatial EMF analysis"
- "From detection to location"

**App Store Description Addition:**
> NEW in V3.0: **AR Spatial Mapping** 🚀
> 
> Transform your iPhone into a professional EMF mapping tool. Walk through any room and watch as a vintage-style radar map reveals the hidden electromagnetic landscape. Pinpoint sources, identify hot spots, and document field intensity with stunning visual clarity.
> 
> Perfect for paranormal investigators, EMF consultants, and anyone serious about understanding their electromagnetic environment.

---

## ❓ Open Questions

1. **Device Compatibility:** Require LiDAR for better tracking, or support all ARKit devices?
2. **Storage:** How many scans to allow before requiring storage upgrade?
3. **Cloud Sync:** Store scanned maps in iCloud/Google Drive?
4. **Sharing:** Allow users to share maps with others?
5. **Calibration:** Does AR mapping require different calibration approach?

---

## 📚 References

### AR Development
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [ARCore Documentation](https://developers.google.com/ar)
- [RealityKit for iOS](https://developer.apple.com/documentation/realitykit)

### Heat Map Libraries
- [Mapbox GL JS](https://docs.mapbox.com/mapbox-gl-js/example/heatmap-layer/)
- [SciPy Interpolation](https://docs.scipy.org/doc/scipy/reference/interpolate.html)
- [D3.js Contours](https://github.com/d3/d3-contour)

### Similar Implementations
- Thermal imaging apps (FLIR)
- Wi-Fi analyzer heat maps
- Acoustic mapping tools

---

**Next Steps:**
1. Validate technical feasibility with AR prototype
2. User research: Survey existing users about willingness to pay
3. Competitive analysis: Check if anyone else launches this first
4. Design mockups for vintage radar aesthetic
5. Plan beta testing with paranormal investigation community

---

*This feature could be the killer differentiator that makes EMF Meter the #1 app in the category.*
