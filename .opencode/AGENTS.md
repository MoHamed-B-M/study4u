# AGENTS.md

## Build & Verify Commands
- `flutter analyze --no-pub` — must show zero errors before committing
- `dart run build_runner build --delete-conflicting-outputs` — regenerate Hive adapters / codegen
- `flutter build apk --release --split-per-abi` — CI pipeline

## Architecture
- Clean Architecture: data / domain / presentation layers
- Riverpod (flutter_riverpod) for state management
- Hive for local persistence (type adapters auto-generated)
- GoRouter for navigation
- Material 3 with Fluent Design System hybrid

## State Management Pattern
- `dataRefreshProvider` (StateProvider<int>) shared refresh counter
- All list providers (`courseListProvider`, `taskListProvider`, `attendanceRecordsProvider`) watch it
- Mutations increment `dataRefreshProvider.notifier.state++` to trigger list re-evaluation
- Settings use `StateNotifierProvider<SettingsNotifier, AppSettings>`

## Recent Changes
- Added `professor` field to Course model (@HiveField(11))
- Added `onboardingComplete` field to AppSettings (@HiveField(5))
- Added `useDynamicColor` field to AppSettings (@HiveField(6))
- Created AddCourseSheet bottom sheet
- Created OnboardingScreen (4 slides, fade animations)
- Fixed onboarding redirect via GoRouter `redirect` callback
- Material You dynamic color toggle in Settings
- AGP 8.6.0 / Kotlin 2.1.0 in android/settings.gradle.kts
