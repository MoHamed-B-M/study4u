# STUDY4U (stdy4u) - Complete App Documentation

> **Purpose:** Comprehensive documentation for rewriting this Flutter app in Kotlin (Android Native).

---

## Table of Contents

1. [App Overview](#1-app-overview)
2. [Architecture](#2-architecture)
3. [Project Structure](#3-project-structure)
4. [Data Models](#4-data-models)
5. [Screens & Features](#5-screens--features)
6. [Navigation](#6-navigation)
7. [State Management](#7-state-management)
8. [Local Storage](#8-local-storage)
9. [Services](#9-services)
10. [Platform Integrations](#10-platform-integrations)
11. [Theme & Design System](#11-theme--design-system)
12. [Custom Widgets](#12-custom-widgets)
13. [Business Logic & Use Cases](#13-business-logic--use-cases)
14. [Dependencies Mapping](#14-dependencies-mapping)
15. [Kotlin Rewrite Guide](#15-kotlin-rewrite-guide)

---

## 1. App Overview

| Property | Value |
|----------|-------|
| **Name** | stdy4u (study4u) |
| **Version** | 1.2.1 |
| **Description** | A production-ready student productivity tool with local persistence |
| **Slogan** | STUDY SMARTER |
| **Target Users** | University/college students |
| **Architecture** | Clean Architecture (Domain / Data / Presentation) |
| **Local Database** | Hive (NoSQL, key-value) |
| **State Management** | Riverpod |
| **Navigation** | GoRouter with ShellRoute |

### Core Value Proposition

A **local-first** (no account, no cloud) student productivity companion that tracks courses, attendance, grades/CGPA, tasks, notes, study materials, and includes a Pomodoro focus timer with audio — all stored on-device.

### Feature Summary

- **Course Management** — Add/edit/delete with color coding, schedule, professor, room, credits, target grade
- **Attendance Tracking** — Present/absent/late marking with calendar view and percentage analytics
- **Task & Note Management** — Per-course tasks with urgency levels (normal/urgent), notes
- **Course Materials** — Links, uploaded files, written notes per course
- **CGPA Calculation** — Weighted GPA with letter-grade conversion and bar chart visualization
- **Pomodoro Focus Timer** — Configurable durations, background music player, session logging
- **Theme System** — Light/Dark/System mode with 8 accent colors
- **Navigation** — Floating glassmorphism bubble nav bar or standard Material nav bar
- **Notifications** — Weekly recurring class reminder notifications
- **OTA Updates** — Over-the-air update system via GitHub releases
- **Onboarding** — Animated feature preview on first launch
- **Motivational Quotes** — Animated quote expansion on course card tap

---

## 2. Architecture

```
┌─────────────────────────────────────────────────┐
│                 PRESENTATION                     │
│  Screens → Widgets → Providers (Riverpod)        │
├─────────────────────────────────────────────────┤
│                   DOMAIN                         │
│  Entities → Repository Interfaces → Use Cases    │
├─────────────────────────────────────────────────┤
│                    DATA                          │
│  Repository Impl → Hive DataSources → Bridges    │
└─────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Contains | Responsibility |
|-------|----------|----------------|
| **Domain** | Entities, Repository interfaces, Use cases | Business logic, no framework dependencies |
| **Data** | Repository implementations, Hive models, Platform bridges | Data access, persistence, native communication |
| **Presentation** | Screens, Widgets, Providers, Theme | UI, state management, user interaction |

---

## 3. Project Structure

```
lib/
├── main.dart                              # Entry point, router, app shell
├── core/
│   ├── animation/
│   │   └── page_scale.dart                # PageScaleProvider (InheritedNotifier)
│   ├── constants/
│   │   └── app_constants.dart             # All constants (box names, thresholds, channel IDs)
│   ├── errors/
│   │   └── app_exceptions.dart            # Sealed exception classes
│   ├── extensions/
│   │   └── context_extensions.dart        # BuildContext helpers
│   ├── services/
│   │   ├── notification_service.dart      # Local notifications, class reminders, update alerts
│   │   └── update_service.dart            # GitHub API update checker + APK downloader
│   └── utils/
│       ├── grade_calculator.dart          # GPA/CGPA computation, letter grade conversion
│       └── time_utils.dart               # Date/time formatting, greeting, timeAgo
├── data/
│   ├── datasources/
│   │   └── local_storage.dart             # Hive initialization, box accessors
│   ├── models/
│   │   ├── app_settings.dart              # AppSettings Hive model (typeId: 7)
│   │   ├── app_settings.g.dart            # Generated adapter
│   │   ├── screen_time_log.dart           # ScreenTimeLog Hive model (typeId: 8)
│   │   └── screen_time_log.g.dart         # Generated adapter
│   ├── platform/
│   │   ├── alarm_bridge.dart              # MethodChannel for native Android alarms
│   │   ├── calendar_bridge.dart           # MethodChannel for native Android calendar
│   │   └── screen_time_bridge.dart        # MethodChannel for Android UsageStats
│   └── repositories/
│       ├── attendance_repo_impl.dart
│       ├── course_repo_impl.dart
│       ├── material_repo_impl.dart
│       ├── pomodoro_repo_impl.dart
│       ├── screen_time_repo_impl.dart
│       ├── settings_repo_impl.dart
│       └── task_repo_impl.dart
├── domain/
│   ├── entities/
│   │   ├── attendance_record.dart
│   │   ├── course.dart
│   │   ├── course_material.dart
│   │   ├── pomodoro_session.dart
│   │   ├── screen_time_entry.dart
│   │   └── task.dart
│   ├── repositories/
│   │   ├── attendance_repository.dart
│   │   ├── course_repository.dart
│   │   ├── material_repository.dart
│   │   ├── pomodoro_repository.dart
│   │   ├── screen_time_repository.dart
│   │   ├── settings_repository.dart
│   │   └── task_repository.dart
│   └── usecases/
│       ├── attendance_analytics.dart
│       ├── cgpa_calculator.dart
│       └── schedule_optimizer.dart
├── presentation/
│   ├── features/
│   │   ├── course_detail/
│   │   │   └── course_detail_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_view.dart
│   │   ├── feature_preview/
│   │   │   └── feature_preview_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   └── settings_view.dart
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── stats/
│   │   │   └── stats_view.dart
│   │   ├── statistics/
│   │   │   └── statistics_screen.dart
│   │   └── tracker/
│   │       ├── tracker_screen.dart
│   │       └── tracker_view.dart
│   ├── providers/
│   │   ├── alarm_provider.dart
│   │   ├── calendar_provider.dart
│   │   └── screen_time_provider.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── design_tokens.dart
│   │   └── theme_provider.dart
│   └── widgets/
│       ├── add_course_sheet.dart
│       ├── animated_counter.dart
│       ├── app_card.dart
│       ├── bubble_nav_bar.dart
│       ├── circular_progress_ring.dart
│       ├── dashboard_card.dart
│       ├── gradient_button.dart
│       ├── pill_chip.dart
│       ├── quote_expansion_route.dart
│       ├── slide_out_panel.dart
│       ├── squish_button.dart
│       ├── staggered_list.dart
│       ├── study_bottom_nav.dart
│       ├── study_charts.dart
│       └── update_dialog.dart
└── shared/
    ├── models/
    │   ├── models.dart                    # Hive shared models
    │   └── models.g.dart                  # Generated adapters
    └── providers/
        ├── logic_providers.dart           # All core Riverpod providers
        └── pomodoro_provider.dart         # PomodoroState + PomodoroNotifier
```

---

## 4. Data Models

### 4.1 Course (Hive typeId: 0)

```dart
class Course {
  String id;              // UUID
  String code;            // e.g., "MATH 201"
  String name;            // e.g., "Linear Algebra"
  String room;            // e.g., "Room 301"
  String professor;       // e.g., "Dr. Smith"
  String startTime;       // e.g., "09:00 AM"
  String endTime;         // e.g., "10:30 AM"
  int colorValue;         // Color integer value (e.g., 0xFF4ADE80)
  double targetGrade;     // Target GPA (2.0-4.0), default 4.0
  double currentGrade;    // Current GPA (0.0-4.0), default 0.0
  double creditHours;     // Credit hours (1-6), default 3.0
  String scheduleJson;    // JSON array of weekday names: ["Mon","Wed","Fri"]
}
```

**Computed Properties:**
- `Color get color => Color(colorValue)`
- `double get percentage => (currentGrade / targetGrade * 100).clamp(0, 100)`

### 4.2 StudyTask (Hive typeId: 2)

```dart
class StudyTask {
  String id;              // UUID
  String title;           // Task title
  DateTime dueDate;       // Due date/time
  TaskUrgency urgency;    // urgent (0) or normal (1)
  bool isCompleted;       // Completion status
  String courseId;        // Associated course ID (empty string if unlinked)
  String content;         // Task content/description
  String type;            // 'task' or 'note'
}
```

**Enums:**
```dart
enum TaskUrgency { urgent, normal }     // typeId: 1
enum TaskType { task, note }
```

### 4.3 AttendanceRecord (Hive typeId: 4)

```dart
class AttendanceRecord {
  String id;              // Format: "{courseId}_{yyyymmdd}"
  String courseId;        // Associated course ID
  DateTime date;          // Attendance date
  AttendanceStatus status; // present (0), absent (1), late (2), upcoming (3)
}
```

**Enum:**
```dart
enum AttendanceStatus { present, absent, late, upcoming }  // typeId: 3
```

### 4.4 CourseMaterial (Hive typeId: 6)

```dart
class CourseMaterial {
  String id;              // UUID
  String courseId;        // Associated course ID
  String title;           // Material title
  String type;            // 'link', 'file', or 'note'
  String content;         // URL, file path, or note text
  DateTime createdAt;     // Creation timestamp
}
```

### 4.5 PomodoroSettings (Hive typeId: 5)

```dart
class PomodoroSettings {
  int focusDuration;      // Minutes, default 25
  int shortBreakDuration; // Minutes, default 5
  int longBreakDuration;  // Minutes, default 15
}
```

### 4.6 AppSettings (Hive typeId: 7)

```dart
class AppSettings {
  String id;                      // Always 'default'
  int primaryColorValue;          // Accent color (default 0xFF4ADE80 - green)
  String themeMode;               // 'system', 'light', or 'dark'
  bool notificationEnabled;       // Default true
  String userName;                // Default ''
  bool onboardingComplete;        // Default false
  bool useFloatingNavBar;         // Default false
  bool hapticFeedback;            // Default true
}
```

### 4.7 ScreenTimeLog (Hive typeId: 8)

```dart
class ScreenTimeLog {
  String id;              // Format: "{packageName}_{yyyymmdd}"
  String appPackageName;  // Android package name
  DateTime date;          // Log date
  int durationMinutes;    // Usage duration in minutes
}
```

### 4.8 Domain Entities

These are the app-level entities used in the presentation layer:

```dart
class CourseEntity {
  String id, code, name, room, professor, startTime, endTime, scheduleJson;
  int colorValue;
  double targetGrade, currentGrade, creditHours;
  List<String> weekDays;
}

class TaskEntity {
  String id, courseId, title, content;
  TaskType type;
  TaskUrgency urgency;
  DateTime dueDate;
  bool isCompleted;
}

class AttendanceRecordEntity {
  String id, courseId;
  DateTime date;
  AttendanceStatus status;
}

class CourseMaterialEntity {
  String id, courseId, title, type, content;
  DateTime createdAt;
}

class PomodoroSessionEntity {
  String id;
  String? courseId;
  int durationSeconds;
  DateTime timestamp;
  bool completed;
}

class ScreenTimeEntryEntity {
  String id, appPackageName;
  DateTime date;
  int durationMinutes;
}
```

### 4.9 Use Case Result Models

```dart
class CgpaResult {
  double cgpa;           // 0.0-4.0
  double percentage;     // 0-100
  String letterGrade;    // A+, A, A-, B+, etc.
  double delta;          // Change (default 0.0)
}

class AttendanceAnalyticsResult {
  double percentage;     // 0-100
  int present, absent, late, total;
  bool isBelowThreshold; // true if percentage < 75%
  bool get hasRecords => total > 0;
}

class UpNextResult {
  CourseEntity? course;
  bool hasNext;
}
```

### 4.10 Platform Bridge Models

```dart
class ScreenTimeAppEntry {
  String appPackageName;
  DateTime date;
  int durationMinutes;
}

class CalendarEvent {
  String eventId, title;
  DateTime startDate, endDate;
}

class UpdateInfo {
  String latestVersion, downloadUrl;
  String? releaseNotes;
  bool isNewer;
}
```

---

## 5. Screens & Features

### 5.1 Splash Screen

**File:** `presentation/features/splash/splash_screen.dart`
**Class:** `SplashScreen` (StatefulWidget)

**UI:**
- Dark navy background (`#111625`)
- Glowing green radial gradient at bottom (`#4ADE80`)
- Book icon inside semi-transparent circle
- "stdy4u" title in bold white 38px
- "STUDY SMARTER" subtitle in spaced uppercase

**Animations:**
- 2.2s fade-in + scale-in + glow-in
- 500ms fade transition to next page after 2.8s delay

**Navigation:** Routes to either `FeaturePreviewScreen` (first launch) or `Stdy4uApp`

### 5.2 Feature Preview / Onboarding

**File:** `presentation/features/feature_preview/feature_preview_screen.dart`
**Class:** `FeaturePreviewScreen` (ConsumerStatefulWidget)

**Purpose:** First-launch showcase of app features

**3 Animated Scenes (6-second loop):**
1. **Focus Timer** — Animated pomodoro ring with countdown
2. **Schedule** — Animated schedule cards sliding in
3. **Tasks** — Animated task icons and falling circles

**UI Elements:**
- 220x330 viewport with rotating scenes
- Scene label (green text)
- 3-dot page indicator
- "START APPLICATION" button → sets `onboardingComplete = true`

### 5.3 Home Screen

**File:** `presentation/features/home/home_screen.dart`
**Class:** `HomeScreen` (ConsumerStatefulWidget)

**UI Elements:**
- **Header:** Greeting ("Good Morning/Afternoon/Evening") + pending task count + settings button
- **PageView (320px height, 3 pages):**
  - **Up Next page:** "UP NEXT" mint green card + Quick Overview (course count + pending tasks)
  - **Tasks page:** Due tasks list (max 3) with checkbox, due date, "URGENT" badge, "+N more"
  - **Quick Stats page:** Attendance circular progress + Present/Absent/Late stats + Pomodoro card
- **Page indicator dots** (3 dots, active is wider)
- **Horizontal course list** (180px height, 150px wide cards) → OpenContainer to CourseDetailScreen
- **FAB:** "Add Course" button → opens AddCourseSheet

### 5.4 Course Detail Screen

**File:** `presentation/features/course_detail/course_detail_screen.dart`
**Class:** `CourseDetailScreen` (ConsumerStatefulWidget)

**4 Tabs:**

| Tab | Content |
|-----|---------|
| **Info** | Professor, Schedule, Room, Credits info cards. Grade progress (current/target). Attendance quick view (Present/Absent/Rate) |
| **Materials** | List of CourseMaterial (links/files/notes) with delete. "Add Material" bottom sheet with SegmentedButton (Link/Note/File). File picker for PDFs, images, docs |
| **Notes** | List of notes (TaskEntity with type=note). "Add Note" bottom sheet |
| **Tasks** | List of tasks with toggle completion, URGENT badge. "Add Task" bottom sheet with date picker and urgency toggle |

**AppBar:** Back button, course name, PopupMenuButton (Edit/Delete)

### 5.5 Tracker Screen

**File:** `presentation/features/tracker/tracker_screen.dart`
**Class:** `TrackerScreen` (ConsumerStatefulWidget)

**UI Elements:**
- **Attendance stats card:** CircularPercentIndicator (72px radius), percentage, Present/Absent/Late counters
- **Calendar card:** TableCalendar (2020-2030), customizable styling
- **Today's Schedule:** Course list with Present/Late action chips

**Logic:** `_markAttendance()` creates attendance ID from `courseId_yyyymmdd`, saves to repository

### 5.6 Statistics Screen

**File:** `presentation/features/stats/stats_view.dart`
**Class:** `StatsView` (ConsumerStatefulWidget)

**UI Elements:**
- **AttendanceCard:** Green card with grade letter, attendance rate, circular progress ring
- **CGPA Breakdown:** StudyBarChart with colored bars per course (4.0 scale)
- **PomodoroCard:** Timer display, session count, Start/Pause/Reset buttons
- **Subject Performance:** List of courses with LinearProgressIndicator, letter grade, percentage

**Animations:** FadeTransition with staggered intervals (0-0.4, 0.2-0.6, 0.4-0.8, 0.6-1.0)

### 5.7 Settings Screen

**File:** `presentation/features/settings/settings_view.dart`
**Class:** `SettingsView` (ConsumerWidget)

**Sections:**

| Section | Items |
|---------|-------|
| **APPEARANCE** | Theme toggle (System/Light/Dark via CupertinoActionSheet), Accent Color picker (8 colors) |
| **PREFERENCES** | Haptic Feedback toggle, Notifications toggle |
| **ABOUT** | App version info, Check for Updates, GitHub Repository link |

**Accent Color Palette:**
`#A18CFF`, `#8F99FB`, `#FBBF24`, `#60A5FA`, `#F472B6`, `#4ADE80`, `#FB923C`, `#34D399`

### 5.8 Dashboard View (Alternative)

**File:** `presentation/features/dashboard/dashboard_view.dart`
**Class:** `DashboardView` (ConsumerWidget)

**Purpose:** Alternative dashboard using DesignTokens lavender/blue color scheme with flutter_animate effects

**UI Elements:**
- Header: "STUDY4U" label, greeting
- Two info cards: Pending Tasks (blue), Total Courses (cream)
- "Next Class" card with CircularProgressRing
- Horizontal course list with CourseCard widgets
- "Today's Tasks" list with checkbox toggles, urgency badges
- BlobBackground decorative elements

---

## 6. Navigation

**Router:** GoRouter v14.2.0 with ShellRoute + GlobalKey\<NavigatorState\>

### Route Table

| Route | Screen | Transition | Notes |
|-------|--------|------------|-------|
| `/` | HomeScreen | Default | Inside ShellRoute |
| `/tracker` | TrackerScreen | Default | Inside ShellRoute |
| `/stats` | StatisticsScreen | Default | Inside ShellRoute |
| `/settings` | SettingsScreen | Default | Inside ShellRoute |
| `/course/:id` | CourseDetailScreen | SlideTransition (right-to-left) | Custom transition |

### Navigation Flow

```
App Start
    │
    ▼
LocalStorage.init()
    │
    ├── onboardingComplete = false
    │       │
    │       ▼
    │   SplashScreen (2.8s)
    │       │
    │       ▼
    │   FeaturePreviewScreen
    │       │
    │       ▼ "START APPLICATION"
    │   Stdy4uApp (MaterialApp.router)
    │
    └── onboardingComplete = true
            │
            ▼
        SplashScreen (2.8s)
            │
            ▼
        Stdy4uApp (MaterialApp.router)
            │
            ▼
        MainScreen (ShellRoute wrapper)
            │
            ├── BubbleNavBar index 0 → /
            ├── BubbleNavBar index 1 → /tracker
            ├── BubbleNavBar index 2 → /stats
            ├── Settings icon → /settings
            └── Course tap → /course/:id
```

### ShellRoute Wrapper (MainScreen)

- Wraps child with `BubbleNavBar` (or standard `NavigationBar`)
- Applies `PageScaleProvider` for zoom-out effect during `QuoteExpansionRoute` transitions
- `AnimatedSwitcher` for fade transitions between screens

### Custom Transitions

- **QuoteExpansionRoute:** Custom PageRoute that animates an expanding rectangle from source position to full screen, displaying a random motivational study quote. Scales background page down to 96%.
- **CourseDetailScreen:** `CustomTransitionPage` with `SlideTransition` (right-to-left, easeInOutCubic)

---

## 7. State Management

All state management uses **Riverpod** (flutter_riverpod v2.5.1).

### 7.1 Repository Providers

```dart
courseRepositoryProvider        → CourseRepositoryImpl()
taskRepositoryProvider          → TaskRepositoryImpl()
attendanceRepositoryProvider    → AttendanceRepositoryImpl()
materialRepositoryProvider      → MaterialRepositoryImpl()
pomodoroRepositoryProvider      → PomodoroRepositoryImpl()
cgpaCalculatorProvider          → CgpaCalculatorUseCase()
attendanceAnalyticsProvider     → AttendanceAnalyticsUseCase()
scheduleOptimizerProvider       → ScheduleOptimizerUseCase()
settingsRepositoryProvider      → SettingsRepositoryImpl()
```

### 7.2 Data Refresh Provider

```dart
dataRefreshProvider = StateProvider<int>((ref) => 0);
```

Incremented after every data mutation to trigger reactive rebuilds across the app.

### 7.3 Derived Data Providers

| Provider | Type | Logic |
|----------|------|-------|
| `courseListProvider` | `Provider<List<CourseEntity>>` | Watches `dataRefreshProvider` + repo.getCourses() |
| `taskListProvider` | `Provider<List<TaskEntity>>` | Watches `dataRefreshProvider` + repo.getTasks() |
| `pendingTaskCountProvider` | `Provider<int>` | `tasks.where((t) => !t.isCompleted).length` |
| `attendanceRecordsProvider` | `Provider<List<AttendanceRecordEntity>>` | Watches dataRefresh + repo.getRecords() |
| `attendanceAnalyticsResultProvider` | `Provider<AttendanceAnalyticsResult>` | Executes use case on records |
| `cgpaResultProvider` | `Provider<CgpaResult>` | Executes use case on courses |
| `upNextProvider` | `Provider<UpNextResult>` | Executes use case on courses |
| `courseDetailProvider` | `Provider.family<CourseEntity?, String>` | Finds course by ID |
| `courseMaterialsProvider` | `Provider.family<List<CourseMaterialEntity>, String>` | Materials filtered by courseId |
| `courseTasksProvider` | `Provider.family<List<TaskEntity>, String>` | Tasks (type=task) filtered by courseId |
| `courseNotesProvider` | `Provider.family<List<TaskEntity>, String>` | Notes (type=note) filtered by courseId |
| `greetingProvider` | `Provider<String>` | Returns "Good Morning"/"Good Afternoon"/"Good Evening" |
| `pomodoroSessionsProvider` | `Provider<List<PomodoroSessionEntity>>` | Watches dataRefresh + repo.getSessions() |

### 7.4 Pomodoro State

```dart
// Enum
enum PomodoroStatus { focus, shortBreak, longBreak, idle }

// State
class PomodoroState {
  int remainingSeconds;
  PomodoroStatus status;
  bool isActive;
  int completedSessions;
  String? courseId;
  int focusMinutes;       // default 25
  int shortBreakMinutes;  // default 5
  int longBreakMinutes;   // default 15
  String? musicFilePath;
  bool isMusicPlaying;

  String get timerString; // Formatted "MM:SS"
}

// Notifier Methods
startTimer({courseId?})   // Starts 1-second periodic timer, plays music
pauseTimer()              // Cancels timer, pauses audio
resetTimer()              // Pauses, stops audio, resets to focus duration
skipSession()             // Calls _handleSessionComplete()
setDurations(focus, shortBreak, longBreak)
setMusicFile(path?)
toggleMusic()
```

### 7.5 Settings State

```dart
// SettingsNotifier Methods
setThemeMode(mode)              // 'system' / 'light' / 'dark'
setPrimaryColor(value)          // Accent color int
setNotificationEnabled(enabled)
setUserName(name)
setOnboardingComplete(value)
setUseFloatingNavBar(value)
setHapticFeedback(value)

// Derived Providers
themeModeProvider       → ThemeMode
primaryColorProvider    → int
useFloatingNavBarProvider → bool
useHapticFeedbackProvider → bool
```

---

## 8. Local Storage

**Engine:** Hive (hive_flutter v2.2.3)

### 8.1 Initialization

```dart
// data/datasources/local_storage.dart
Hive.initFlutter()
// Register 9 type adapters (Course, TaskUrgency, StudyTask, AttendanceStatus,
// AttendanceRecord, PomodoroSettings, ScreenTimeLog, AppSettings, CourseMaterial)
// Open 8 boxes in parallel via Future.wait()
```

### 8.2 Hive Boxes

| Box Name | Type | Key Format | Purpose |
|----------|------|------------|---------|
| `courses` | `Box<Course>` | Course ID (UUID) | All courses |
| `tasks` | `Box<StudyTask>` | Task ID (UUID) | All tasks |
| `attendance` | `Box<AttendanceRecord>` | `{courseId}_{yyyymmdd}` | Attendance records |
| `settings` | `Box<PomodoroSettings>` | Single key | Pomodoro configuration |
| `screenTime` | `Box<ScreenTimeLog>` | `{packageName}_{yyyymmdd}` | Screen time logs |
| `appSettings` | `Box<AppSettings>` | `'default'` | App settings (single entry) |
| `pomodoroSessions` | `Box<String>` | UUID | Pomodoro sessions (JSON strings) |
| `materials` | `Box<CourseMaterial>` | Material ID (UUID) | Course materials |

### 8.3 Static Accessors

```dart
LocalStorage.coursesBox
LocalStorage.tasksBox
LocalStorage.attendanceBox
LocalStorage.pomodoroBox
LocalStorage.screenTimeBox
LocalStorage.appSettingsBox
LocalStorage.materialsBox
LocalStorage.pomodoroSessionsBox
LocalStorage.isReady
LocalStorage.initError
LocalStorage.onReady(callback)
```

### 8.4 Data Patterns

- **Attendance record IDs:** `{courseId}_{yyyymmdd}` (e.g., `abc123_20240315`)
- **Course schedule:** JSON string of weekday names (e.g., `['Mon', 'Wed', 'Fri']`)
- **Pomodoro sessions:** Serialized to JSON strings with fields: `id`, `courseId`, `durationSeconds`, `timestamp` (ISO 8601), `completed`
- **Settings:** Single key-value pair with key `'default'`

---

## 9. Services

### 9.1 NotificationService

**Singleton:** `NotificationService.instance`

**Channels:**
| Channel ID | Name | Purpose |
|------------|------|---------|
| `general` | General Notifications | Task reminders, course updates |
| `class_reminders` | Class Reminders | Upcoming classes |
| `app_updates_channel` | App Updates | New version alerts |

**Key Methods:**
```dart
init({onNotificationTap})                    // Initializes plugin, creates channels
showNotification({id, title, body, payload}) // Shows immediate notification
triggerUpdateNotification(version)           // Shows update notification (green color)
scheduleClassReminder({id, courseName, startTime, weekDays, minutesBefore})
                                             // Weekly recurring via zonedSchedule
cancelNotification(id)
cancelAll()
parseTime(timeStr)                           // "09:00 AM" → DateTime
```

### 9.2 UpdateService

**API:** `https://api.github.com/repos/MoHamed-B-M/study4u/releases/latest`

```dart
static UpdateInfo? lastKnownUpdate

checkForUpdate()           // Fetches GitHub releases, compares versions
downloadApk({url, onProgress})  // Downloads APK to temp dir with progress
```

**Version Comparison:** Semantic versioning (splits on '.', pads shorter with 0s)

---

## 10. Platform Integrations

### 10.1 Android MethodChannels

| Channel ID | Bridge Class | Methods | Purpose |
|------------|-------------|---------|---------|
| `com.stdy4u/screen_time` | ScreenTimeBridge | `getUsageStats` | Fetch app usage stats via UsageStatsManager |
| `com.stdy4u/calendar` | CalendarBridge | `addEvent`, `removeEvent`, `fetchEvents` | Native calendar CRUD |
| `com.stdy4u/alarm` | AlarmBridge | `scheduleAlarm`, `cancelAlarm` | Native alarm scheduling |

### 10.2 Notifications

- 3 Android notification channels
- Weekly recurring class reminders via `zonedSchedule` with `DateTimeComponents.dayOfWeekAndTime`
- Timezone support via `timezone` package

### 10.3 Audio

- Pomodoro timer background music player via `just_audio`
- File-based audio playback (`setFilePath`)
- Play/pause/stop controls integrated with Pomodoro state

### 10.4 File Management

- Course materials stored in `getApplicationDocumentsDirectory()/study4u_materials/`
- `file_picker` for selecting PDFs, images, docs
- Supported extensions: pdf, jpg, jpeg, png, gif, webp, doc, docx, ppt, pptx, xls, xlsx, txt

### 10.5 OTA Updates

- GitHub releases API
- Version comparison (semantic versioning)
- APK download with progress tracking
- Auto-install via `open_filex`

---

## 11. Theme & Design System

### 11.1 AppTheme (Primary Theme)

**Static Color Constants:**
| Name | Value | Usage |
|------|-------|-------|
| `primary` | `#4ADE80` (green) | Primary accent, active states |
| `secondary` | `#2DD4BF` (teal) | Secondary accent |
| `tertiary` | `#FBBF24` (amber) | Tertiary accent |
| `background` | `#F4F9F6` (light sage) | Light mode background |
| `surface` | `#F8FAF9` | Light mode surface |
| `surfaceDark` | `#1B2236` | Dark mode surface |
| `scaffoldDark` | `#111625` (dark navy) | Dark mode background |
| `textPrimary` | `#1E293B` | Primary text |
| `error` | `#BA1A1A` | Error states |
| `warningRed` | `#EF4444` | Warnings, urgent badges |
| `outline` | `#CBD5E1` | Borders |
| `activeBlue` | `#38BDF8` | Active blue states |
| `mintGreenLight` | `#A7F3D0` | Up Next card background |
| `amberYellow` | `#F59E0B` | Late attendance indicator |

**Radius Constants:**
| Name | Value |
|------|-------|
| `radiusXXL` | 32.0 |
| `radiusMD` | 16.0 |
| `radiusCard` | 24.0 |
| `radiusPill` | 9999.0 |
| `standardPadding` | 24.0 |

**Typography:** Google Fonts `Fredoka`
- displayLarge: 48px w800
- displayMedium: 32px w700
- displaySmall: 24px w700
- titleLarge: 20px w700
- titleMedium: 16px w600
- bodyLarge: 16px w400
- bodyMedium: 14px w400
- bodySmall: 12px w400
- labelLarge: 14px w600
- labelMedium: 12px w500
- labelSmall: 10px w500

### 11.2 DesignTokens (Alternative Theme)

Used by Dashboard, Tracker, and Stats views:

**Colors:**
| Name | Value |
|------|-------|
| `primaryLavender` | `#A18CFF` |
| `secondaryBlue` | `#8F99FB` |
| `cardCream` | `#FFF3E0` |
| `cardBlue` | `#E8F0FE` |
| `cardPink` | `#FDE8E8` |
| `cardPurple` | `#F0E6FF` |
| `cardGreen` | `#E8F5E9` |
| `cardTeal` | `#E0F2F1` |
| `textPrimary` | `#212121` |
| `textSecondary` | `#757575` |
| `textTertiary` | `#9E9E9E` |
| `background` | `#F7F7FA` |
| `surface` | `#FFFFFF` |
| `surfaceVariant` | `#F0F0F5` |

**Spacing:** XS=4, SM=8, MD=16, LG=24, XL=32
**Radii:** SM=12, MD=20, LG=24, XL=28, Pill=9999
**Shadows:** cardShadow (blur 20, offset 4), cardShadowHover (blur 24, offset 8)

---

## 12. Custom Widgets

### 12.1 BubbleNavBar
**File:** `presentation/widgets/bubble_nav_bar.dart`
**Purpose:** Floating glassmorphism bottom navigation bar with 3 items. Active item expands with green background pill and label text.

### 12.2 AppCard
**File:** `presentation/widgets/app_card.dart`
**Purpose:** Versatile card container with 3 variants:
- Default: rounded card with border, shadow, dark-mode aware
- `AppCard.glass()`: Semi-transparent white with blur shadow (glassmorphism)
- `AppCard.gradient()`: Linear gradient background with shadow

### 12.3 AddCourseSheet
**File:** `presentation/widgets/add_course_sheet.dart`
**Purpose:** Bottom sheet form for adding/editing courses. Fields: name, code, professor, room, credits (ListWheelScrollView 1-6), start/end time (TimePicker), weekday selector (FilterChip), color picker (8 circles), target grade (Slider 2.0-4.0).

### 12.4 UpdateDialog
**File:** `presentation/widgets/update_dialog.dart`
**Purpose:** Full-screen modal dialog for app updates. Shows version, release notes, Download/Ignore buttons. On download: progress bar with percentage. Downloads APK and opens with `OpenFilex`.

### 12.5 DashboardCard / InfoCard / CourseCard / NextClassCard / BlobBackground
**File:** `presentation/widgets/dashboard_card.dart`
- **DashboardCard:** Basic card container with customizable bg color, padding, radius, shadow
- **InfoCard:** Dashboard card with icon, value, label
- **CourseCard:** 120px wide card with icon, code, name
- **NextClassCard:** Full-width colored card showing next class with CircularProgressRing
- **BlobBackground:** 3 positioned circular gradient blobs for decorative background

### 12.6 CircularProgressRing / MiniProgressRing
**File:** `presentation/widgets/circular_progress_ring.dart`
- **CircularProgressRing:** CustomPainter-based ring with sweep gradient, optional label/sublabel
- **MiniProgressRing:** Simpler 4px stroke ring for compact displays

### 12.7 StudyBarChart / AttendanceCard / PomodoroCard
**File:** `presentation/widgets/study_charts.dart`
- **StudyBarChart:** Vertical bar chart with Y-axis labels, gradient bars
- **AttendanceCard:** Green card with grade letter + attendance rate
- **PomodoroCard:** Timer card with display, session count, Start/Pause/Reset buttons

### 12.8 SquishButton
**File:** `presentation/widgets/squish_button.dart`
**Purpose:** Animated button that "squishes" on press (scale + border radius animation)

### 12.9 QuoteExpansionRoute
**File:** `presentation/widgets/quote_expansion_route.dart`
**Purpose:** Custom PageRoute that animates expanding rectangle from source to full screen with motivational quote. Scales background to 96%.

**8 Hardcoded Quotes:**
1. "Success is the sum of small efforts..." — R. Collier
2. "The secret of getting ahead is getting started." — Mark Twain
3. "It does not matter how slowly you go..." — Confucius
4. "The only way to do great work is to love what you do." — Steve Jobs
5. "In the middle of difficulty lies opportunity." — Albert Einstein
6. "Education is the most powerful weapon..." — Nelson Mandela
7. "The future belongs to those who believe in the beauty of their dreams." — Eleanor Roosevelt
8. "Don't let yesterday take up too much of today." — Will Rogers

### 12.10 StaggeredList
**File:** `presentation/widgets/staggered_list.dart`
**Purpose:** Column of items that animate in with staggered fade+slide-up entrance

### 12.11 PillChip
**File:** `presentation/widgets/pill_chip.dart`
**Purpose:** Small rounded badge with semi-transparent background and colored text

### 12.12 GradientButton
**File:** `presentation/widgets/gradient_button.dart`
**Purpose:** Full-width button with gradient background, optional icon, pill shape, shadow

### 12.13 SlideOutPanel
**File:** `presentation/widgets/slide_out_panel.dart`
**Purpose:** Swipeable row that reveals action buttons from the right side

### 12.14 AnimatedCounter
**File:** `presentation/widgets/animated_counter.dart`
**Purpose:** Text widget that animates from 0 to target value with elastic curve

### 12.15 StudyBottomNav
**File:** `presentation/widgets/study_bottom_nav.dart`
**Purpose:** Alternative bottom navigation with 4 items and a central floating gradient add button

### 12.16 PageScaleProvider
**File:** `core/animation/page_scale.dart`
**Purpose:** InheritedNotifier that provides ValueNotifier\<double\> for page scale during QuoteExpansionRoute

---

## 13. Business Logic & Use Cases

### 13.1 GradeCalculator

```dart
letterToGpa(letter: String) → double
  // "A+" → 4.0, "A" → 4.0, "A-" → 3.7, "B+" → 3.3, "B" → 3.0,
  // "B-" → 2.7, "C+" → 2.3, "C" → 2.0, "C-" → 1.7, "D+" → 1.3,
  // "D" → 1.0, "D-" → 0.7, "F" → 0.0

gpaToLetter(gpa: double) → String
  // >=3.7 → "A", >=3.3 → "B+", >=3.0 → "B", >=2.7 → "B-",
  // >=2.3 → "C+", >=2.0 → "C", >=1.7 → "C-", >=1.3 → "D+",
  // >=1.0 → "D", >=0.7 → "D-", else "F"

computeCgpa(grades: List<({double grade, double credits})>) → double
  // Weighted average: sum(grade*credits)/sum(credits), clamped 0-4.0

percentageFromGpa(gpa: double) → double
  // (gpa / 4.0 * 100).clamp(0, 100)
```

### 13.2 CgpaCalculatorUseCase

```dart
// Input: List<CourseEntity>
// Logic: Filter courses with currentGrade > 0, extract grade+credits pairs
// Output: CgpaResult(cgpa, percentage, letterGrade)
```

### 13.3 AttendanceAnalyticsUseCase

```dart
// Input: List<AttendanceRecordEntity>
// Logic: Count present, absent, late, total. attended = present + late
//        percentage = (attended/total)*100. isBelowThreshold = percentage < 75.0
// Output: AttendanceAnalyticsResult(percentage, present, absent, late, total, isBelowThreshold)
```

### 13.4 ScheduleOptimizerUseCase

```dart
// Input: List<CourseEntity>
// Logic: Get current time as "HH:MM". Find next course whose startTime > current time.
//        If none found, return first course (wraps to next day).
// Output: UpNextResult(course, hasNext)
```

### 13.5 TimeUtils

```dart
formatTime(DateTime) → "hh:mm a"
formatDate(DateTime) → "MMM dd, yyyy"
formatDateShort(DateTime) → "MMM dd"
formatDay(DateTime) → "EEEE"
timeAgo(DateTime) → "JUST NOW" / "N MINUTES AGO" / "YESTERDAY" / etc.
greeting() → "Good Morning" / "Good Afternoon" / "Good Evening"
isSameDay(a, b) → bool
```

---

## 14. Dependencies Mapping

### Flutter → Kotlin Equivalents

| Flutter Package | Purpose | Kotlin Equivalent |
|----------------|---------|-------------------|
| `flutter_riverpod` | State management | Hilt / Koin + ViewModel + StateFlow |
| `go_router` | Navigation | Jetpack Navigation Compose |
| `hive` + `hive_flutter` | Local NoSQL DB | Room (SQLite) / SQLDelight |
| `hive_generator` | TypeAdapter code gen | Room compiler / KSP |
| `google_fonts` | Fredoka font | Custom font in res/font |
| `flutter_svg` | SVG rendering | Compose SVG / ImageVector |
| `animate_do` | Animation utilities | Compose Animation APIs |
| `flutter_animate` | Declarative animations | Compose Animation APIs |
| `intl` | Date formatting | java.text.SimpleDateFormat / java.time |
| `just_audio` | Audio playback | MediaPlayer / ExoPlayer |
| `fl_chart` | Charts | MPAndroidChart / Vico |
| `percent_indicator` | Circular progress | CircularProgressIndicator Compose |
| `table_calendar` | Calendar widget | Compose Calendar library |
| `flutter_local_notifications` | Local notifications | NotificationManager + NotificationCompat |
| `workmanager` | Background tasks | WorkManager |
| `uuid` | UUID generation | java.util.UUID |
| `flutter_background_service` | Background service | ForegroundService |
| `home_widget` | Home screen widgets | Glance (AppWidgets) |
| `url_launcher` | Open URLs | Intent.ACTION_VIEW |
| `file_picker` | File picker | ActivityResultContracts |
| `package_info_plus` | App version info | PackageManager |
| `http` | HTTP client | Retrofit / OkHttp / Ktor |
| `open_filex` | Open files | Intent.ACTION_VIEW with MIME type |
| `timezone` | Timezone data | java.time.ZoneId |
| `animations` | Material motion | Compose motion APIs |
| `path_provider` | File system paths | Context.filesDir / getExternalFilesDir |
| `flutter/services.dart` | MethodChannel | Platform Channel (MethodChannel) |

### Key Constants to Preserve

| Constant | Value | Usage |
|----------|-------|-------|
| Attendance threshold | 75.0% | Below this triggers warning |
| Pomodoro focus | 25 minutes | Default focus duration |
| Pomodoro short break | 5 minutes | Default short break |
| Pomodoro long break | 15 minutes | Default long break |
| Max grade points | 4.0 | GPA scale maximum |
| MethodChannel: screen_time | `com.stdy4u/screen_time` | Native screen time bridge |
| MethodChannel: calendar | `com.stdy4u/calendar` | Native calendar bridge |
| MethodChannel: alarm | `com.stdy4u/alarm` | Native alarm bridge |
| Notification: general | `general` | General notifications channel |
| Notification: class_reminders | `class_reminders` | Class reminders channel |
| Notification: app_updates | `app_updates_channel` | App updates channel |
| GitHub API URL | `https://api.github.com/repos/MoHamed-B-M/study4u/releases/latest` | OTA updates |

---

## 15. Kotlin Rewrite Guide

### Recommended Architecture

```
app/
├── data/
│   ├── local/
│   │   ├── db/
│   │   │   ├── AppDatabase.kt          // Room database
│   │   │   ├── CourseDao.kt
│   │   │   ├── TaskDao.kt
│   │   │   ├── AttendanceDao.kt
│   │   │   ├── MaterialDao.kt
│   │   │   └── PomodoroSessionDao.kt
│   │   └── datastore/
│   │       └── SettingsDataStore.kt     // DataStore for settings
│   ├── remote/
│   │   └── UpdateApi.kt                // Retrofit interface for GitHub API
│   └── repository/
│       ├── CourseRepositoryImpl.kt
│       ├── TaskRepositoryImpl.kt
│       ├── AttendanceRepositoryImpl.kt
│       ├── MaterialRepositoryImpl.kt
│       ├── PomodoroRepositoryImpl.kt
│       └── SettingsRepositoryImpl.kt
├── domain/
│   ├── model/
│   │   ├── Course.kt
│   │   ├── Task.kt
│   │   ├── AttendanceRecord.kt
│   │   ├── CourseMaterial.kt
│   │   ├── PomodoroSession.kt
│   │   └── AppSettings.kt
│   ├── repository/
│   │   ├── CourseRepository.kt
│   │   ├── TaskRepository.kt
│   │   └── ... (interfaces)
│   └── usecase/
│       ├── CalculateCgpaUseCase.kt
│       ├── AttendanceAnalyticsUseCase.kt
│       └── ScheduleOptimizerUseCase.kt
├── di/
│   └── AppModule.kt                    // Hilt/Koin module
├── platform/
│   ├── ScreenTimeBridge.kt             // MethodChannel
│   ├── CalendarBridge.kt               // MethodChannel
│   └── AlarmBridge.kt                  // MethodChannel
├── service/
│   ├── NotificationService.kt
│   ├── UpdateService.kt
│   └── PomodoroService.kt
├── ui/
│   ├── theme/
│   │   ├── Color.kt
│   │   ├── Type.kt
│   │   └── Theme.kt
│   ├── navigation/
│   │   └── AppNavigation.kt
│   ├── home/
│   │   ├── HomeScreen.kt
│   │   └── HomeViewModel.kt
│   ├── course/
│   │   ├── CourseDetailScreen.kt
│   │   └── CourseDetailViewModel.kt
│   ├── tracker/
│   │   ├── TrackerScreen.kt
│   │   └── TrackerViewModel.kt
│   ├── stats/
│   │   ├── StatsScreen.kt
│   │   └── StatsViewModel.kt
│   ├── settings/
│   │   ├── SettingsScreen.kt
│   │   └── SettingsViewModel.kt
│   ├── splash/
│   │   └── SplashScreen.kt
│   ├── onboarding/
│   │   └── OnboardingScreen.kt
│   └── components/
│       ├── BubbleNavBar.kt
│       ├── AppCard.kt
│       ├── CircularProgressRing.kt
│       ├── StudyBarChart.kt
│       ├── SquishButton.kt
│       └── ... (other reusable composables)
└── Study4uApp.kt                       // Application class
```

### Key Migration Notes

1. **Hive → Room:** Each Hive box becomes a Room @Entity + @Dao. TypeAdapter typeIds map to table identifiers.
2. **Riverpod → ViewModel + StateFlow:** Each provider becomes a ViewModel with Kotlin StateFlow/SharedFlow.
3. **GoRouter → Jetpack Navigation:** ShellRoute becomes NavHost with bottom bar. Route strings become sealed class or NavRoute.
4. **MethodChannel:** Platform bridges stay as MethodChannel with same IDs.
5. **Notifications:** Use NotificationManager + NotificationCompat.Builder with same channel IDs.
6. **Settings:** Use DataStore Preferences instead of Hive box.
7. **Pomodoro Timer:** Use Kotlin Coroutines + Flow with countdown timer.
8. **Audio:** Use MediaPlayer or ExoPlayer for background music.
9. **Theme:** Recreate in Compose MaterialTheme with same color values.
10. **Animations:** Use Compose Animation APIs (animateContentSize, AnimatedVisibility, etc.)

### Data Migration Considerations

- Hive box names → Room table names (same strings)
- Hive TypeAdapter typeIds (0-8) → Room @Entity class names
- Attendance record ID pattern: `{courseId}_{yyyymmdd}` (keep same)
- Course schedule stored as JSON string of weekday names (keep same or normalize)
- Pomodoro sessions stored as JSON strings (migrate to proper table)
- Settings stored as single key-value pair with key `'default'` (use DataStore)

---

*Documentation generated for STUDY4U v1.2.1 Flutter app.*
