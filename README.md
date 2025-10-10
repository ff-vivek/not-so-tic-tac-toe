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

### Development Scripts 🚀

This project includes automated scripts for streamlined development:

**Quick Start (iOS)**:
```bash
./run_app.sh
```

**Enhanced Multi-Platform Script**:
```bash
./dev.sh ios          # Run on iOS
./dev.sh android      # Run on Android
./dev.sh setup        # First-time setup
./dev.sh clean        # Clean rebuild
```

These scripts automatically:
- Pull latest code from Git
- Install dependencies (`flutter pub get`)
- Run build_runner (if needed)
- Start iOS Simulator or Android Emulator
- Launch the app with hot reload

See [SCRIPTS.md](SCRIPTS.md) for detailed documentation.

## 📚 Documentation

- **[Product Requirements Document](docs/tech_prd_1_0.md)** - Full product specification
- **[Tasks Breakdown](docs/tasks_breakdown.md)** - Epic and user story breakdown
- **[Development Process](docs/development_process.md)** - Phased development roadmap
- **[AI Prompts Log](.ai-prompts/README.md)** - AI session logs for auditing

## 🤖 AI Development Guidelines

This project includes rules for AI coding assistants (Cursor, Windsurf, etc.):
- **[`docs/dreamflowrules.md`](docs/dreamflowrules.md)** - Comprehensive development guidelines (6 core rules)

**Key Rules for AI Assistants**:
1. Always reference `docs/development_process.md` for current phase
2. Update `development_process.md` after each task completion
3. Only implement features defined in PRD and tasks breakdown
4. Ask for clarification when uncertain
5. Focus on best UX/UI practices
6. **Log all AI prompts** in `.ai-prompts/` for auditing

### Prompt Logging 📝
All AI interactions are logged in `.ai-prompts/` folder:
- Format: `YYYY-MM-DD_HHMM_description.md`
- Includes: Full prompt, summary, token usage, files modified
- Purpose: Auditing, cost tracking, knowledge sharing
- See [`.ai-prompts/TEMPLATE.md`](.ai-prompts/TEMPLATE.md) for format

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
