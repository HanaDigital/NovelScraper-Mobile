import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/theme.dart';

class SourcePage extends StatefulWidget {
  const SourcePage({super.key});

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: const TitleText("Source"),
      ),
      body: TextButton(
        child: const MediumText("Go back to source"),
        onPressed: () {
          // context.go("/sources");
          GoRouter.of(context).go("/sources");
        },
      ),
    );
  }
}
