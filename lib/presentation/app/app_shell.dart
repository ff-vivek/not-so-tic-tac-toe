import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/pages/game_home_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static final List<Widget> _tabs = <Widget>[
    const GameHomePage(),
    const _ProfilePage(),
    const _LeaderboardsPage(),
    const _StorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) async {
          setState(() => _index = i);
          if (i == 3) {
            // Store tab
            await ref.read(analyticsServiceProvider).storeVisit(source: 'tab');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Ranks',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}

class _GradientScaffold extends StatelessWidget {
  const _GradientScaffold({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F1F), Color(0xFF1A1440)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                    )),
                const SizedBox(height: 20),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return _GradientScaffold(
      title: 'Your Profile',
      subtitle: 'Customize your identity and track your streaks.',
      child: Center(
        child: Text(
          'Profile coming soon',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _LeaderboardsPage extends StatelessWidget {
  const _LeaderboardsPage();

  @override
  Widget build(BuildContext context) {
    return _GradientScaffold(
      title: 'Leaderboards',
      subtitle: 'Global rankings and weekly ladders.',
      child: Center(
        child: Text(
          'Leaderboards coming soon',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _StorePage extends StatelessWidget {
  const _StorePage();

  @override
  Widget build(BuildContext context) {
    return _GradientScaffold(
      title: 'Gridlock Store',
      subtitle: 'Skins and cosmetics to flex on the board.',
      child: Center(
        child: Text(
          'Store coming soon',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
