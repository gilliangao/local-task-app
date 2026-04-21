# Local Task App – Project Notes

## 🧠 Project Overview
A local-first task management app built with Flutter.

Core concept:
Long Term → Short Term → Today → Done

---

## ✅ What has been implemented

### 1. App Structure
- Flutter app created
- Bottom navigation with 4 tabs:
  - Today
  - Short Term
  - Long Term
  - Completed

---

### 2. Task System
- Create task via dialog with section assignment
- Edit existing tasks (title, section, completion status)
- Delete individual tasks
- Assign sections:
  - Today
  - Short Term
  - Long Term
- Display tasks in organized lists

---

### 3. Task Interaction
- Checkbox to mark task as completed/incomplete
- UI updates:
  - Line-through text
  - Grey color for completed tasks
  - Status text (Active / Completed)
- Visual feedback for task states

---

### 4. Task Movement
- Move tasks between sections via popup menu (⋮)
- Dynamic section reassignment
- Maintains task order during moves

---

### 5. Task Ordering (Priority Management)
- Move up (↑) and down (↓) within sections
- Per-section sorting and reordering
- Priority management within categories

---

### 6. Local Storage (Persistence)
- Using shared_preferences for data persistence
- Tasks automatically saved on changes
- Data loaded on app startup
- Survives app restarts and device reboots

---

### 7. Advanced Features
- Clear all completed tasks functionality
- Confirmation dialogs for destructive actions
- Loading states during data operations
- Error handling for storage operations

---

### 8. Localization (i18n)
- Support for English and Chinese languages
- Dynamic language switching
- Localized UI strings throughout the app
- Proper RTL/LTR support

---

### 9. UI/UX Enhancements
- Material 3 design system
- Responsive layout
- Intuitive navigation
- Accessibility considerations
- Modern Flutter widgets and patterns

---

## 🧱 Current Architecture

### Data Model
```dart
class TaskItem {
  String title;
  bool isDone;
  TaskSection section;

  TaskItem({required this.title, required this.section, this.isDone = false});

  // JSON serialization methods
  Map<String, dynamic> toMap()
  factory TaskItem.fromMap(Map<String, dynamic> map)
}
```

### State Management
- StatefulWidget with local state management
- Async operations for data persistence
- Optimistic UI updates with error handling

### Storage Layer
- SharedPreferences for local persistence
- JSON encoding/decoding for complex objects
- Automatic save on state changes

### UI Architecture
- BottomNavigationBar for section switching
- ListView.builder for efficient task rendering
- Dialog-based forms for task creation/editing
- PopupMenuButton for contextual actions

---

## 🎯 Future Enhancements

### Potential Features
- Task categories/tags
- Due dates and reminders
- Task search and filtering
- Data export/import
- Cloud synchronization
- Task templates
- Statistics and analytics
- Dark/light theme toggle
- Custom section creation

### Technical Improvements
- State management solution (Provider/Bloc)
- Database integration (SQLite/Isar)
- Unit and integration tests
- CI/CD pipeline
- Performance optimizations
- Offline-first architecture

---

## 📚 Resources & Dependencies

### Core Dependencies
- flutter: Flutter SDK
- shared_preferences: Local data persistence
- flutter_localizations: Internationalization support

### Development Tools
- flutter_lints: Code quality
- flutter_test: Testing framework

### Localization
- ARB files for translations
- flutter gen-l10n for code generation
