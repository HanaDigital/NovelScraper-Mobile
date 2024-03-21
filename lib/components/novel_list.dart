import 'package:flutter/material.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';

class NovelList extends StatefulWidget {
  final List<Novel> novels;

  const NovelList({super.key, required this.novels});

  @override
  State<NovelList> createState() => _NovelListState();
}

class _NovelListState extends State<NovelList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.novels.length,
        itemBuilder: (context, index) {
          final novel = widget.novels[index];
          return ListTile(
            leading: novel.thumbnailURL != null ? Image.network(novel.thumbnailURL!) : null,
            title: SpanTitleText(novel.title),
            subtitle: SmallText(novel.authors.join(", ")),
            onTap: () {
              // context.go("/reader", extra: novel);
            },
          );
        },
      ),
    );
  }
}
