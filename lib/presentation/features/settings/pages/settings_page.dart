import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/settings/controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface.withValues(alpha: 0.0),
              colors.primaryContainer.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 6),
                Text('Tune your experience.', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    )),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _Section(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        children: [
                          _SegmentedSetting<ThemeMode>(
                            label: 'Theme',
                            value: settings.themeMode,
                            segments: const [
                              ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                              ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                              ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                            ],
                            onChanged: (m) => ref.read(settingsControllerProvider.notifier).setThemeMode(m),
                          ),
                          _SwitchTile(
                            icon: Icons.motion_photos_on_outlined,
                            title: 'Reduced motion',
                            subtitle: 'Minimize animations where possible',
                            value: settings.reducedMotion,
                            onChanged: (_) => ref.read(settingsControllerProvider.notifier).toggleReducedMotion(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        icon: Icons.surround_sound_outlined,
                        title: 'Audio & Haptics',
                        children: [
                          _SwitchTile(
                            icon: Icons.music_note_outlined,
                            title: 'Music',
                            subtitle: 'Background music in menus',
                            value: settings.musicEnabled,
                            onChanged: (_) => ref.read(settingsControllerProvider.notifier).toggleMusic(),
                          ),
                          _SwitchTile(
                            icon: Icons.graphic_eq_outlined,
                            title: 'Sound effects',
                            subtitle: 'Clicks, wins, and highlights',
                            value: settings.soundEnabled,
                            onChanged: (_) => ref.read(settingsControllerProvider.notifier).toggleSound(),
                          ),
                          _SwitchTile(
                            icon: Icons.vibration_outlined,
                            title: 'Haptics',
                            subtitle: 'Subtle vibrations on interactions',
                            value: settings.hapticsEnabled,
                            onChanged: (_) => ref.read(settingsControllerProvider.notifier).toggleHaptics(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        icon: Icons.info_outline,
                        title: 'About',
                        children: const [
                          ListTile(
                            leading: Icon(Icons.verified_outlined),
                            title: Text('Version'),
                            subtitle: Text('1.0.0'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => ref.read(settingsControllerProvider.notifier).resetDefaults(),
                          icon: const Icon(Icons.restore)
                              ,
                          label: const Text('Reset to defaults'),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children});
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colors.secondary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _SegmentedSetting<T> extends StatelessWidget {
  const _SegmentedSetting({
    required this.label,
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<ButtonSegment<T>> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SegmentedButton<T>(
            segments: segments,
            selected: {value},
            showSelectedIcon: false,
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ),
      ],
    );
  }
}
