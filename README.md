# 📚 stdy4u

A modern student productivity companion built with Flutter and Material 3.

> **Version 1.1.0** — Local-first, no account required.

---

## Features

### 🎓 Course Management
- Add courses with name, code, professor, room, schedule, and color coding
- Track grades, target GPA, and credit hours per course
- Visual progress bar for each subject
- Horizontal carousel on the home screen for quick access

### ✅ Tasks & Notes
- Create tasks with due dates and urgency levels (Normal / Urgent)
- Course-specific notes tab
- Check-off completion with animated toggle
- Filter by course on the detail screen

### 📂 Course Materials
- Add materials as **links**, **notes**, or **uploaded files** (PDF, images, docs)
- Stored locally — files are copied to the app's documents directory
- Tap to open files or URLs

### 📅 Attendance Tracker
- Mark attendance per course: Present / Late / Absent
- Calendar view with `table_calendar`
- Automatic attendance rate calculation with 75% threshold warning
- Quick-action chips in the daily schedule

### 📊 Statistics & Analytics
- CGPA calculation with letter grade conversion
- Grade distribution bar chart (`fl_chart`)
- Per-subject performance overview
- Pomodoro timer with focus/break sessions

### ⏱️ Pomodoro Timer
- 25-minute focus sessions with short (5 min) and long (15 min) breaks
- Auto-rotation through focus → short break → focus → ... → long break
- Session counter
- Haptic feedback on start/pause/complete

### 🎨 Theming
- Light, Dark, and System Default modes
- 8 accent colors to personalize the UI
- Material 3 expressive design with dynamic color schemes

### 🔔 Notifications
- Task reminders and session alerts via `flutter_local_notifications`
- Toggle notifications in Settings
- Android notification channel ("General Notifications")

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter + Dart |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Navigation** | GoRouter with ShellRoute |
| **Local Storage** | Hive (`hive_flutter`) |
| **Charts** | fl_chart |
| **Calendar** | table_calendar |
| **Animations** | flutter_animate, animate_do |
| **Notifications** | flutter_local_notifications |
| **File Picker** | file_picker |
| **Code Generation** | build_runner + hive_generator + riverpod_generator |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── errors/          # Custom exception classes
│   ├── extensions/      # BuildContext helpers
│   ├── services/        # NotificationService
│   └── utils/           # Grade calculator, time utilities
├── data/
│   ├── datasources/     # LocalStorage (Hive init + box access)
│   ├── models/          # AppSettings, ScreenTimeLog (Hive-annotated)
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Course, Task, CourseMaterial, AttendanceRecord
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Business logic: CGPA, attendance, schedule
├── features/            # (legacy, contains screen files)
├── presentation/
│   ├── features/        # Screen widgets grouped by feature
│   ├── theme/           # AppTheme, ThemeProvider/SettingsNotifier
│   └── widgets/         # Reusable UI components
└── shared/
    ├── models/          # Hive-annotated shared models (generated)
    └── providers/       # Riverpod providers
```

---

## Getting Started

### Prerequisites
- Flutter SDK (see `pubspec.yaml` for required version)
- Android Studio / VS Code with Flutter plugins

### Setup

```bash
# Clone the repository
git clone https://github.com/MoHamed-B-M/study4u.git
cd study4u

# Install dependencies
flutter pub get

# Generate Hive adapters (if models changed)
dart run build_runner build --delete-conflicting-outputs

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

### Local Signing (Optional)

Copy `android/key.properties.sample` to `android/key.properties` and fill in your keystore details:

```properties
storeFile=../keystore/upload-keystore.jks
storePassword=your-store-password
keyAlias=your-key-alias
keyPassword=your-key-password
```

> Add `key.properties` and `keystore/` to `.gitignore`.

---

## Building for Release

```bash
# Increment version manually in pubspec.yaml, then:
flutter build apk --release --build-number=$YOUR_BUILD_NUMBER

# Or with signing env vars (CI):
KEYSTORE_PATH=... KEYSTORE_PASSWORD=... KEY_ALIAS=... KEY_PASSWORD=... \
  flutter build apk --release --build-number=$CI_PIPELINE_ID
```


[ROADMAP.md](https://github.com/user-attachments/files/27901117/ROADMAP.md)



## License

Private project.
