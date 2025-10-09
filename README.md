# Gridlock: X & O Evolved 🎮

A mobile-first, multiplayer Tic-Tac-Toe game with dynamic rule modifiers, built with Flutter.

## 📖 Project Overview

Gridlock reimagines classic Tic-Tac-Toe for the modern, social media-driven era. By introducing dynamic rule modifiers, strategic depth, and built-in viral mechanics, it transforms a universally known game into an endlessly replayable, highly shareable, and competitive experience.

**Key Features**:
- Real-time multiplayer matchmaking
- 5 unique game modifiers (Blocked Squares, Spinner, Gravity Well, Volatile Squares, Ultimate Mode)
- Win streak system with social sharing
- Cosmetic customization and in-app store
- Leaderboards and progression systems

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- iOS Simulator / Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd not-so-tic-tac-toe
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/path/to/test_file.dart
```

## 📚 Documentation

- **[Product Requirements Document](docs/tech_prd_1_0.md)** - Full product specification
- **[Tasks Breakdown](docs/tasks_breakdown.md)** - Epic and user story breakdown
- **[Development Process](docs/development_process.md)** - Phased development roadmap

## 🤖 AI Development Guidelines

This project includes rules for AI coding assistants (Cursor, Windsurf, etc.):
- **`.cursorrules`** - Comprehensive development guidelines
- **`.windsurfrules`** - Windsurf-specific rules reference
- **`.aidigestorrules`** - AI Digestor rules reference

**Key Rules for AI Assistants**:
1. Always reference `docs/development_process.md` for current phase
2. Update `development_process.md` after each task completion
3. Only implement features defined in PRD and tasks breakdown
4. Ask for clarification when uncertain
5. Focus on best UX/UI practices

## 🏗️ Architecture

This project follows Clean Architecture principles:

```
lib/
├── core/              # Shared utilities, constants, themes
├── data/              # Data sources, repositories implementation
├── domain/            # Business logic, entities, use cases
├── presentation/      # UI, state management, widgets
└── main.dart
```

## 🎯 Current Status

**Phase**: Foundation & Setup (Phase 0)

See [Development Process](docs/development_process.md) for detailed progress tracking.

## 🤝 Contributing

1. Check current phase in `docs/development_process.md`
2. Pick an uncompleted task from the current phase
3. Create a feature branch: `feature/epic-X-description`
4. Implement with tests
5. Update `development_process.md` checkboxes
6. Submit PR for review

## 📝 License

[Add your license here]

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design 3](https://m3.material.io/)
