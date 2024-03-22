import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/theme.dart';

class NovelList extends StatelessWidget {
  final List<Novel> novels;
  final String pathPrefix;

  const NovelList({super.key, required this.novels, required this.pathPrefix});

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                tileColor: AppColors.secondaryColor.withOpacity(0.7),
                leading: novel.thumbnailURL != null ? Image.network(novel.thumbnailURL!) : null,
                title: SpanMediumText(novel.title, maxLines: 2),
                subtitle: SpanSmallText(novel.authors.join(", ")),
                onTap: () {
                  context.go("$pathPrefix/novel", extra: novel);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
