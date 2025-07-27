# 🐑 FETA
**Flock Emergency and Temperature Alerts** - A Flutter application for livestock health monitoring

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

## 📋 Overview

FETA is a mobile application designed for livestock monitoring, providing real-time alerts about factors affecting animal health including:
- 🌡️ Heat stress monitoring
- 📱 Movement tracking
- ⚠️ Emergency notifications
- 📊 Health analytics

## 📱 Screenshots & Demos

<div align="center">

### Home Screen
<img src="assets/home.gif" width="50%" alt="Home Screen Demo">

---

### Calendar
<img src="assets/showcase.gif" width="50%" alt="Calendar Demo">
---

### Reminder for an ewe
<img src="assets/vaccination.gif" width=50% alt="Vaccination Reminder">

---

</div>

## 🚀 Quick Start

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- Android device/emulator

### 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Project-Provato/FETA.git
   cd feta
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Build for Production

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

## 🚧 Roadmap

### 🎯 Next Release (v0.2)
- [ ] **Real-time Monitoring**
  - [ ] Temperature readings integration
  - [ ] Push notification alerts
  - [ ] Movement tracking basics

- [ ] **Data Management**
  - [ ] Local database setup (SQLite)
  - [ ] Export health reports (PDF/CSV)
  - [ ] Data backup functionality

### Future Features (v1.0+)
- [ ] **Backend & Sync**
  - [ ] Cloud database integration
  - [ ] Multi-device synchronization
  - [ ] REST API development

- [ ] **Analytics & Insights**
  - [ ] Historical data charts
  - [ ] Health trend analysis
  - [ ] Predictive alerts

- [ ] **Polish & Accessibility**
  - [ ] Accessibility improvements
  - [ ] Advanced error handling
  - [ ] Multilingual support

### ✅ Completed
- [x] Basic UI framework
- [x] Calendar integration
- [x] Responsive design
- [x] Dark mode support
- [X] Basic support for standard localization (greek/english)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature`)
3. Commit your changes (`git commit -m 'Added something fun'`)
4. Push to the branch (`git push origin feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

## 🐛 Issues

Found a bug? [Report it here](https://github.com/Project-Provato/FETA/issues)

---
Made with ❤️  from the PROVATO team
