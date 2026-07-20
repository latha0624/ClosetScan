# ClosetScan

iPhone demo for scanning a closet with **Apple RoomPlan + LiDAR**, digitally hiding contents, and displaying dimensions to the nearest **1/16 inch**, with a tape-measure validation workflow.

Built for the AI & AR/VR Innovation Intern second-round technical demonstration.

## Requirements

| Item | Detail |
|------|--------|
| Device | **LiDAR** iPhone — you have **iPhone 16 Pro** (supported) |
| Mac | **Not required.** Build for free via GitHub Actions + install with Sideloadly (see [FREE_INSTALL.md](FREE_INSTALL.md)) |
| Apple ID | Free Apple ID for Sideloadly (7-day re-sign window) |
| OS target | iOS **17.0+** |

RoomPlan does **not** run in the Simulator. Use your physical 16 Pro.

## Quick start (no Mac, $0)

Follow **[FREE_INSTALL.md](FREE_INSTALL.md)** end-to-end:

1. Push this folder to a **public** GitHub repo  
2. Download the **ClosetScan-ipa** artifact from Actions  
3. Install with [Sideloadly](https://sideloadly.io/) on Windows → iPhone 16 Pro  

If you later get Mac access, you can still open `ClosetScan.xcodeproj` and Run directly.
## What the app does

1. **Scan** — Uses `RoomCaptureView` to capture walls, floor, ceiling, doors/windows/openings, and furniture objects.
2. **Empty shell** — Results view renders **surfaces only** by default (objects omitted). Toggle **Show contents** to reveal detected object bounding boxes (the live “before/after” beat).
3. **Dimensions** — Axis-aligned bounding box of surfaces → width / depth / height in meters, decimal inches, and fractional inches (nearest 1/16").
4. **Validation** — Enter steel-tape W/D/H; app stores trials and reports absolute error vs the 1/16" target.

## Architecture

```
Home → RoomCaptureView (scan) → CapturedRoom
                                ├─ EmptyClosetViewer (surfaces ± objects)
                                ├─ ClosetDimensions (AABB → fractional inches)
                                └─ ValidationStore (tape vs app trials)
```

| Layer | Files |
|-------|-------|
| App state | `AppModel.swift` |
| Scan | `Scan/RoomCaptureController.swift`, `Scan/ScanView.swift` |
| Math | `Model/ClosetDimensions.swift` |
| Empty / full 3D | `Results/EmptyClosetViewer.swift`, `Results/ResultsView.swift` |
| Accuracy | `Validation/ValidationView.swift`, `Validation/ValidationStore.swift` |

### Content removal approach

RoomPlan returns a parametric `CapturedRoom` with:

- **Surfaces** — walls, floors, ceilings, openings (the empty closet envelope)
- **Objects** — storage, furniture, etc.

Digital removal is intentional omission: the RealityKit dollhouse builds meshes from surfaces only unless the contents toggle is on. No generative inpainting required for a clean demo, and it is reproducible under interview lighting.

### Dimension math

1. Transform each surface’s local corner extents into world space.
2. Take axis-aligned min/max → extent.
3. Map Y → height; larger horizontal axis → width, smaller → depth.
4. Convert meters → inches (`× 39.37007874015748`), round fraction to nearest 1/16", reduce fraction.

## Accuracy & validation methodology

### Honest framing (say this in the interview)

- **Display resolution:** 1/16" (≈ 1.5875 mm).
- **Sensor reality:** LiDAR + RoomPlan is generally **centimeter-class**, affected by occlusion, glossy surfaces, narrow geometry, and how completely the space was scanned.
- Do **not** claim guaranteed ±1/16" sensor accuracy. Claim: *we measure, report to 1/16", and validate against tape.*

### Protocol (run before the interview and show the in-app history)

1. Empty or leave closet as-is; open the door fully.
2. Scan slowly; cover every wall, floor corner, and the upper extent.
3. Record app W / D / H.
4. Measure the same three axes with a steel tape (same reference edges).
5. Enter tape values in **Validate Accuracy**.
6. Repeat ≥ **3** independent scans.
7. Report mean absolute error (MAE) and max absolute error per axis.

### Sample results table (fill with your trials)

| Trial | App W | Tape W | \|ΔW\| | App D | Tape D | \|ΔD\| | App H | Tape H | \|ΔH\| | ≤1/16"? |
|-------|-------|--------|------|-------|--------|------|-------|--------|------|---------|
| 1 | | | | | | | | | | |
| 2 | | | | | | | | | | |
| 3 | | | | | | | | | | |

1/16" = 0.0625".

## Known limitations

- Requires LiDAR; non-Pro iPhones cannot run RoomPlan capture.
- Very narrow or cluttered closets may under-detect walls or mis-merge surfaces.
- Clothes/hanging items may register as objects inconsistently; empty-shell mode still shows structure.
- Bounding-box extents can slightly overestimate if door frames / openings expand the AABB.
- World origin / axis labeling (width vs depth) is normalized (larger horizontal first) for stable UI numbers.

## 20-minute live demo script

| Time | Beat |
|------|------|
| 0:00–0:30 | Home screen: goal + stack (RoomPlan / LiDAR / RealityKit) |
| 0:30–3:30 | Live scan of a real closet (or comparable enclosure) |
| 3:30–5:00 | Results: toggle contents **On → Off** (digital empty shell) |
| 5:00–6:00 | Read W×D×H in fractional inches |
| 6:00–8:00 | Validation: enter tape numbers, show error |
| 8:00–16:00 | Architecture, accuracy honesty, limitations, process |
| 16:00–20:00 | Q&A |

## Interview ops

- Push this repo to GitHub and share the link with **jimkliew** before your slot.
- Email your time slot with subject: `AI & AR/VR Innovation Intern`
- **Confirmed slot:** **Tue Jul 21, 2026 · 9:00 AM EST**
- Prep doc: [INTERVIEW_PREP.md](INTERVIEW_PREP.md)
- Confirmation draft: [INTERVIEW_CONFIRMATION_DRAFT.md](INTERVIEW_CONFIRMATION_DRAFT.md)

## License

Interview demo code — use and modify freely for this candidacy.
