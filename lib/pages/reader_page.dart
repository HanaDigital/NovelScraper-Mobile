import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/components/bottom_navbar.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/theme.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          title: const TitleText("Reader"),
          actions: [
            IconButton(
              onPressed: () {
                context.go(libraryPath);
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ],
        ),
        body: const Center(
          child: MediumText("Reader Page"),
        ));
  }
}
