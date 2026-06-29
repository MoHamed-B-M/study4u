# Changelog

All notable changes to stdy4u will be documented in this file.

---

## [1.3.0] - 2026-06-29

### Added
- `SpringCurve` utility: underdamped spring approximation as a `Curve` subclass for use with `AnimatedSize` — by **Hamma**
- `google_nav_bar: ^5.0.7` replacing `navigation_bar_m3e` — by **Hamma**

### Changed
- Nav bar replaced: `NavigationBarM3E` → `GNav` with green accent (`#4ADE80`), `easeOutExpo` curve, outlined Material icons — by **Hamma**
- Nav bar hide detection on Settings: now reads `GoRouterState.of(context).matchedLocation` directly in `build()` instead of relying on `didUpdateWidget` which didn't fire when only the child route changed inside the `ValueListenableBuilder` shell — by **Hamma**
- Pomodoro card expansion: removed horizontal `SizeTransition` + spring controller; replaced with `AnimatedSize` + `SpringCurve(stiffness: 400, damping: 20)` + `AnimatedSwitcher` + `FadeTransition` using `ValueKey` — eliminates layout jitter from mixing `SizeTransition` in a `Row` — by **Hamma**
- Splash screen zoom: added `addListener(_onUpdate)` → `setState()` to all three animation controllers so the widget rebuilds on animation ticks — by **Hamma**
- App size optimization: removed 9 unused dependencies (`riverpod_annotation`, `flutter_svg`, `animate_do`, `m3e_collection`, `fl_chart`, `workmanager`, `flutter_background_service`, `home_widget`, `ota_update`) and 1 unused dev dependency (`flutter_assets_cleaner`) — by **Hamma**

### Fixed
- Splash screen zoom-in animation not playing: animation controllers had no listeners, so `build()` never re-rendered with updated `_scaleCtrl.value` — by **Hamma**
- Nav bar not hiding on Settings screen: `didUpdateWidget` was not called by the `ValueListenableBuilder` shell when only the child route changed — by **Hamma**
- Pomodoro card expansion jitter: `SizeTransition(axis: horizontal)` inside a `Row` caused continuous layout reflow as the expanded width changed — by **Hamma**

### Changed
- Theme system refactored to M3E Expressive design (`m3e_design`), `AppTheme.lightTheme` / `darkTheme` now accept `ColorScheme` directly — `52b1a9f`, `e48a4d0` by **Hamma**
- Nav bar hiding on settings: passes `currentLocation` from `ShellRoute.builder` instead of `GoRouterState.of(context)` to fix scope resolution — `e48a4d0` by **Hamma**
- **M3E spring physics animation refactor**: All custom animations converted from standard easing curves to `SpringSimulation` from `flutter/physics.dart`:
  - Nav bar slide (spatial): `stiffness: 400, damping: 20` with reduced motion support — `7e1931b` by **Hamma**
  - Splash screen startup: fade, scale, and glow driven by staggered `SpringSimulation` with spatial/effect springs — `7e1931b` by **Hamma**
  - Staggered list items: combined slide (spatial) + fade (effects) with single spring controller — `7e1931b` by **Hamma**
  - Slide-out panel: toggle animation uses spatial spring for smooth width reveal — `7e1931b` by **Hamma**
  - Stats view cards: 4 staggered fade-in controllers with effects springs and `Timer` delays — `7e1931b` by **Hanna`
  - Squish action buttons: scale-down press uses high-stiffness spatial spring (`600/14`) for tactile feedback — `7e1931b` by **Hamma**
  - Animated counter: number tween uses spatial spring (`300/16`) replacing `Curves.elasticOut` — `7e1931b` by **Hamma**
- Nav bar body transition: removed `AnimatedSwitcher` (redundant with GoRouter), nav bar uses `SlideTransition` with spring-driven controller — `7e1931b` by **Hamma**
- FAB menu dimming overlay removed: `overlay: false` on `FabMenuM3E` so the dark scrim no longer appears when the menu opens — by **Hamma**
- Nav bar hiding on Settings refactored: uses `Align` + `heightFactor` + spring `SizeTransition` instead of `SlideTransition` to avoid leaving empty space at screen bottom when hidden — by **Hamma**

### Fixed
- Broken temp files removed, `build_runner` re-run for Hive `.g.dart` adapters — `60529c5` by **Hamma**
- Compact `ButtonGroupM3E` bottom sheet layout, `BlobBackground` removed — `af487e9` by **Hamma**
- Top spacing added to `ToolbarM3E` headers below status bar — `18cfe42` by **Hamma**

### Removed
- `BlobBackground` widget — `af487e9` by **Hamma**
- `material_new_shapes` dependency — `d9cc8f1` by **Hamma**
- `M3ColorSchemeGenerator` import from `app_theme.dart` — `e48a4d0` by **Hamma**
- Old FAB bottom sheet picker (`_showAddOptions`) — `86c48dd` by **Hamma**

### Dependencies
- Added `dynamic_color: ^1.7.0` — `e48a4d0` by **Hamma**
- Added `m3e_design: ^0.2.1` — `52b1a9f` by **Hamma**
- Added `m3e_card_list: ^0.1.0` — `d9cc8f1` by **Hamma**
- Added `fab_m3e: ^0.1.1` — `86c48dd` by **Hamma**
- Added `app_bar_m3e: ^0.1.2` — `3e61894` by **Hamma**
- Added `navigation_bar_m3e: ^0.1.1` — `3e61894` by **Hamma**
- Added `button_group_m3e: ^0.3.1` — `d7dcf6c` by **Hamma**
- Added `toolbar_m3e: ^0.1.1` — `d7dcf6c` by **Hamma**
- Added `expressive_loading_indicator: ^0.0.1` — `d7dcf6c` by **Hamma**
- Added `icon_button_m3e: ^0.2.1` — `d7dcf6c` by **Hamma**

---

## [1.2.1] - 2026-06-22

### Added
- Animation optimization: refactored animations to use const constructors, TickerProviderStateMixin, and proper AnimationController disposal for better performance on mid-range devices.
- Material 3 Typography Update: Updated the entire app to use the latest Material 3 'Expressive' typography with Fredoka font for all text styles.
- ABI splits for ARMv7 and ARMv8: Configured APK splits to reduce app size by generating separate APKs for armeabi-v7a and arm64-v8a architectures.

### Changed
- Updated theme to use GoogleFonts.fredoka for all text styles, ensuring consistent font usage throughout the app.
- Improved animation performance by ensuring AnimationControllers are properly disposed and using SingleTickerProviderStateMixin where applicable.

## [1.2.0] - 2026-05-19

### Added
- **Expanding Quote Card** — Tap the next-class card to see a full-screen animated quote card with a randomized motivational quote, backdrop expansion, and cross-fade typography.
- **Local Push Notifications for Updates** — When a new version is detected, a native system notification (`Importance.max` / `Priority.high`) fires immediately with the version string. Tapping it opens the update dialog.
- **Slide-Out Panel** — New reusable `SlideOutPanel` widget for smooth reveal interactions.
- **Squish Buttons** — Tactile press-feedback button component with scale-down animation used across the update dialog.

### Changed
- **Blur removed from quote card** — `BackdropFilter` eliminated for a jank-free 280ms expansion transition.
- **Transition performance** — Expansion route uses `fastOutSlowIn` easing, discrete blur stepping, and `RepaintBoundary` isolation.
- **Background page scale** — Shell pages scale to 0.96 during quote expansion via `PageScaleProvider`/`pageScaleNotifier`.
- **Light-mode nav bar fixes** — `NavigationBar` and `FloatingNavBar` now show proper `#64748B` slate inactive colors instead of hardcoded dark; `SystemChrome.setSystemUIOverlayStyle` adapts status bar icons.
- **Update dialog redesigned** — Custom dark card layout with scrollable changelog, squish action buttons, and download progress.
- **Home screen** — Major rework with new card layouts, dashboard integration, and theme-aware styling.
- **Tracker screen** — Updated visuals, consistent spacing and color tokens.
- **Statistics screen** — Refactored chart layouts and theme alignment.
- **Dashboard** — Quote card trigger integrated via `_NextClassCardWrapper` with GlobalKey.

### Dependencies
- `flutter_local_notifications` — Channel setup expanded with `app_updates_channel`.

### Docs
- README refreshed with new screenshots.

---

## [1.1.2] - 2026-05-18

### Added
- **Design Tokens System**: New `DesignTokens` class with centralized palette (lavender/blue primaries, pastel card colors, spacing, radius, shadows) for consistent theming across the app.
- **Dashboard View**: Extracted standalone `DashboardView` with personalized greeting, course progress rings, pending task count, and "Up Next" quick view.
- **Settings View**: Complete rewrite as a dedicated `SettingsView` with iOS-style grouped sections, color picker for theme accent, and about/update section.
- **Stats View**: New dedicated `StatsView` with GPA bar chart, course-by-course breakdown, and pomodoro focus time analytics.
- **Tracker View**: New standalone `TrackerView` with `table_calendar` integration, per-course attendance marking (Present/Absent/Excused), and daily attendance summary.
- **Dashboard Card Widget**: Reusable `DashboardCard` container with gradient backgrounds, rounded corners, and tap support.
- **Circular Progress Ring Widget**: Custom `CircularProgressRing` for attendance/GPA progress visualization with label and sublabel.
- **Study Charts Widget**: `StudyBarChart` component for GPA and weekly focus time visualization.
- **Study Bottom Nav Widget**: New `StudyBottomNav` Cupertino-style navigation bar with centered add button.
- **CI Workflow**: New `build_apk.yml` GitHub Actions workflow for automated APK builds on push.
- **Screenshots**: Added 6 new app screenshots for store/README.

### Changed
- **Complete UI Redesign**: Refactored all major screens (Home, Course Detail, Settings, Statistics, Tracker) with updated color scheme — dark theme now uses `#111625` scaffold and `#1B2236` surface colors.
- **Theme System**: Replaced `opacity()` calls with `withValues(alpha:)` for null-safety compliance. Card border radius standardized to 24.0 (`radiusCard`). Page transitions switched to `FadeUpwardsPageTransitionsBuilder`.
- **Screen Architecture**: Monolithic screens decomposed into focused view widgets — `DashboardView`, `SettingsView`, `StatsView`, `TrackerView` — for better maintainability.
- **SDK Constraint**: Relaxed from `^3.11.5` to `>=3.6.0 <4.0.0` for broader compatibility.

### Fixed
- **Duplicate Closure Parameter**: Changed `builder: (_, _)` to `builder: (context, child)` in `AddCourseSheet` to comply with Dart's no-duplicate-parameter-name rule.
- **CI Workflow**: Fixed syntax issues in `.github/workflows/build.yaml`.
- **Null-Safe Opacity**: Replaced deprecated `Color.withOpacity()` with `Color.withValues(alpha:)` throughout the theme.

### Dependencies
- Downgraded `flutter_lints` from `^6.0.0` to `^5.0.0`.

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