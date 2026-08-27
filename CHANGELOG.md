# Changelog

All notable changes to stdy4u will be documented in this file.

---

## [Unreleased]

### Added
- **Telegram community**: New "Telegram Community" row in Settings → About — opens [t.me/study4ulink](https://t.me/study4ulink) with the Telegram app / external browser — by **Hamma**
- **First-launch Telegram prompt**: One-time comic-print dialog on first launch (after the update check, so dialogs never stack) inviting users to join the Telegram channel — Close and Join buttons; dismissal is persisted in Hive (`AppSettings.telegramPromptShown`, field 11) so it never shows twice — by **Hamma**
- **Android home-screen widget**: New comic-print study dashboard widget (2×2) — next class (computed live from today's schedule at render time), pending tasks count, focus minutes today, and CGPA with letter grade; paper/ink styling adapts to light & dark system themes; tap opens the app — by **Hamma**
- **Widgets settings option**: New `WIDGETS` section in Settings with "Home Screen Widget" row opening a bottom sheet that pins the widget via the system add-widget dialog (Android 8+), with manual instructions fallback — by **Hamma**
- **`com.stdy4u/widget` method channel**: `WidgetPlugin.kt` + `WidgetBridge` Dart bridge — saves data snapshots and re-renders all widget instances, requests pinning — by **Hamma**
- **Selectable app icon**: New "App Icon" row in Settings → Appearance — pick between the Default icon and a **Comic edition** launcher icon (new `ic_launcher/` asset pack: adaptive background/foreground + legacy PNGs at all densities); built on two Android `activity-alias` entries (`MainLauncherDefault` / `MainLauncherAlt`) so exactly one is enabled at a time — by **Hamma**
- **`com.stdy4u/app_icon` method channel**: `AppIconPlugin.kt` + `AppIconBridge` Dart bridge — swaps the launcher aliases at runtime, reports the active icon, and re-applies the persisted choice (`AppSettings.useAltAppIcon`, field 12) on every app start — by **Hamma**
- **`flutter_vibrate: ^1.4.0`**: New dependency unifying device vibration & haptic feedback APIs across Android/iOS — by **Hamma**
- **`VIBRATE` permission**: Added to `AndroidManifest.xml` for full `flutter_vibrate` functionality — by **Hamma**
- **Collaborative Study Room**: New real-time collaborative notes page at `/collab` (entry point: groups button in the Home app bar) built on the local-first CRDT stack `crdt_lf ^4.0.0` / `crdt_lf_flutter ^0.4.0` — Fugue text algorithm merges concurrent keystrokes conflict-free; edits persist locally via Hive snapshots so the page works fully offline; LAN sync via the official `crdt_socket_sync ^0.7.0` relay mode (dumb rebroadcaster, auto-reconnect with backoff, ping/pong liveness, change dedup); peer presence bar driven by the awareness plugin; comic-styled editor with LIVE/OFFLINE status pill — by **Hamma**
- **Collab relay server script**: `tools/collab_relay_server.dart` — run `dart run tools/collab_relay_server.dart 8787` on any machine in the LAN to host rooms; CRDT-agnostic relay keeps the backend free of merge logic — by **Hamma**
- **P2P Live Collaboration**: Study Room upgraded to full mesh P2P — live video (grid, local PiP, remote tiles), voice (mic mute, speaker), P2P chat & file transfer via WebRTC DataChannel (16 KB chunked, fallback to relay), responsive UI (mobile tabs / desktop split), live-editing toggle; new `flutter_webrtc` + `permission_handler` + `web_socket_channel` stack with `webrtc_signaling_server` (port 8789) — by **Hamma**
- **WebRTC signaling server**: `tools/webrtc_signaling_server.dart` — dumb JSON room broadcast for SDP/ICE/chat/file-meta on LAN — by **Hamma**

### Changed
- **What's New dialog enlarged**: Update dialog now grows up to **80% of screen height** (width 92%) instead of a fixed 220px notes box — release notes get room to breathe on long changelogs — by **Hamma**
- **Release notes readability**: Bumped markdown body text 13→15px with proper 1.45 line height (was ultra-cramped 0.8), larger headings (h1 21 / h2 19 / h3 17), block spacing and list indentation added — by **Hamma**
- **Widget data sync**: Widget snapshot refreshes automatically on app start, on app resume, and whenever data changes (`dataRefreshProvider`) — by **Hamma**
- **Haptics migrated to `flutter_vibrate`**: Every `HapticFeedback.*` call across 17 files replaced with typed platform haptics — `lightImpact`→`FeedbackType.light`, `mediumImpact`→`.medium`, `heavyImpact`→`.heavy`, `selectionClick`→`.selection`; unused `flutter/services.dart` imports dropped (kept in `SoundService` for `SystemSound`) — by **Hamma**
- **Telegram prompt redesign**: First-launch dialog rebuilt — telegram-blue hero band with comic diagonal stripes and an overlapping send-badge, perk chips (Tips / Updates / Community) in a re-flowing Wrap layout, brand-blue Join CTA, "no spam" footnote, and a fade+scale entrance; fixed 360px cap makes it overflow-proof on narrow screens — by **Hamma**

### Removed
- **`build_apk.yml` workflow** ("Build APK (All Branches)") — redundant with the main Build & Release APK workflow — by **Hamma**

### Fixed
- **"Problem loading widget" error**: `StudyWidgetProvider` view building is now guarded — if rendering ever throws, a minimal fallback RemoteViews layout (`widget_fallback.xml`) is shown instead of the launcher's broken-widget error state — by **Hamma**
- **Stray yellow stripes on first launch**: The Telegram prompt could trigger Flutter's overflow indicators on narrower screens — new layout wraps all content (chips via `Wrap`, fixed dialog cap) so nothing can overflow anymore — by **Hamma**
- **`flutter_vibrate` build failure** ("Inconsistent JVM Target Compatibility"): Root `build.gradle.kts` now forces Java 17 + Kotlin `jvmTarget` 17 on every Android subproject after evaluation, aligning older plugins (which pinned Java 1.8) with modern Kotlin tasks — by **Hamma**
- **`flutter_vibrate` resource linking failure** (`AAPT: resource android:attr/lStar not found`): The same root block also pins every subproject's `compileSdk` to 36 (matching `:app`) so old plugins merge/link resources against a modern SDK — by **Hamma**
- **Launcher icon reverting to default**: Root cause was a lost Hive write + blind `apply()` overwriting the correctly persisted native state. Fixed via: (1) `AppIconPlugin` now `commit()`s choice to `SharedPreferences` synchronously and auto-restores PM state in `onAttachedToEngine`; `isAltIcon` falls back to that pref for DEFAULT; (2) Dart `settings_view` awaits Hive before PM; (3) startup reconciles Hive *to* native (native is durable) instead of reverting the launcher — eliminates the "switch → close → revert" loop — by **Hamma**

---

## [2.0.2] - 2026-08-25

### Added
- **AGPL-3.0 license**: Added full GNU Affero General Public License v3.0 — the project is now officially open-source licensed — by **Hamma**

### Changed
- **README overhaul**: Complete documentation rewrite — streamlined Overview section, updated feature list, shields.io badge row (Flutter, Dart, CI, platform, downloads, license, visitors), simplified Tech Stack and Project Structure sections, and a rewritten Theming section documenting the Neo-Brutalist manga design system — by **Hamma**

---

## [2.0.1] - 2026-07-06

### Added
- **Battery Optimization Onboarding**: Replaced "Usage Access" onboarding page with proper `DisableBatteryOptimization` API calls — auto-start dialog, manufacturer battery optimization dialog with step-by-step instructions — by **Hamma**
- **`disable_battery_optimization: ^1.1.2`**: New dependency for requesting battery optimization, auto-start, and manufacturer-specific power settings — by **Hamma**
- **`ComicLoader` widget**: Animated SVG loading indicator — pulsates the thunder-struck icon with smooth scale + color shift (`inkRed` ↔ `surfaceWhite`), configurable size and colors — by **Hamma**
- **`flutter_markdown`**: New dependency for live markdown rendering in update release notes — by **Hamma**
- **`solar_icons`**: New dependency replacing `cupertino_icons` — 7000+ icons in Bold/Outline/Broken styles — by **Hamma**
- **CGPA target persistence**: Target CGPA now stored in Hive via `AppSettings.targetCgpa` (field 10) — survives navigation and app restarts — by **Hamma**
- **Download pause/resume/cancel**: Download dialog now shows Pause/Resume/Cancel buttons; progress saved to `dl_state.json` on pause, resumes via HTTP `Range` header, partial file deleted on cancel — by **Hamma**

### Changed
- **Update check loading UI**: Full-screen dimmed overlay with centered `ComicLoader` (size increased to 56) replaces tiny spinner inside button — minimum 1s display to complete pulse cycle — by **Hamma**
- **Release notes rendering**: Replaced plain-text markdown stripping with live `flutter_markdown` `MarkdownBody` widget — renders headings, lists, code blocks, links, bold/italic; styled with comic theme colors — by **Hamma**
- **Icons migrated to SolarIcons**: All 29 `CupertinoIcons.*` replaced with `SolarIconsBold.*` across 5 files (bottom nav, tracker, settings, dashboard, stats) — by **Hamma**
- **Edge-to-edge rendering**: Transparent `statusBarColor` and `systemNavigationBarColor` set at startup and maintained on tab screens — by **Hamma**
- **Compacted release notes line spacing**: Paragraph `height` reduced from 1.5 to 0.8 — ultra-tight comic-style layout — by **Hamma**
- **SoundService simplification**: Replaced `just_audio` + `AudioPlayer` (6 MB native libs) with `SystemSound.play(SystemSoundType.click)` + `HapticFeedback.lightImpact()` — instant play, no preloading, no init delay — by **Hamma**
- **Dependency cleanup**: Removed 14 unused packages — `m3e_design`, `m3e_buttons`, `icon_button_m3e`, `fab_m3e`, `toolbar_m3e`, `app_bar_m3e`, `expressive_loading_indicator`, `button_group_m3e`, `m3e_card_list`, `material_color_utilities`, `flutter_animate`, `percent_indicator`, `animations`, `dynamic_color` — reduces APK size — by **Hamma**
- **Removed link underlines**: Link (`a`) style in release notes markdown no longer has `TextDecoration.underline` — cleaner comic aesthetic — by **Hamma**
- **ComicLoader**: Increased default size from 24 to 32, overlay size from 48 to 56 — by **Hamma**
- **Deferred notification init**: `NotificationService.instance.init()` moved to `addPostFrameCallback` — timezone initialization no longer blocks first frame — by **Hamma**

### Fixed
- **CGPA target not persisting**: Target CGPA was stored in local widget state only — reset on navigation/tab switch. Now persisted via Hive `AppSettings.targetCgpa` field 10 — by **Hamma**
- **Notification ID overflow**: `remainder(1 << 31)` could produce negative Android notification IDs — replaced with `% 100000).abs()` for always-positive IDs — by **Hamma**
- **APK download not following redirects**: Set `request.followRedirects = true` in `HttpClient` download — GitHub asset URLs redirect to CDN — by **Hamma**
- **Materials open button not working**: Replaced `launchUrl(Uri.file(...))` with `OpenFilex.open()` for file materials (external apps can't access internal storage paths); added try-catch error handling for link launching — by **Hamma**
- **Update dialog parenthesis bug**: Missing closing parens for `Container`/`Padding` and invalid `li:` parameter in `MarkdownStyleSheet` — fixed build errors — by **Hamma**
- **Usage access removed from onboarding**: Usage Access page (page 4) removed from `FeaturePreviewScreen` — battery optimization pages now use the actual `DisableBatteryOptimization` plugin instead of just opening Settings — by **Hamma**

### Removed
- `cupertino_icons` — replaced by `solar_icons`
- `_stripMarkdown()` — replaced by `flutter_markdown` live render
- `just_audio` SoundService dependency — click sound now uses `SystemSound` + `HapticFeedback` (saves ~6 MB native libs)
- `assets/audio/mechanical_click.wav` — no longer needed
- Beta/Stable update channel toggle — single-channel release check
- `UpdateChannel` enum — removed

---
## [2.0.0] - 2026-07-01

### Added
- **Comic-Print Manga Design System**: Complete UI overhaul with custom `ComicTheme`, `ComicCard`, `ComicButton` atomic widgets — Luckiest Guy font, sharp black ink borders (`width: 2.5`), hard offset shadows (`Offset(4,4)`, `blurRadius: 0`), ink red (`#E63946`) accents — by **Hamma**
- **MangaNavBar**: Custom bottom navigation with flat white background, thick 3px top ink border, sharp geometric edges, ink red selected state with white icon/label inversion, ALL-CAPS labels (`letterSpacing: 1.2`) — replaces `google_nav_bar` — by **Hamma**
- **Mechanical Keyboard Click Sound**: Synthesized 44.1kHz 16-bit WAV (800Hz + 3.5kHz + 6kHz mixed with rapid decay) preloaded at startup via `just_audio`, fires in parallel with 60ms shadow-snapping animation — by **Hamma**
- **High-Contrast Text Enforcement**: `ComicCard` wraps children in `DefaultTextStyle` forcing `Color(0xFF000000)` (Ink Black) in light mode; all titles use `GoogleFonts.luckiestGuy()` explicitly — by **Hamma**
- **SpringCurve utility**: Underdamped spring approximation as a `Curve` subclass for `AnimatedSize` — by **Hamma**
- **Press Sound Toggle**: New `pressSound` setting (Hive field 9) — global on/off for mechanical click sound, checked in `SoundService.playClick()` — by **Hamma**
- **Settings Plugin**: Native Android `SettingsPlugin.kt` + `SettingsBridge` Dart bridge — opens system app info screen via `Settings.ACTION_APPLICATION_DETAILS_SETTINGS` intent — by **Hamma**
- **App Name Mapping**: `_friendlyAppName()` maps 30+ Android package names (Chrome, YouTube, Instagram, WhatsApp, etc.) to human-readable labels in screen time Top Apps — by **Hamma**

### Changed
- **All feature screens refactored**: Home, Dashboard, Tracker, Stats, Settings, Course Detail, Splash, Feature Preview — all use `ComicTheme` constants, `ComicCard`/`ComicButton` instead of Material 3 / M3E widgets — by **Hamma**
- **Home screen Up Next & Current Courses**: Replaced old `Material`/`InkWell` (rounded 24px) and `OpenContainer` with `ComicCard` — flat background, `BorderRadius.zero`, 2.5px black border, `Offset(4,4)` block shadow — by **Hamma**
- **Navigation architecture**: GoRouter `ShellRoute` body replaced with `IndexedStack` containing all 3 tab screens (Home, Tracker, Stats) — instant tab switching, no route rebuild lag — by **Hamma**
- **Edge-to-edge rendering**: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` in `main()`; status & navigation bars set to `Colors.transparent` with adaptive icon brightness — by **Hamma**
- **Nav bar visibility**: Removes nav bar on non-tab routes (Settings, Course Detail) instead of animating it — by **Hamma**
- **APK size optimization**: Universal APK disabled → per-ABI split APKs via `--split-per-abi`; added `--split-debug-info` to CI build command — each APK now ~20–25 MB instead of ~55 MB — by **Hamma**
- **Settings page**: Removed "Show Labels" switch (nav labels are always shown in ALL-CAPS manga style) — by **Hamma**
- **Settings page redesigned**: Replaced `CupertinoAlertDialog`/`CupertinoActionSheet` with comic-themed dialogs; section headers get ink red underline; removed `Accent Color` picker — by **Hamma**
- **Settings gear icon**: Plain `IconButton` replaced with comic-styled `GestureDetector` + `Container` (36×36, 2px border, hard shadow, adaptive background) — by **Hamma**
- **Update dialog redesigned**: Removed `AppTheme`/`DesignTokens`/`M3ESpring`/`_SquishActionButton` — uses sharp borders, ink red CTA, hard shadows, Luckiest Guy title — by **Hamma**
- **Onboarding intro redesigned**: Comic-styled content containers with 2.5px ink border + hard shadow; Luckiest Guy titles; comic-styled icon containers with border/shadow; adjusted parallax factors (`-0.3` to `-0.4`) for deeper zoom effect — by **Hamma**
- **Course detail TabBar**: Added explicit `labelColor`/`unselectedLabelColor`/`indicatorColor` using `ComicTheme.inkBlack`/`darkText` — fixes invisible tabs in light mode — by **Hamma**
- **Pomodoro pop-up modal**: Replaced inline expand/collapse arrow with full comic-styled `Dialog` — dimmed backdrop, X close button, wider layout (`maxWidth: 85vw`), compact session history (240→140px) — by **Hamma**
- **Set Target CGPA button**: Replaced `ElevatedButton` with comic `GestureDetector` + `Container` (ink red bg, 2.5px border, hard shadow); opens dialog with text field for target input; stored in `_targetCgpa` state — by **Hamma**
- **Stats text contrast**: 20+ hardcoded `Colors.white` replaced with `isDark ? ComicTheme.darkText : ComicTheme.inkBlack` in CGPA, pomodoro, screen time cards — by **Hamma**
- **Add course sheet FAB**: Sheet backgrounds now adaptive (`isDark ? ComicTheme.darkPulp : ComicTheme.surfaceWhite`) instead of always white; removed `AppTheme` dependency — by **Hamma**
- **Home screen**: PageView section height increased (320→380) for full visibility of courses/pending cards; spacer before current courses increased (`0.04`→`0.08` screen height) — by **Hamma**
- **`Check for Updates` button**: Added 10-second HTTP timeout to `checkForUpdate()`; updated `User-Agent` to `stdy4u/2.0` — by **Hamma**

### Fixed
- **White-on-white text**: `_buildSectionHeader` action button explicitly set `color: ComicTheme.surfaceWhite` on light background — now uses ComicButton's `DefaultTextStyle` which correctly resolves to `ComicTheme.inkBlack` — by **Hamma**
- **Haptic feedback not respecting settings**: ComicButton and MangaNavBar now read `useHapticFeedbackProvider` and pass `enableHaptic` flag; haptic split from audio sound — `HapticFeedback.lightImpact()` called directly in button handlers — by **Hamma**
- **Splash screen zoom**: Added `addListener(_onUpdate)` → `setState()` to all three animation controllers so the widget rebuilds on animation ticks — by **Hamma**
- **Nav bar hide on Settings**: Reads `GoRouterState.of(context).matchedLocation` directly in `build()` instead of relying on `didUpdateWidget` — by **Hamma**
- **Pomodoro card jitter**: Replaced `SizeTransition` + spring controller with `AnimatedSize` + `SpringCurve(stiffness: 400, damping: 20)` + `AnimatedSwitcher` + `FadeTransition` — by **Hamma**
- **33 broken import paths**: All `../../../../` relative imports from `lib/presentation/features/X/` depth fixed to `../../../` — was resolving above `lib/` — by **Hamma**
- **Navigation from IndexedStack children**: Settings and course detail routes moved outside `ShellRoute` to root navigator level; uses `GoRouter.of(context).push()` instead of `context.push()` — by **Hamma**
- **Notification permission on Android 13+**: Added `androidPlugin?.requestNotificationsPermission()` in `NotificationService.init()` — requested at startup on Android 13+ — by **Hamma**
- **Permission "Open Settings" buttons**: Replaced broken `launchUrl(Uri.parse('package:...'))` with native `SettingsPlugin` platform channel calling `ACTION_APPLICATION_DETAILS_SETTINGS` — by **Hamma**

### Removed
- `google_nav_bar` — replaced by custom `MangaNavBar`
- `m3e_design`, `m3e_buttons`, `icon_button_m3e`, `fab_m3e`, `toolbar_m3e`, `app_bar_m3e`, `expressive_loading_indicator`, `button_group_m3e`, `m3e_card_list` — replaced by atomic `Comic*` widgets
- `riverpod_annotation`, `flutter_svg`, `animate_do`, `m3e_collection`, `fl_chart`, `workmanager`, `flutter_background_service`, `home_widget`, `ota_update` — unused dependencies
- "Show Labels" setting — manga nav bar always shows labels
- Accent Color picker from settings — replaced by press sound toggle

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