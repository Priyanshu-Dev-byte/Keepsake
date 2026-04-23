# Keepsake — Memory Constellation

> *Seal your life's milestones as constellations of emotion.*
> *Relive how they felt, not just what they looked like.*

![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-26.0+-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-purple)
![SwiftData](https://img.shields.io/badge/SwiftData-Enabled-green)

---

## 🌟 What is Keepsake?

Keepsake is an iOS app built for the **Apple Swift Student
Challenge 2026**. It transforms life's most meaningful
milestones — graduations, birthdays, weddings, trips —
into intentional memory capsules visualized as
**constellations of emotion**.

Every photo you add becomes a star.
Every emotion you tag becomes a color.
Every capsule becomes its own personal sky.

We take thousands of photos but rarely revisit them.
They pile up in a camera roll with no emotional context —
a graduation photo sits next to a grocery screenshot.
Keepsake fixes this by making memory-keeping an
intentional ritual rather than a passive habit.

---

## ✨ Features

### 🫙 Memory Capsules
Create capsules tied to life milestones — graduation,
birthday, trip, wedding, achievement. Each capsule
holds your memories for that milestone, sealed with
a ritual animation when you're ready.

### ⭐ Emotion Tagging
Tag every memory with how it felt:
- 💛 **Joy** — the bright, happy moments
- 💜 **Nostalgia** — bittersweet looking back
- 💙 **Pride** — earned achievement
- 🌸 **Love** — connection and warmth
- 🩶 **Bittersweet** — complex, layered feelings
- 💚 **Hope** — looking forward with optimism

### 🌌 Constellation View
Every memory becomes a star in your personal
constellation. Memories from the same capsule
cluster together, connected by glowing threads.

Multi-photo memories form their own mini
constellation cluster — photos arranged in
triangles, diamonds, and pentagons, all connected
by inner threads.

Two tiers of visual connection:
- **Inner threads** — bright, connect photos
  within the same memory
- **Outer threads** — faint, connect different
  memories across the capsule

### 📸 Multiple Photos Per Memory
Add up to 5 photos to a single memory. Each photo
becomes its own star in the cluster, forming a
geometric constellation shape within the group.
View all photos in a swipeable carousel when you
tap the star.

### 🕯️ Seal Ritual
When a milestone is complete, seal the capsule.
A beautiful ritual animation plays — milestone
specific for graduation, birthday, wedding, and
more. Sealed capsules can always be reopened
and added to.

### 🗺️ Global Constellation Map
The Constellation tab shows every memory from
every capsule as one unified star map. Filter by
capsule, filter by emotion. Pinch to zoom.
Double tap to reset. Every star connected,
every feeling mapped.

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| **Swift 6** | Strict concurrency, zero data races |
| **SwiftUI** | Entire UI, iOS 26 APIs |
| **SwiftData** | Local persistence, offline first |
| **iOS 26 Liquid Glass** | Native glass effect UI throughout |
| **Canvas API** | Constellation thread rendering |
| **PhotosUI** | Multi photo picker up to 5 |
| **Vision** | On-device background removal |
| **UIKit** | UIActivityViewController for sharing |

---

## 🎨 Design System

### Colors
```swift
Background:    #0B0C1E  // Deep navy
Card:          #1A1B2E  // Slightly lighter navy
Accent:        #FF6B8A  // Rose (default)
```

### Emotions
```swift
Joy:           #FFD700  // Gold
Nostalgia:     #9B72CF  // Purple
Pride:         #4A90D9  // Blue
Love:          #FF6B8A  // Rose
Bittersweet:   #7B8FA1  // Blue grey
Hope:          #52B788  // Green
```

### iOS 26 Liquid Glass
```swift
// Standard glass
.glassEffect()

// Interactive glass — all tappable elements
.glassEffect(.regular.interactive())

// Emotion tinted glass
.glassEffect(
    .regular.tint(emotion.color.opacity(0.35))
)

// Grouped glass elements
GlassEffectContainer { }
```

---

---

## 🚀 Getting Started

### Requirements
- Xcode 26 or later
- iOS 26 deployment target
- Swift 6
- iPhone or iPad running iOS 26

### Running the App

1. Clone the repository
```bash
git clone https://github.com/yourusername/keepsake.git
```

2. Open in Xcode
```bash
cd keepsake
open Keepsake.swiftpm
```

3. Select your target device
   (iPhone or iPad running iOS 26)

4. Build and run
   `Cmd + R`

> **Note:** Keepsake is fully offline.
> No API keys, no backend, no configuration needed.
> Just build and run.

---

## 🏗️ Architecture

Keepsake follows a clean, simple architecture
appropriate for a Swift Student Challenge submission.

### Key Architectural Decisions

**SwiftData over CoreData**
Simpler API, native Swift integration, zero
boilerplate. All persistence handled automatically.

**@Observable over ObservableObject**
Swift 6 native observation. No @Published needed.
Automatic minimal re-renders. Zero data races.

**Canvas API for constellation threads**
All thread lines drawn with SwiftUI Canvas —
zero asset cost, smooth performance at any scale.

**Deterministic star positions**
Star positions derived from memory.id hash.
Same layout every launch. No stored coordinates.

**Two-tier thread system**
Inner threads connect photos within the same
memory (bright, 1.2pt). Outer threads connect
different memories (faint, 0.7pt). Two visual
weights create immediate depth and grouping.

---

## 🎯 Apple Swift Student Challenge 2026

Keepsake was built for the
**Apple Swift Student Challenge 2026**.

### Challenge Requirements
- ✅ .swiftpm format in ZIP file
- ✅ Fully offline — zero network calls
- ✅ Under 25MB ZIP
- ✅ Experienced in under 3 minutes
- ✅ Built with Xcode 26
- ✅ Swift 6 strict concurrency
- ✅ iOS 26 APIs (Liquid Glass)
- ✅ Individual work
- ✅ All content in English

### What Makes This Unique
- iOS 26 Liquid Glass used correctly throughout
- Swift 6 strict concurrency — zero data races
- Multi-photo memory clusters in constellation
- Two-tier thread system (inner + outer)
- Emotion-tagged star visualization
- Geometric cluster shapes (triangle, diamond,
  pentagon) based on photo count
- Ritual seal animation per milestone type
- Fully offline and privacy preserving
- Zero third-party dependencies
- Zero force unwraps

---

## 💭 Inspiration

> *"We take thousands of photos but remember less —
> because we've outsourced the memory to the device.
> A graduation photo sits three scrolls away from a
> grocery receipt."*

I built Keepsake because meaningful moments in my
life were getting lost in my camera roll. The photos
existed but the feeling behind them was gone.

Keepsake asks one simple question:
**How did this feel?**

That question — and its answer, mapped as a star
in your personal constellation — is what makes the
difference between a photo archive and a memory
worth keeping.

---
