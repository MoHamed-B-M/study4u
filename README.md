<div align="center">
  <br>
  <h1>📚 stdy4u</h1>
  <h3><em>STUDY SMARTER</em></h3>
  <p><strong>v1.2.0</strong> — Local-first student productivity companion</p>
  <br>
</div>

---

## 📱 Preview

<p align="center">
  <img src="screenshot/Skreenup_1779140422542.png" width="180" alt="Dashboard">
  <img src="screenshot/Skreenup_1779140432966.png" width="180" alt="Attendance Tracker">
  <img src="screenshot/Skreenup_1779140444045.png" width="180" alt="Statistics">
  <img src="screenshot/Skreenup_1779140457709.png" width="180" alt="Settings">
  <img src="screenshot/Skreenup_1779140469510.png" width="180" alt="Course Detail">
</p>

### 📖 App Explanation
<p align="center">
  <video src="videos/study4u__Master_Focus.mp4" type="video/mp4" controls width="300"></video>
</p>

---

## ✨ Features

### 🎓 Course Management
- Add courses with name, code, professor, room, schedule, and color coding
- Track grades, target GPA, and credit hours per course
- Edit or delete courses via long-press context menu
- Visual progress indicators on the home dashboard

### ✅ Tasks & Notes
- Create tasks with due dates and urgency levels (Normal / Urgent)
- Course-specific notes tab
- Check-off completion with animated toggle
- Filter by course on the detail screen

### 📂 Course Materials
- Add materials as **links**, **notes**, or **uploaded files** (PDF, images, docs)
- Stored locally — files are copied to the app's documents directory
- Tap to open files or URLs
- Delete unwanted materials with the delete button

### 📅 Attendance Tracker
- Mark attendance per course: Present / Late / Absent / Excused
- Calendar view with `table_calendar` — tap a day to see all courses
- Automatic attendance rate calculation with configurable threshold warning
- Quick-action chips in the daily schedule

### 📊 Statistics & Analytics
- CGPA calculation with letter grade conversion (A, B, C, D, F)
- Grade distribution bar chart per course
- Per-subject performance overview with progress rings
- Pomodoro focus time analytics — weekly bar chart

### ⏱️ Pomodoro Timer
- Focus sessions with configurable durations (1–60 min)
- Short break (1–30 min) and long break (1–60 min) with auto-rotation
- Session counter and haptic feedback
- Calm music player — pick audio files to play during focus sessions
- Weekly focus analytics dashboard

### 🎨 Theming & Personalization
- Light, Dark, and System Default modes
- 8 accent colors to personalize the UI
- **Floating Navigation Bar** — glassmorphism frosted glass effect
- Haptic feedback toggle
- Material 3 expressive design

### 🔔 Notifications
- Weekly recurring class reminders (15 min before each class)
- Task reminders and session alerts
- Notification history bottom sheet
- Toggle notifications in Settings

### 🚀 Updates
- On-launch GitHub OTA update check
- Download progress dialog with auto-install
- Manual check in Settings → About → Check for Updates

---

## 📖 How to Use

### 1. Getting Started

On first launch, you'll see an animated splash screen followed by a short **onboarding carousel**. Swipe through the intro pages, then tap **START** to begin.

The app works completely offline — all your data (courses, tasks, attendance, notes) is stored locally on your device. No sign-up, no account needed.

### 2. Adding Your First Course

- Tap the **Home** tab and press the **+** button to open the Add Course form
- Fill in the course name, code, professor, and schedule
- Pick a **color** to identify the course on your dashboard
- Set your **target grade** and credit hours (used for CGPA calculations)
- Save — the course appears on your dashboard immediately

> **Tip:** Long-press any course card to edit or delete it.

### 3. Daily Dashboard

Your **Home** screen shows at a glance:
- A personalized greeting with your study streak
- **Up Next** — your next class today with a countdown
- **Quote Cards** — tap the "UP NEXT" card to expand a full-screen motivational quote with a smooth animated transition. Swipe or tap the close button to dismiss
- Course progress rings showing attendance rate
- Pending tasks and quick action buttons

### 4. Marking Attendance

- Go to the **Tracker** tab to see a monthly calendar
- Tap any date to view all courses scheduled that day
- Tap **Present / Late / Absent / Excused** to mark attendance
- The tracker calculates your attendance percentage and warns if you're below the threshold

### 5. Using the Pomodoro Timer

- Navigate to the **Pomodoro** section from the Home screen
- Tap the gear icon to adjust Focus, Short Break, and Long Break durations
- Press **Play** to start a focus session
- Optionally pick calming music to play during focus time
- View your weekly focus stats on the **Stats** screen

### 6. Tracking Grades & Statistics

- The **Stats** screen shows your overall **CGPA** with a bar chart breakdown per course
- Each course displays its grade, credits, and contribution to your GPA
- The weekly focus time chart shows your Pomodoro productivity

### 7. Managing Materials, Tasks & Notes

Tap any course card to open its detail screen with three tabs:
- **Materials** — Add links, written notes, or upload files (PDFs, images). Tap to open, swipe to delete
- **Tasks** — Create tasks with due dates and urgency. Check them off when done
- **Notes** — Course-specific notes that stay with the course

### 8. Customizing the App

- Open **Settings** to switch between Light, Dark, or System theme
- Pick from **8 accent colors** to personalize the look
- Toggle the **Floating Navigation Bar** for a glassmorphism effect
- Enable or disable haptic feedback

### 9. App Updates

When a new version is available, a **native system notification** pops up in your status bar. Tap the notification to open the update dialog, view release notes, and download the latest APK. You can also manually check for updates in **Settings → About → Check for Updates**.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.44 + Dart |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Navigation** | GoRouter with ShellRoute |
| **Local Storage** | Hive (`hive_flutter`) |
| **Charts** | fl_chart |
| **Calendar** | table_calendar |
| **Animations** | flutter_animate, animate_do |
| **Notifications** | flutter_local_notifications |
| **Audio** | just_audio |
| **File Picker** | file_picker |
| **Code Generation** | build_runner + hive_generator + riverpod_generator |
| **CI/CD** | GitHub Actions (build + release APK) |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── errors/          # Custom exception classes
│   ├── extensions/      # BuildContext helpers
│   ├── services/        # NotificationService, UpdateService
│   └── utils/           # Grade calculator, time utilities
├── data/
│   ├── datasources/     # LocalStorage (Hive init + box access)
│   ├── models/          # AppSettings, ScreenTimeLog (Hive-annotated)
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Course, Task, CourseMaterial, AttendanceRecord
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Business logic: CGPA, attendance, schedule
├── presentation/
│   ├── features/        # Screen widgets grouped by feature
│   │   ├── dashboard/   # Home dashboard with greeting + progress
│   │   ├── home/        # Main screen shell with tabs
│   │   ├── tracker/     # Attendance tracker with calendar
│   │   ├── stats/       # Statistics & CGPA visualization
│   │   ├── settings/    # App settings & about
│   │   ├── splash/      # Animated splash screen
│   │   └── course_detail/ # Course detail & tasks/materials
│   ├── theme/           # AppTheme, DesignTokens, ThemeProvider
│   └── widgets/         # Reusable UI components
└── shared/
    ├── models/          # Hive-annotated shared models
    └── providers/       # Riverpod providers
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.6.0 <4.0.0`
- Android Studio / VS Code with Flutter plugins

### Setup

```bash
# Clone the repository
git clone https://github.com/MoHamed-B-M/study4u.git
cd study4u

# Install dependencies
flutter pub get

# Generate Hive adapters & Riverpod providers
dart run build_runner build --delete-conflicting-outputs

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```


---

## 📦 Building for Release

```bash
# Increment version in pubspec.yaml, then:
flutter build apk --release --build-number=$YOUR_BUILD_NUMBER

# Or with signing env vars (CI):
flutter build apk --release --build-number=$CI_PIPELINE_ID
```

> The repository includes a GitHub Actions workflow (`.github/workflows/build_apk.yml`) that builds a release APK automatically on every push.

---

## 📄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a full history of changes.

---

## 🏫 School Project

This app was developed as a school project for **Madame Basma**.

---

## 📝 License

Private project.
