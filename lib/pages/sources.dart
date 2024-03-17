import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/theme.dart';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: const TitleText("Sources"),
      ),
      body: Column(
        children: [
          TextButton(
            child: const MediumText("Go back Home"),
            onPressed: () {
              // context.go("/source");
              GoRouter.of(context).go("/");
            },
          ),
          TextButton(
            child: const MediumText("Open Source"),
            onPressed: () {
              // context.go("/source");
              GoRouter.of(context).go("/sources/source");
            },
          ),
        ],
      ),
    );
  }
}
