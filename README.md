<div align="center">

<img src="assets/icon/app_icon.png" width="128" height="128" alt="Swipe Logo" />

# 📸 Swipe
### Smart Photo Gallery Triage & Cleanup

[![Kotlin](https://img.shields.io/badge/Kotlin-2.1.0-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Jetpack Compose](https://img.shields.io/badge/Jetpack%20Compose-BOM%202024.12.01-4285F4?style=for-the-badge&logo=jetpackcompose&logoColor=white)](https://developer.android.com/jetpack/compose)
[![Material 3 Expressive](https://img.shields.io/badge/Material%203-Expressive-FF6D00?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Built with](https://img.shields.io/badge/Built%20by-Antigravity%20AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://deepmind.google)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue?style=for-the-badge&logo=github)](https://github.com/FernandoNino38/Swipe/releases/latest)
[![Platform](https://img.shields.io/badge/Platform-Android%208.0%2B-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Quickly organize, keep, or discard gallery photos with fluid, intuitive card gestures.</b><br>
  Built entirely by Artificial Intelligence (<b>Antigravity</b> by Google DeepMind), featuring 100% offline processing, 100% Native Kotlin & Jetpack Compose, and Material 3 Expressive physics.
</p>

</div>

---

## 🌟 Overview

**Swipe** is a modern, high-performance Android application dedicated to organizing and cleaning local image and video galleries. Inspired by fluid card-swiping mechanics and powered by **Material 3 Expressive Design**, it lets users make fast, delightful decisions on every photo:

- 👉 **Swipe Right**: Keep the photo in your gallery.
- 👈 **Swipe Left**: Mark for deletion (Soft-delete for review).
- 👆 **Tap Favorite**: Instantly add the photo to your Favorites collection.
- ↩️ **Undo**: Instantly revert the last decision with realistic physics re-entry animation.
- 🔍 **Long-Press Lists**: Press and hold on Keep or Favorite buttons to open your saved items with an immersive M3 Carousel preview.

---

## ✨ Key Features (v1.0.0)

### 🎨 Material 3 Expressive Architecture
- **Expressive Shapes & Geometry**: Fully compliant with M3 Expressive shape scales (up to 36dp corner radii for bottom sheets and floating action cards).
- **Physics-Based Spring Motion**: Spring interpolations (`DampingRatioMediumBouncy`, `EmphasizedAccelerate`, `EmphasizedDecelerate`) ensuring tactile and fluid swipe transitions.
- **Dynamic Glow Borders**: Real-time left/right edge indicators reacting directly to drag distance and direction.
- **Expressive Loading Indicators**: Integrated M3 loading indicators with fluid polygon animations during photo fetching.

### 🃏 Card Deck & Triage System
- Interactive center card with natural rotation and release physics.
- Responsive metadata chips showing date, dimensions, file size, and favorite status.
- Instant undo capability reverting card position and triage state seamlessly.

### 🗂️ Album Selector & Custom Batches
- **Folder Selection**: Pick any album or folder on your device (Camera, WhatsApp, Downloads, Screenshots, etc.).
- **Batch Size Limit**: Choose how many photos you want to review per session (20, 40, 60, 100, or all).
- **Sorting Options**: Sort by newest, oldest, or largest file size to reclaim storage quickly.

### 🧠 Persistent Kept & Favorite Memory
- Locally remembers photos you have decided to keep or favorite, preventing them from reappearing in future sessions even after app restarts.
- Remove photos from kept or favorites lists at any time with a single tap.
- Full M3 Carousel viewer with "Show on Gallery" system intents.

### 🗑️ Review Grid & Safe Deletion (Hard-Delete)
- Photos marked for deletion are safely collected in a review grid before any permanent action is taken.
- Real-time calculation of reclaimed storage space.
- System-level secure deletion via Android `MediaStore.createDeleteRequest`.

### 🔒 100% Offline & Complete Privacy
- No data or images ever leave your device. No accounts required, no telemetry tracking, and zero reliance on cloud servers.

---

## 🛠️ Tech Stack

- **Language**: [Kotlin](https://kotlinlang.org) 2.1.0
- **UI Framework**: [Jetpack Compose](https://developer.android.com/jetpack/compose) (Compose BOM 2024.12.01)
- **Design System**: [Material 3 Expressive](https://m3.material.io)
- **Image Loading**: [Coil](https://coil-kt.github.io/coil/) 2.7.0
- **Media Access**: Android `MediaStore` Content Resolver & API 33/34 granular media permissions
- **Architecture**: Clean Architecture + MVVM + Kotlin Coroutines & StateFlow

---

## 📂 Project Structure

```text
android/app/src/main/kotlin/com/antigravity/phototriage/photo_triage/
├── data/
│   ├── model/               # Data Transfer Objects
│   └── repository/          # MediaStoreRepository (photo fetching & deletion)
├── domain/
│   └── model/               # Domain Models (TriageItem, ActionType)
└── ui/
    ├── components/          # TriageCard, QuickActionsBar, M3PhotoCarouselDialog, etc.
    ├── screens/             # DeckScreen, ReviewScreen, FavoritesScreen, KeptPhotosScreen, SettingsScreen
    ├── theme/               # Color, Theme, Type (M3 Expressive), Shape (M3 Expressive), Motion
    └── viewmodel/           # TriageViewModel & UI States
```

---

## 🚀 Getting Started

### Prerequisites
- Android Studio Ladybug / Meerkat (or newer)
- JDK 17+
- Android SDK 36 (targetSdk 36, minSdk 26)

### Build Production APK

```bash
cd android
./gradlew assembleRelease
```
*The compiled release APK will be located at `android/app/build/outputs/apk/release/app-release.apk`.*

---

## 🤖 Built with Artificial Intelligence (Credits)

This project was **100% conceived, architected, designed, and coded by Artificial Intelligence** using **Antigravity**, the advanced AI coding agent developed by **Google DeepMind**, in pair-programming collaboration with **Fernando Nino**.

- 🧠 **Software Engineering & AI**: Antigravity (Google DeepMind)
- 💡 **Product Direction & Requirements**: [Fernando Nino](https://github.com/FernandoNino38)
- 🛠️ **Implementation**: 100% Native Kotlin & Jetpack Compose, Material 3 Expressive tokens, MediaStore APIs, and offline persistence.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  Developed by <b>Antigravity</b> (Google DeepMind) in collaboration with <b>Fernando Nino</b>.
</div>
