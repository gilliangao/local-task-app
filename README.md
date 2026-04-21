# Local Task App

A Flutter application for managing daily tasks and routines with persistent storage and localization support.

## Features

- **Task Organization**: Organize tasks into four sections:
  - Today: Daily tasks and immediate priorities
  - Short Term: Tasks for the coming weeks
  - Long Term: Future goals and projects
  - Completed: Finished tasks for reference

- **Task Management**:
  - Add new tasks with section assignment
  - Edit existing tasks (title, section, completion status)
  - Delete individual tasks or clear all completed tasks
  - Mark tasks as complete/incomplete

- **Task Reordering**: Move tasks up/down within their sections for priority management

- **Task Movement**: Move tasks between different sections as priorities change

- **Persistent Storage**: Tasks are automatically saved locally using SharedPreferences

- **Localization**: Support for English and Chinese languages

- **Modern UI**: Built with Flutter and Material 3 design system

## Getting Started

### Prerequisites

- Flutter SDK (^3.11.5)
- Dart SDK (^3.11.5)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/gilliangao/local-task-app.git
   cd local-task-app/app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Supported Platforms

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Project Structure

```
app/
├── lib/
│   ├── main.dart          # Main application code
│   └── l10n/              # Localization files
├── android/               # Android platform code
├── ios/                   # iOS platform code
├── web/                   # Web platform code
├── windows/               # Windows platform code
├── macos/                 # macOS platform code
├── linux/                 # Linux platform code
└── pubspec.yaml           # Flutter dependencies and configuration
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is private and not licensed for public use.
