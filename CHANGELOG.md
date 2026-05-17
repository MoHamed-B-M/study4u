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

### Fixed
- **Conditional Attendance State (0% / Undefined)**: When no attendance records exist (total = 0), the tracker now shows a neutral "No classes tracked yet!" placeholder instead of flashing a red "Below 75% threshold!" warning. Same fix applied to course detail attendance quick view.
- **Floating Action Button Spacing**: Added `floatingActionButtonLocation: FloatingActionButtonLocation.endFloat` to the Materials, Notes, and Tasks tab Scaffolds so the FAB sits cleanly above the bottom edge without overlapping system navigation.

### Changed
- **Pomodoro session persistence**: Implemented the previously-stub `PomodoroRepositoryImpl` using Hive-backed JSON storage.
- **Notification service**: Extended with a `class_reminders` notification channel and `scheduleClassReminder()` method for weekly recurring alerts.

### Dependencies
- Added `http: ^1.2.0` — GitHub API calls for update checking
- Added `open_filex: ^4.4.0` — Trigger Android package installer for APK updates
- Added `timezone: ^0.9.2` — Timezone-aware notification scheduling

---

## [1.1.0] - Previous release

Initial production-ready release with course tracking, attendance management, Pomodoro timer, GPA calculator, and dark theme.
