import 'package:novelscraper/models/chapter_model.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/novelfull.dart';

enum Source {
  novelfull(
    name: "NovelFull",
    url: "novelfull.com",
    logoSrc: "novelfull-logo.png",
    search: NovelFull.search,
    fetchNovel: NovelFull.fetchNovel,
    downloadNovel: NovelFull.downloadNovel,
  );

  final String name;
  final String url;
  final String logoSrc;
  final Future<List<Novel>> Function(String query) search;
  final Future<Novel?> Function(Novel novel) fetchNovel;
  final Future<void> Function(Novel novel, List<Chapter> preDownloadedChapters) downloadNovel;

  const Source({
    required this.name,
    required this.url,
    required this.logoSrc,
    required this.search,
    required this.fetchNovel,
    required this.downloadNovel,
  });
}
