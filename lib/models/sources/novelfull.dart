import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init();

class NovelFull {
  static Future<List<Novel>> search(String query) async {
    final List<Novel> novels = [];
    try {
      final searchURI = Uri.https(Source.novelfull.url, "search", {"keyword": query});
      final response = await http.get(searchURI);
      final document = parse(response.body);

      document.querySelectorAll("#list-page .col-truyen-main .row").forEach((novelEl) {
        final titleEl = novelEl.querySelector("h3.truyen-title a");
        if (titleEl == null) return;
        final novelURL = titleEl.attributes["href"];
        final title = titleEl.text.trim();
        if (novelURL == null || title.isEmpty) return;
        final novelURI = Uri.https(Source.novelfull.url, novelURL);

        final author = novelEl.querySelector(".author")?.text.trim() ?? "Unknown";
        final thumbnailURL = novelEl.querySelector("img")?.attributes["src"];

        final novel = Novel(source: Source.novelfull, title: title, url: novelURI.toString());
        novel.authors.add(author);
        if (thumbnailURL != null) novel.thumbnailURL = Uri.https(Source.novelfull.url, thumbnailURL).toString();
        novels.add(novel);
      });
    } catch (e, st) {
      talker.handle(e, st, "[NovelFull] Failed to search for novels");
    }
    return novels;
  }

  static Future<Novel?> fetchNovel(Novel novel) async {
    return null;
  }
}
