import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class NovelFull {
  Future<List<Novel>> search(String query) async {
    final searchURI = Uri.https(Source.novelfull.url, "search", {"keyword": query});
    final response = await http.get(searchURI);
    final document = parse(response.body);

    final List<Novel> novels = [];
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
    return novels;
  }
}
