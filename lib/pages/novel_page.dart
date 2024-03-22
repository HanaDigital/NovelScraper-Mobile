import 'package:flutter/material.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';

class NovelPage extends StatefulWidget {
  final Novel novel;

  const NovelPage({super.key, required this.novel});

  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText("Novel"),
      ),
      body: Center(
        child: MediumText(widget.novel.title),
      ),
    );
  }
}
