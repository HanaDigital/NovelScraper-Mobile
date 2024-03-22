import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/theme.dart';

class NovelList extends StatefulWidget {
  final List<Novel> novels;
  final String pathPrefix;

  const NovelList({super.key, required this.novels, required this.pathPrefix});

  @override
  State<NovelList> createState() => _NovelListState();
}

class _NovelListState extends State<NovelList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: widget.novels.length,
            itemBuilder: (context, index) {
              final novel = widget.novels[index];
              return ListTile(
                tileColor: AppColors.secondaryColor.withOpacity(0.7),
                leading: novel.thumbnailURL != null ? Image.network(novel.thumbnailURL!) : null,
                title: SpanMediumText(novel.title, maxLines: 2),
                subtitle: SpanSmallText(novel.authors.join(", ")),
                onTap: () {
                  context.go("${widget.pathPrefix}/novel", extra: novel);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
