# Free install path (no Mac purchase)

You do **not** need to buy or borrow a Mac. Use free GitHub Actions (cloud Mac) + free Sideloadly on Windows.

## Overview

1. Put this project on a **public** GitHub repo (free).
2. GitHub builds `ClosetScan.ipa` on a free macOS runner.
3. Download the IPA on your Windows PC.
4. Install it on your **iPhone 16 Pro** with [Sideloadly](https://sideloadly.io/) (free Apple ID).
5. Trust the developer profile and run the live closet demo.

Free Apple ID installs last **7 days** — re-sideload before the interview if needed.

---

## Part A — GitHub (once)

1. Create a free account at https://github.com if you do not have one.
2. Create a new **public** repository named `ClosetScan` (public = free Actions macos capacity for this interview share).
3. On your Windows PC, in PowerShell:

```powershell
cd "C:\Users\latha\OneDrive\Desktop\intership\AR\ClosetScan"
git init
git add .
git commit -m "Initial ClosetScan RoomPlan demo"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ClosetScan.git
git push -u origin main
```

(Replace `YOUR_USERNAME`. GitHub will ask you to sign in — use a Personal Access Token as the password if prompted.)

4. Open the repo on GitHub → **Actions** tab → enable workflows if asked.
5. Open **Build ClosetScan IPA** → wait until it finishes green (~10–20 min first time).
6. Click the finished run → **Artifacts** → download **ClosetScan-ipa** → unzip so you have `ClosetScan.ipa`.

---

## Part B — Sideloadly on Windows

1. Download Sideloadly: https://sideloadly.io/
2. Important for Windows: use the **web** (non–Microsoft Store) versions of iTunes + iCloud if Sideloadly asks.
3. Plug in your iPhone 16 Pro with a USB cable. Trust the computer.
4. Open Sideloadly:
   - IPA = your `ClosetScan.ipa`
   - Apple ID = your free Apple ID
5. Start. When install finishes, on iPhone:
   - **Settings → General → VPN & Device Management** (or Device Management)
   - Trust your Apple ID
6. Open **ClosetScan** and allow Camera / World Sensing.

---

## Part C — Before the interview

- [ ] App opens on the 16 Pro
- [ ] Practice one closet scan
- [ ] Toggle contents off (empty shell)
- [ ] Read dimensions
- [ ] Enter tape measurements in Validation once
- [ ] Share the GitHub repo link with **jimkliew**
- [ ] Email your time slot (subject: `AI & AR/VR Innovation Intern`)

If the app disappears or won’t open after a few days, **re-run Sideloadly** with the same IPA and Apple ID (7-day free signing limit).

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Actions workflow missing | Push to `main`, then refresh Actions; ensure repo is public |
| Build failed | Open the failed job log; re-run workflow; tell your coding agent the error |
| Sideloadly error | Replug USB, unlock iPhone, try another cable/port; confirm Apple ID password |
| Untrusted developer | Settings → trust the Apple ID used to sideload |
| RoomPlan unsupported | Must be physical LiDAR phone (16 Pro is fine); not Simulator |

You already have the correct phone. This path only removes the Mac cost.
