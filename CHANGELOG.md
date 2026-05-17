# Changelog

All notable changes to stdy4u will be documented in this file.

---

## [1.1.1] - 2026-05-17

### Added
- **GitHub OTA Update Downloader**: On-launch update check via GitHub Releases API. Download progress dialog with auto-install using `open_filex`. Manual check button in Settings → About → Check for Updates.
- **Automated Schedule Notifications**: Weekly recurring class reminders via `flutter_local_notifications` + `timezone`. Parses "09:00 AM" time format and fires a notification 15 minutes before each class on its scheduled days.
- **Pomodoro Local Analytics Dashboard**: Focus sessions are now persisted to a local Hive box (previously in-memory only). New weekly bar chart on the Stats screen showing "Minutes Focused per Day" using `fl_chart`.
- **CGPA Calculator Unit Tests**: 13 unit tests covering weighted CGPA computation, edge cases (empty list, zero credits), clamping, and letter grade mapping.
- **Materials Vault Delete Support**: Material tiles now have a delete button for removing saved files/links/notes from the materials list.
- **Pomodoro Custom Time Picker**: New gear icon button opens a bottom sheet with sliders for Focus Duration (1–60 min), Short Break (1–30 min), and Long Break (1–60 min). Durations persist in state.
- **Course Edit Support**: `AddCourseSheet` now accepts an optional `CourseEntity` parameter. When editing, all fields are pre-filled and saving calls `updateCourse` instead of `addCourse`.
- **Course Long-Press Menu**: Long-pressing a course card opens a bottom sheet with three options: Edit Course (opens pre-filled form), Delete Course (with confirmation dialog), and Cancel.
- **Notification History Bottom Sheet**: Tapping the bell icon on the Home screen now shows a bottom sheet with notification info and a link to Settings.
- **Premium Splash Screen**: Full-screen animated splash with deep navy background (`#111625`), warm coral radial gradient bottom glow, graduation cap logo with fade + scale reveal (`easeOutBack`), "stdy4u" + "STUDY SMARTER" tagline, and cross-fade transition to the main app.
- **First-Launch Onboarding**: 3-page carousel (`PageView.builder`) with pastel-themed cards (cream, dusty rose, soft mint), animated capsule page indicators, SKIP/NEXT/START buttons, and cross-fade navigation to main app. Shown only on first launch after splash.
- **Pomodoro Calm Music Player**: Music note icon in pomodoro controls allows picking an audio file via `file_picker`. Audio plays automatically during focus sessions using `just_audio`. Mini player row shows play/pause/close controls.
- **Glassmorphism Floating Navigation Bar**: Switchable capsule-shaped bottom nav with `BackdropFilter` + `ImageFilter.blur` for frosted glass effect, semi-transparent background (adapts to light/dark mode), animated selection pill, and narrower margins. Toggle in Settings → Appearance → Floating Navigation Bar.
- **Haptic Feedback Toggle**: New switch in Settings → Appearance → Haptic Feedback. Persisted via Hive (`@HiveField(7)`).

### Fixed
- **Conditional Attendance State (0% / Undefined)**: When no attendance records exist (total = 0), the tracker now shows a neutral "No classes tracked yet!" placeholder instead of flashing a red "Below 75% threshold!" warning. Same fix applied to course detail attendance quick view.
- **Floating Action Button Spacing**: Added `floatingActionButtonLocation: FloatingActionButtonLocation.endFloat` to the Materials, Notes, and Tasks tab Scaffolds so the FAB sits cleanly above the bottom edge without overlapping system navigation.
- **Play Button Visibility in Dark Mode**: Changed pomodoro play/pause button background from `displayLarge.color` (white on dark) to `colorScheme.primary`, icon to `Colors.white`.
- **GitHub Update Check Failure**: Added required `User-Agent` header to GitHub API call. Moved on-launch check from `didChangeDependencies` to `initState` + `addPostFrameCallback` to ensure it fires exactly once.
- **Hive Materials Box Error**: Added missing `await Hive.openBox<CourseMaterial>('materials')` in `LocalStorage.init()`.
- **Materials File Opening**: File tiles now show a SnackBar ("File not found...") when the file doesn't exist on disk.
- **Onboarding START Button**: Replaced `GestureDetector` with `ElevatedButton` for reliable tap handling. Added system gesture zone safe area padding.

### Changed
- **Pomodoro session persistence**: Implemented the previously-stub `PomodoroRepositoryImpl` using Hive-backed JSON storage.
- **Notification service**: Extended with a `class_reminders` notification channel and `scheduleClassReminder()` method for weekly recurring alerts.
- **Settings Screen Redesigned**: Complete iOS-style grouped layout with rounded section containers, grey uppercase section headers, chevron icons, and surface container backgrounds.
- **Course Cards Redesigned (Apple Design System)**: Cards now feature a 4px color accent bar at top, circular icon, border + radius, cleaner typography, and subtle spacing.
- **Add Course Sheet Redesigned (Apple Design System)**: iOS grouped sections (Course Details, Schedule, Days, Color & Grade) with no-border input fields inside rounded cards, dividers between rows, grey uppercase section headers.
- **Performance Page Animations**: Replaced `animate_do` `FadeInUp` with native `AnimationController` + `FadeTransition` and staggered `Interval` curves (0.0–0.9 over 800ms).
- **Timer Digits Animation**: Pomodoro countdown wrapped in `AnimatedSwitcher` + `ScaleTransition` for smooth digit transitions.
- **FAB Redesigned**: All FABs now use `CircleBorder` for a fully rounded Apple-style appearance.
- **MainScreen → ConsumerStatefulWidget**: Changed to support conditional rendering of standard `NavigationBar` vs. `FloatingNavBar` via provider.
- **AppSettings Model**: Added `@HiveField(6) useFloatingNavBar` and `@HiveField(7) hapticFeedback` fields. Changed `onboardingComplete` default from `true` to `false`.

### Dependencies
- Added `http: ^1.2.0` — GitHub API calls for update checking
- Added `open_filex: ^4.4.0` — Trigger Android package installer for APK updates
- Added `timezone: ^0.9.2` — Timezone-aware notification scheduling
- Added `just_audio: ^0.9.39` — Pomodoro focus music playback

---

## [1.1.0] - Previous release

Initial production-ready release with course tracking, attendance management, Pomodoro timer, GPA calculator, and dark theme.
