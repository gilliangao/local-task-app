# Local Task App – Project Notes

## 🧠 Project Overview
A local-first task management app built with Flutter.

Core concept:
Long Term → Short Term → Today → Done

---

## ✅ What has been implemented

### 1. App Structure
- Flutter app created
- Bottom navigation:
  - Today
  - Short Term
  - Long Term

---

### 2. Task System
- Create task via dialog
- Assign section:
  - Today
  - Short Term
  - Long Term
- Display tasks in lists

---

### 3. Task Interaction
- Checkbox to mark task as completed
- UI updates:
  - Line-through
  - Grey color
  - Status text (Active / Completed)

---

### 4. Task Movement
- Move tasks between sections
- Implemented via popup menu (⋮)

---

### 5. Task Ordering (Important)
- Move up (↑)
- Move down (↓)
- Sorting is per section

---

### 6. Local Storage (Important milestone)
- Using shared_preferences
- Tasks are:
  - Saved automatically
  - Loaded on app start
- Data persists after refresh

---

## 🧱 Current Architecture

### Data Model
```dart
class TaskItem {
  String title;
  bool isDone;
  TaskSection section;
}