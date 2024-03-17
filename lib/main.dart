import 'package:flutter/material.dart';
import 'package:novelscraper/components/bottom_navbar.dart';
import 'package:novelscraper/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NovelScraper',
      theme: primaryTheme,
      routerConfig: bottomNavBarRouter,
    );
  }
}
