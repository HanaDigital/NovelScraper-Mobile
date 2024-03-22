import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:novelscraper/pages/home_page.dart';
import 'package:novelscraper/pages/library_page.dart';
import 'package:novelscraper/pages/novel_page.dart';
import 'package:novelscraper/pages/reader_page.dart';
import 'package:novelscraper/pages/sources/source_page.dart';
import 'package:novelscraper/pages/sources/sources_page.dart';

enum BottomNavPagesEnum {
  home,
  sources,
  library,
}

const homePath = '/';
const sourcesPath = '/sources';
const libraryPath = '/library';
const readerPath = '/reader';

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
                path: 'source/:sourceName',
                builder: (context, state) {
                  final sourceName = state.pathParameters['sourceName']!;
                  return SourcePage(sourceName: sourceName);
                },
                routes: [
                  GoRoute(
                    path: 'novel',
                    builder: (context, state) {
                      final Novel novel = state.extra! as Novel;
                      return NovelPage(novel: novel);
                    },
                  ),
                ]),
          ],
        ),
        GoRoute(
          path: libraryPath,
          builder: (context, state) => const LibraryPage(),
        ),
      ],
    ),
    GoRoute(
      path: readerPath,
      builder: (context, state) => const ReaderPage(),
    ),
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
