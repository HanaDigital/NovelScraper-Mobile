import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/components/bottom_navbar.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/theme.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          title: const TitleText("Library"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MediumText("Library Page"),
              ElevatedButton(
                onPressed: () {
                  context.go(readerPath);
                },
                child: const SmallText("Open Reader"),
              ),
            ],
          ),
        ));
  }
}
