import 'package:flutter/material.dart';
import 'package:novelscraper/components/bottom_navbar.dart';
import 'package:novelscraper/stores/database_store.dart';
import 'package:novelscraper/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatabaseStore(),
      child: MaterialApp.router(
        title: 'NovelScraper',
        theme: primaryTheme,
        routerConfig: bottomNavBarRouter,
      ),
    );
  }
}
