<div align="center">

<img src="assets/icon/app_icon.png" width="128" height="128" alt="Swipe Logo" />

# 📸 Swipe
### Smart Photo Gallery Triage & Cleanup

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Built with](https://img.shields.io/badge/Built%20by-Antigravity%20AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://deepmind.google)
[![Release](https://img.shields.io/badge/Release-v0.11.2-blue?style=for-the-badge&logo=github)](https://github.com/FernandoNino38/Swipe/releases/latest)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Quickly organize, keep, or discard gallery photos with fluid, intuitive card gestures.</b><br>
  Built entirely by Artificial Intelligence (<b>Antigravity</b> by Google DeepMind), featuring 100% offline processing and interactive card physics.
</p>

</div>

---

## 🌟 Overview

**Swipe** is a mobile application dedicated to organizing and cleaning local image galleries. Inspired by fluid card-swiping mechanics, it lets users make fast, delightful decisions on every photo:

- 👉 **Swipe Right**: Keep the photo in your gallery.
- 👈 **Swipe Left**: Mark for deletion (Soft-delete for review).
- 👆 **Tap Favorite**: Instantly add the photo to your Favorites collection.
- ↩️ **Undo**: Instantly revert the last decision with realistic physics re-entry animation.

---

## ✨ Key Features

### 🎨 Modern Design & Revamped Experience (v0.11)
- **Native Typography Header & Adjacent Selector**: Prominent **Swipe** title using system font styling, accompanied by a compact album/folder selector chip right next to the title.
- **Maximized Photo Viewport**: Maximizes screen estate for detailed photo inspection, eliminating distracting side text while retaining reactive perimeter glow borders (green for keep, red for delete).
- **Floating 5-Action Bottom Bar**: Trash bin with marked items badge, Quick Discard, Undo, Keep, and Favorite buttons (with long-press to view favorites).
- **Dedicated Settings Screen**:
  - **Appearance**: Seamless switching between System, Light, and Dark (AMOLED) modes.
  - **Language**: Real-time switching between English and Portuguese.
  - **Triage Preferences**: Customizable session limits (20, 40, 60, 100, or All) and persistent "kept photos" memory management.
  - **Credits & Source**: Attribution to AI engineering (Antigravity by Google DeepMind) and GitHub repository links.

### 🃏 Card Deck with Physics-Based Gestures
- Smooth transitions with responsive scaling and angular rotation proportional to swipe speed.
- Dynamic color-reactive edge glows responding in real time to drag intensity.
- Translucent metadata pills at the bottom of the card displaying date, time, file size, and resolution.

### 🗂️ Album Selector & Custom Batches
- **Folder Selection**: Pick any album or folder on your device (Camera, WhatsApp, Downloads, etc.).
- **Batch Size Limit**: Choose how many photos you want to review per session (e.g., 20, 40, 60, 100, or all).
- **Sorting Options**: Sort by newest, oldest, or largest file size to reclaim storage quickly.

### 🧠 Persistent Kept-Photos Memory
- Locally remembers photos you have already decided to keep, preventing them from reappearing in future sessions.
- Option to toggle memory filtering or reset the kept-photos history anytime in Settings.

### 🗑️ Review Grid & Safe Deletion (Hard-Delete)
- Photos marked for deletion are safely collected in a review grid before any permanent action is taken.
- Real-time calculation of the exact storage space that will be reclaimed (MB/GB).
- Easily unmark individual items or confirm permanent deletion in bulk with system-level security prompts.

### 🔒 100% Offline & Complete Privacy
- No data or images ever leave your device. No accounts required, no telemetry tracking, and zero reliance on cloud servers.

### 🌐 Bilingual Support
- Instant real-time language toggling between **English** and **Portuguese** from Settings without restarting the app.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Media Access**: [photo_manager](https://pub.dev/packages/photo_manager)
- **Local Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Haptic Feedback**: Native Flutter HapticFeedback
- **Visual Effects**: `BackdropFilter` (Blur), `InkSparkle` (Material 3 Ripple), `Hero Animations`

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── localization/         # Strings and internationalization (EN/PT)
│   ├── services/             # Media access and persistent history services
│   └── theme/                # Visual theme tokens and color palettes
├── domain/
│   ├── controllers/          # Triage controller and business logic
│   └── models/               # Data models and user action state
└── presentation/
    ├── screens/              # Screens (Main Deck, Favorites, Trash, Details, Settings)
    └── widgets/              # UI Components (Cards, Bottom Bar, Album Selector)
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.13.0)
- [Android Studio](https://developer.android.com/studio) or VS Code with Flutter/Dart extensions
- Android device (or emulator) running Android 8.0+

### Installation & Build

1. **Clone the repository:**
   ```bash
   git clone https://github.com/FernandoNino38/Swipe.git
   cd Swipe
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run automated tests:**
   ```bash
   flutter test
   ```

4. **Launch the application in debug mode:**
   ```bash
   flutter run
   ```

5. **Build production APK:**
   ```bash
   flutter build apk --release
   ```
   *The compiled release APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.*

---

## 🤖 Built with Artificial Intelligence (Credits)

This project was **100% conceived, architected, designed, and coded by Artificial Intelligence** using **Antigravity**, the advanced AI coding agent developed by **Google DeepMind**, in pair-programming collaboration with **Fernando Nino**.

- 🧠 **Software Engineering & AI**: Antigravity (Google DeepMind)
- 💡 **Product Direction & Requirements**: [Fernando Nino](https://github.com/FernandoNino38)
- 🛠️ **Implementation**: Clean Dart & Flutter native code, reactive state management, offline persistence, and physical card animations built without pre-made templates.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  Developed by <b>Antigravity</b> (Google DeepMind) in collaboration with <b>Fernando Nino</b>.
</div>
