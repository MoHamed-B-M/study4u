# stdy4u — Roadmap

> *Last updated: May 2026*

---

## ✅ v1.0 — Foundation *(Complete)*

- [x] Course CRUD with color coding and scheduling
- [x] Task management with urgency levels
- [x] Attendance tracking with calendar view
- [x] CGPA calculation and grade distribution charts
- [x] Pomodoro timer with focus/break rotation
- [x] Light / Dark / System theme with accent colors
- [x] Local persistence via Hive
- [x] Navigation with GoRouter (4-tab shell)

## ✅ v1.1 — Polish & Essentials *(Current)*

- [x] About screen with version and GitHub link
- [x] File upload in course materials (PDF, images, docs)
- [x] Theme selection moved to bottom sheets
- [x] Notification service initialization
- [x] Header layout fix (compact, no overlap)
- [x] Animation optimization (reduced durations, removed slideX jank)
- [x] APK version bumping for seamless updates
- [x] API 36 / AGP 8.9 upgrade
- [x] CI/CD signing config

---

## 🟡 v1.2 — Next Up

- [ ] **Screen Time Tracker** — Log app usage per package with daily/weekly charts
- [ ] **Exam Schedule** — Dedicated exam date tracker with countdown
- [ ] **Grade Calculator** — What-if scenario: "what grade do I need on the final to get an A?"
- [ ] **Drag & Drop Task Reordering** — Priority ordering within each course
- [ ] **Push Notifications** — Schedule class reminders and task deadline alerts via the notification service
- [ ] **File Preview** — In-app preview for PDFs and images instead of launching external apps
- [ ] **Widget (Home Screen)** — Android home screen widget showing today's schedule (via `home_widget`)

---

## 🟡 v1.3 — Collaboration & Sync

- [ ] **Cloud Backup** — Export/import Hive data to/from a file
- [ ] **Share Schedule** — Export course schedule as iCal/ICS file
- [ ] **Study Groups** — Join/share courses with other users (local network)
- [ ] **Attendance Export** — Export attendance records as CSV

---

## 🔵 v2.0 — Advanced Features

- [ ] **Offline-First Sync** — Optional Firebase or Supabase backend with local-first architecture
- [ ] **Smart Scheduling** — AI-powered study plan based on upcoming tasks and course load
- [ ] **Focus Analytics** — Pomodoro history charts (sessions per day, streak tracking)
- [ ] **Grade Trends** — Line chart showing grade progression over time per subject
- [ ] **Dark Mode Enhancements** — AMOLED black theme option
- [ ] **Multi-language Support** — Localization (AR, FR, ES)
- [ ] **Accessibility Pass** — Screen reader support, large text modes, high contrast

---

## 🟣 Future Ideas

- Timetable view (weekly grid)
- Assignment submission reminders (photo upload)
- University-specific course catalog import (scrape)
- Parent/guardian dashboard (read-only share link)
- Wear OS companion app
- Desktop version (Windows / Linux via Flutter)
