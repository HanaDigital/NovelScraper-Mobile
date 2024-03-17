import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/pages/home.dart';
import 'package:novelscraper/pages/library.dart';
import 'package:novelscraper/pages/source.dart';
import 'package:novelscraper/pages/sources.dart';

enum BottomNavPagesEnum {
  home,
  sources,
  library,
}

const homePath = '/';
const sourcesPath = '/sources';
const libraryPath = '/library';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
GoRouter bottomNavBarRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: homePath,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: homePath,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: sourcesPath,
          builder: (context, state) => const SourcesPage(),
          routes: [
            GoRoute(
              path: 'source',
              builder: (context, state) => const SourcePage(),
            ),
          ],
        ),
        GoRoute(
          path: libraryPath,
          builder: (context, state) => const LibraryPage(),
        ),
      ],
    )
  ],
);

class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    switch (BottomNavPagesEnum.values[index]) {
      case BottomNavPagesEnum.home:
        GoRouter.of(context).go(homePath);
        break;
      case BottomNavPagesEnum.sources:
        GoRouter.of(context).go(sourcesPath);
        break;
      case BottomNavPagesEnum.library:
        GoRouter.of(context).go(libraryPath);
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.public),
            icon: Icon(Icons.public),
            label: 'Sources',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_outline),
            label: 'Library',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }
}
