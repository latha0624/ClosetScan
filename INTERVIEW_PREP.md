# Interview Prep — AI & AR/VR Innovation Intern

**Candidate:** Latha Prabhakar  
**Demo:** ClosetScan (RoomPlan + LiDAR closet scan)  
**Slot:** **Tuesday, July 21, 2026 · 9:00 AM EST**  
**Contact:** jimkliew  
**Repo:** https://github.com/latha0624/ClosetScan  
**Device:** iPhone 16 Pro (LiDAR)

---

## Confirmed logistics

| Item | Detail |
|------|--------|
| Date | Tuesday, July 21, 2026 |
| Time | **9:00 AM Eastern (EST)** |
| Format | Second-round technical demonstration (~20 min) |
| Subject line for email | `AI & AR/VR Innovation Intern` |

Send the confirmation draft in `INTERVIEW_CONFIRMATION_DRAFT.md` before the slot. Share the GitHub link with jimkliew.

---

## One-sentence pitch

ClosetScan uses Apple RoomPlan and LiDAR to scan a closet, digitally hide its contents as an empty shell, and report width, depth, and height to the nearest 1/16 inch — with a tape-measure validation workflow.

---

## Night-before checklist

- [ ] Confirmation email/message sent (see draft)
- [ ] Repo link shared: https://github.com/latha0624/ClosetScan
- [ ] ClosetScan installed on iPhone 16 Pro and opens without crash
- [ ] If Sideloadly install: re-signed within last 7 days
- [ ] Camera / LiDAR / World Sensing permissions granted
- [ ] Phone charged ≥ 50%; Low Power Mode off
- [ ] Closet ready: door fully open, clear path, decent light
- [ ] Steel tape measure ready for validation demo
- [ ] ≥ 3 practice scans done; validation history populated
- [ ] Backup plan: last successful scan still viewable from Home
- [ ] Quiet space + stable Wi‑Fi / meeting link tested (if remote)

---

## Morning-of (arrive 15–20 min early)

1. Unlock phone, open ClosetScan once to warm LiDAR / permissions.
2. Place tape measure where you can reach it during the demo.
3. Open GitHub repo on a second screen if you want to show code.
4. Silence notifications.
5. Have this prep doc open for the Q&A section only if needed.

---

## 20-minute live demo script

| Time | Beat | What to say / do |
|------|------|------------------|
| 0:00–0:30 | Home | “ClosetScan — RoomPlan + LiDAR + RealityKit. Goal: empty-shell closet + dimensions to 1/16\", validated against tape.” |
| 0:30–3:30 | Live scan | Open closet door fully. Scan slowly; cover walls, floor corners, and upper extent. |
| 3:30–5:00 | Empty shell | Results: toggle **Show contents** On → Off. “Surfaces only = digital empty shell; objects omitted on purpose.” |
| 5:00–6:00 | Dimensions | Read W × D × H in fractional inches. Mention meters + decimal + 1/16\" display. |
| 6:00–8:00 | Validation | Enter steel-tape W/D/H. Show absolute error vs 1/16\" target and prior trials. |
| 8:00–16:00 | Architecture | Flow, content removal, dimension math, accuracy honesty, limitations (below). |
| 16:00–20:00 | Q&A | Prefer short, concrete answers. Offer to dig into code if asked. |

### Demo tips

- Narrate while scanning: “I’m covering the back wall… corners… upper shelf line.”
- If scan quality looks weak, do a second pass rather than apologizing at length.
- Always land on the accuracy honesty line (do not oversell ±1/16\" sensor accuracy).

---

## Architecture talking points

```
Home → RoomCaptureView (scan) → CapturedRoom
                                ├─ EmptyClosetViewer (surfaces ± objects)
                                ├─ ClosetDimensions (AABB → fractional inches)
                                └─ ValidationStore (tape vs app trials)
```

| Layer | Files | Say this |
|-------|-------|----------|
| App state | `AppModel.swift` | Phase machine: home → scanning → results → validation |
| Scan | `RoomCaptureController.swift`, `ScanView.swift` | `RoomCaptureView` wraps RoomPlan; captures parametric room |
| Math | `ClosetDimensions.swift` | Surface corners → world AABB → W/D/H → nearest 1/16\" |
| 3D UI | `EmptyClosetViewer.swift`, `ResultsView.swift` | RealityKit dollhouse; contents toggle |
| Accuracy | `ValidationView.swift`, `ValidationStore.swift` | Persist trials; absolute error vs tape |

### Content removal (expected question)

RoomPlan returns:

- **Surfaces** — walls, floors, doors/windows/openings (empty envelope)
- **Objects** — storage, furniture, etc.

Digital removal = **intentional omission**: build meshes from surfaces only unless the contents toggle is on. No generative inpainting. Reproducible under interview lighting.

### Dimension math (expected question)

1. Transform each surface’s local corner extents into world space.
2. Axis-aligned min/max → extent.
3. Y → height; larger horizontal axis → width, smaller → depth.
4. Meters → inches (`× 39.37007874015748`), round fraction to nearest 1/16\", reduce fraction.

---

## Accuracy — say this exactly

- **Display resolution:** 1/16\" (≈ 1.5875 mm).
- **Sensor reality:** LiDAR + RoomPlan is generally **centimeter-class**, affected by occlusion, glossy surfaces, narrow geometry, and incomplete scans.
- **Do not claim** guaranteed ±1/16\" sensor accuracy.
- **Do claim:** *we measure, report to 1/16\", and validate against tape.*

### Validation protocol (if asked how you tested)

1. Open door fully; scan slowly covering all walls and upper extent.
2. Record app W / D / H.
3. Measure same axes with steel tape (same reference edges).
4. Enter tape values in **Validate Accuracy**.
5. Repeat ≥ 3 independent scans.
6. Report MAE and max absolute error per axis.

1/16\" = 0.0625\".

| Trial | App W | Tape W | \|ΔW\| | App D | Tape D | \|ΔD\| | App H | Tape H | \|ΔH\| | ≤1/16"? |
|-------|-------|--------|------|-------|--------|------|-------|--------|------|---------|
| 1 | | | | | | | | | | |
| 2 | | | | | | | | | | |
| 3 | | | | | | | | | | |

*(Fill with your practice trials before the call.)*

---

## Known limitations (own them)

- Requires LiDAR; non-Pro iPhones cannot run RoomPlan capture.
- Very narrow or cluttered closets may under-detect walls or merge surfaces.
- Clothes/hanging items may register as objects inconsistently; empty-shell mode still shows structure.
- AABB can slightly overestimate if door frames / openings expand the bounds.
- Width vs depth is normalized (larger horizontal first) for stable UI numbers.

---

## Likely Q&A

**Why RoomPlan instead of raw ARKit mesh?**  
Parametric surfaces + objects give a clean empty-shell toggle and stable dimensioning without fighting a dense mesh. Faster path to a clear demo narrative.

**How accurate is 1/16\"?**  
Display precision, not guaranteed sensor precision. We validate against tape and report error honestly.

**What would you build next?**  
Examples: opening-aware interior clear span (exclude door swing), multi-scan fusion, export USDZ / share sheet, ML clothing segmentation on top of the empty shell, or on-device persistence of validation stats with charts.

**Why SwiftUI + RealityKit?**  
Native RoomPlan integration, fast UI for interview iteration, RealityKit for the dollhouse visualization.

**Did you need a Mac?**  
No — free path via GitHub Actions IPA + Sideloadly on Windows (`FREE_INSTALL.md`). Device is iPhone 16 Pro.

**What broke during development?**  
RoomPlan API details (e.g. no ceilings array — height from wall extents), `RoomCaptureViewDelegate` / NSCoding conformance for CI. Happy to walk through the commit history.

---

## Closing line

“Thanks for the time — happy to walk through any part of the scan pipeline, the dimension math, or the validation results in more detail.”
