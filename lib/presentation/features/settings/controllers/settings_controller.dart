import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
    required this.reducedMotion,
  });

  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState(
        themeMode: ThemeMode.system,
        soundEnabled: true,
        musicEnabled: false,
        hapticsEnabled: true,
        reducedMotion: false,
      );

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);
  void toggleSound() => state = state.copyWith(soundEnabled: !state.soundEnabled);
  void toggleMusic() => state = state.copyWith(musicEnabled: !state.musicEnabled);
  void toggleHaptics() => state = state.copyWith(hapticsEnabled: !state.hapticsEnabled);
  void toggleReducedMotion() => state = state.copyWith(reducedMotion: !state.reducedMotion);

  void resetDefaults() => state = const SettingsState(
        themeMode: ThemeMode.system,
        soundEnabled: true,
        musicEnabled: false,
        hapticsEnabled: true,
        reducedMotion: false,
      );
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
