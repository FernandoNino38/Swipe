<div align="center">

<img src="assets/icon/app_icon.png" width="128" height="128" alt="Swipe Logo" />

# 📸 Swipe
### Smart Photo Gallery Triage & Cleanup · 100% Native Android

[![Kotlin](https://img.shields.io/badge/Kotlin-2.1.0-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Jetpack Compose](https://img.shields.io/badge/Jetpack%20Compose-BOM%202024.12.01-4285F4?style=for-the-badge&logo=jetpackcompose&logoColor=white)](https://developer.android.com/jetpack/compose)
[![Material 3 Expressive](https://img.shields.io/badge/Material%203-Expressive-FF6D00?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Built with](https://img.shields.io/badge/Built%20by-Antigravity%20AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://deepmind.google)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue?style=for-the-badge&logo=github)](https://github.com/FernandoNino38/Swipe/releases/latest)
[![Platform](https://img.shields.io/badge/Platform-Android%208.0%2B-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Quickly organize, keep, or discard gallery photos with fluid, intuitive card gestures.</b><br>
  Built 100% native for Android with <b>Kotlin</b>, <b>Jetpack Compose</b>, and full <b>Material 3 Expressive</b> physics & design tokens.
</p>

</div>

---

## 🌟 Overview

**Swipe** is a modern, high-performance Android application dedicated to organizing and cleaning local image galleries. Inspired by fluid card-swiping mechanics and powered by **Material 3 Expressive Design**, it lets users make fast, delightful decisions on every photo:

- 👉 **Swipe Right (Keep)**: Preserve the photo in your gallery with satisfying spring physics.
- 👈 **Swipe Left (Discard)**: Safely stage the photo into the Trash Review queue.
- 👆 **Tap Favorite (Heart)**: Instantly favorite and synchronize with the native Android MediaStore.
- ↩️ **Undo**: Instantly revert the last decision with realistic reverse card physics.
- 🔍 **Long-Press Collections**: Long-press Keep or Favorite buttons to explore your curated collections.
- 🖼️ **Full-Screen M3 Carousel**: Tap any photo in Favorites, Kept, or Trash to view in an immersive multi-browse carousel with edge-peeking and direct gallery launch.

---

## ✨ Key Features (v1.0.0)

### 🎨 Material 3 Expressive Design System
- **Organic Geometry & Squircles**: Extra-large radii (up to 36dp) on floating navigation bars, bottom sheets, and responsive photo cards.
- **Dynamic Physics Motion**: Custom spring interpolations (`DampingRatioMediumBouncy`, `EmphasizedAccelerate`, `EmphasizedDecelerate`) for tactile card gestures and dismissals.
- **Reactive Glow Borders**: Dynamic edge glow animations reflecting real-time drag distance and decision direction (Emerald for Keep, Coral for Discard).
- **Floating Island Navigation**: Modern M3 Expressive floating quick actions island elevated above navigation bars.
- **Full-Screen Carousel Multi-Browse**: Deep OLED canvas with dynamic scale interpolation, photo ratio tags, and metadata inspection.

### 🃏 Intuitive Photo Triage
- Interactive gesture stack with natural rotation and swipe physics.
- Live metadata pills highlighting date, time, file size, aspect ratio, and resolution.
- Instant undo capability restoring card state seamlessly.

### 🗂️ Album Filtering & Batch Review
- **Folder Selection**: Target specific albums (Camera, WhatsApp, Screenshots, Downloads, etc.) or review your entire library.
- **Configurable Batch Sizes**: Choose session limits (20, 40, 60, 100, or all photos).
- **Flexible Sorting**: Sort photos by newest first, oldest first, or largest file size to recover storage rapidly.

### 🧠 Persistent Local Memory
- Locally remembers kept and favorite photos using DataStore preferences, preventing already triaged photos from cluttering your future review sessions.
- Easily manage and remove photos from kept or favorites lists anytime with one tap.

### 🗑️ Safe Two-Step Trash Review & Scoped Storage
- Soft-delete staging prevents accidental photo loss.
- Review queued deletions with real-time storage reclamation metrics.
- Scoped Storage compliant deletion via Android `MediaStore.createDeleteRequest`.

### 🔒 100% Offline & Private
- Zero cloud dependence, no account requirements, and zero analytics telemetry. All photo scanning and management runs strictly on-device.

---

## 🛠️ Native Android Tech Stack

- **Target OS**: Android Exclusive (API 26+ / Android 8.0 to Android 15+)
- **Language**: [Kotlin](https://kotlinlang.org) 2.1.0
- **UI Toolkit**: [Jetpack Compose](https://developer.android.com/jetpack/compose) (BOM 2024.12.01)
- **Design System**: [Material 3 Expressive](https://m3.material.io)
- **Image Pipeline**: [Coil Compose](https://coil-kt.github.io/coil/) 2.7.0
- **Storage & Media**: Android `MediaStore` Content Resolver & Scoped Storage APIs
- **Preferences**: Jetpack DataStore Preferences
- **Architecture**: MVVM + Clean Architecture + Kotlin Coroutines & StateFlow

---

## 📂 Project Structure

```text
android/
├── app/
│   ├── build.gradle.kts
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── kotlin/com/antigravity/phototriage/photo_triage/
│       │   ├── MainActivity.kt               # Single Activity entry point & Navigation Host
│       │   ├── data/
│       │   │   ├── preferences/              # UserPreferences DataStore
│       │   │   └── repository/               # MediaRepository (MediaStore querying & delete)
│       │   ├── domain/model/                 # TriageItem, GalleryAlbum, Enums
│       │   └── ui/
│       │       ├── components/               # TriageCard, QuickActionsBar, M3PhotoCarouselDialog
│       │       ├── screens/                  # DeckScreen, ReviewScreen, FavoritesScreen, KeptPhotosScreen, SettingsScreen
│       │       ├── theme/                    # Color, M3 Expressive Theme, Typography, Shape, Motion
│       │       └── viewmodel/                # TriageViewModel & TriageUiState
│       └── res/                              # Adaptive Launcher Icons & XML resources
├── build.gradle.kts
└── settings.gradle.kts
```

---

## 🚀 Building & Running

### Requirements
- **Android Studio**: Ladybug / Meerkat (2024.2+)
- **JDK**: Java 17+
- **Android SDK**: SDK 36 (targetSdk 36, compileSdk 36, minSdk 26)

### Build Release APK

```bash
cd android
./gradlew assembleRelease
```

*The generated APK will be at `android/app/build/outputs/apk/release/app-release.apk`.*

---

## 🤖 Built with Artificial Intelligence

This project was **100% conceived, architected, and coded by Artificial Intelligence** using **Antigravity**, the advanced AI coding agent developed by **Google DeepMind**, in pair-programming collaboration with **Fernando Nino**.

- 🧠 **AI Engineer**: Antigravity (Google DeepMind)
- 💡 **Product Vision & Architecture Guidance**: [Fernando Nino](https://github.com/FernandoNino38)

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
