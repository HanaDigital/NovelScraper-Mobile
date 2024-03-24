import 'dart:isolate';

import 'package:html/dom.dart';
import 'package:novelscraper/models/chapter_model.dart';
import 'package:novelscraper/models/novel_isolate.dart';
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
        novel.thumbnailURL = thumbnailURL != null ? Uri.https(Source.novelfull.url, thumbnailURL).toString() : null;
        novels.add(novel);
      });
    } catch (e, st) {
      talker.handle(e, st, "[NovelFull] Failed to search for novels");
    }
    return novels;
  }

  static Future<Novel?> fetchNovel(Novel novel) async {
    try {
      final novelURI = Uri.parse(novel.url);
      final response = await http.get(novelURI);
      final document = parse(response.body);

      // GET NOVEL INFO
      final novelInfoEl = document.querySelector(".col-info-desc");
      final title = novelInfoEl?.querySelector(".desc > h3.title")?.text.trim();
      final rating = novelInfoEl
          ?.querySelector(".small")
          ?.text
          .trim()
          .replaceFirst("Rating: ", "")
          .replaceFirst(RegExp(r"from[\S\s]*?(?=\d)"), "from ");
      final description = novelInfoEl?.querySelector(".desc-text")?.text.trim();
      final latestChapter = novelInfoEl?.querySelector(".l-chapter > ul.l-chapters > li")?.text.trim();
      final coverURL = novelInfoEl?.querySelector(".info-holder .book img")?.attributes["src"];

      final infoHolderEls = novelInfoEl?.querySelectorAll(".info-holder > .info > div");
      final authors = infoHolderEls?[0].querySelectorAll("a").map((el) => el.text.trim()).toList();
      final alternateTitles = infoHolderEls?[1].text.replaceFirst("Alternative names:", "").trim().split(", ");
      final genres = infoHolderEls?[2].querySelectorAll("a").map((el) => el.text.trim()).toList();
      final status = infoHolderEls?[4].querySelector("a")?.text.trim();

      // GET CHAPTERS PER PAGE
      final chaptersEl = document.querySelector("#list-chapter");
      var chaptersPerPage = 0;
      chaptersEl?.querySelectorAll("ul.list-chapter").forEach((el) {
        chaptersPerPage += el.querySelectorAll("li").length;
      });

      // GET TOTAL CHAPTERS
      var totalPages = 1;
      var totalChapters = 0;
      final lastPageURL = chaptersEl?.querySelector("ul.pagination > li.last")?.querySelector("a")?.attributes["href"];
      if (lastPageURL != null) {
        totalPages = int.tryParse(lastPageURL.split("=").last) ?? 1;
        totalChapters = chaptersPerPage * (totalPages - 1);

        try {
          final lastPageUri = Uri.parse("${novel.url}?page=$totalPages");
          final lastPageRes = await http.get(lastPageUri);
          final lastPageDocument = parse(lastPageRes.body);
          lastPageDocument.querySelectorAll("#list-chapter ul.list-chapter").forEach((el) {
            totalChapters += el.querySelectorAll("li").length;
          });
        } catch (e, st) {
          talker.warning("[NovelFull] Error while getting total chapters", e, st);
        }
      } else {
        totalChapters = chaptersPerPage;
      }

      // UPDATE NOVEL
      novel.title = title ?? novel.title;
      novel.authors = authors ?? novel.authors;
      novel.genres = genres ?? novel.genres;
      novel.alternateTitles = alternateTitles ?? novel.alternateTitles;
      novel.description = description ?? novel.description ?? "No description available.";

      novel.coverURL = coverURL != null ? Uri.https(Source.novelfull.url, coverURL).toString() : null;
      novel.rating = rating ?? novel.rating ?? "No rating available.";
      novel.latestChapterName = latestChapter ?? novel.latestChapterName;
      novel.totalChapters = totalChapters > 0 ? totalChapters : novel.totalChapters;
      novel.status = status ?? novel.status ?? "Unknown";
      return novel;
    } catch (e, st) {
      talker.handle(e, st, "[NovelFull] Failed to fetch novel");
    }
    return null;
  }

  static Future<void> downloadNovel(Map<String, Object> params) async {
    final sPort = params['sPort'] as SendPort;
    final novel = params['novel'] as Novel;
    final preDownloadedChapters = params['preDownloadedChapters'] as List<Chapter>;

    ReceivePort rPort = ReceivePort();
    sPort.send([NovelIsolateAction.setSendPort, rPort.sendPort]);

    bool cancel = false;
    rPort.listen((message) {
      if (message is List && message.isNotEmpty && message[0] is NovelIsolateAction) {
        switch (message[0]) {
          case NovelIsolateAction.cancel:
            talker.info("[NovelFull] Canceling download");
            cancel = true;
            break;
        }
      }
    });

    try {
      talker.info("[NovelFull] Downloading novel: ${novel.title}");
      final novelURI = Uri.parse(novel.url);
      final response = await http.get(novelURI);
      final document = parse(response.body);

      final chapterLinks = await _getAllChapterLinks(novel.url, document);
      novel.totalChapters = chapterLinks.length;
      talker.info("[NovelFull] Found ${chapterLinks.length} chapters");

      final List<Chapter> downloadedChapters = [];
      for (int i = 0; i < chapterLinks.length; i++) {
        if (cancel) throw Exception("Download canceled");
        talker.info("[NovelFull] Downloading chapter: ${i + 1}:${chapterLinks[i].title}");
        final percentage = num.parse((((i + 1) / chapterLinks.length) * 100).toStringAsFixed(2));
        sPort.send([NovelIsolateAction.setPercentage, percentage]);
        final chapter = chapterLinks[i];

        // CHECK IF CHAPTER IS ALREADY DOWNLOADED
        if (preDownloadedChapters.isNotEmpty && preDownloadedChapters.length > i) {
          final downloadedChapter = preDownloadedChapters[i];
          if (downloadedChapter.content != null &&
              downloadedChapter.title == chapter.title &&
              downloadedChapter.url == chapter.url) {
            talker.info("[NovelFull] Chapter already downloaded");
            chapter.content = downloadedChapter.content;
            downloadedChapters.add(chapter);
            novel.downloadedChapters = downloadedChapters.length;
            continue;
          }
        }

        // DOWNLOAD CHAPTER CONTENT
        talker.info("[NovelFull] Downloading chapter content");
        final content = await _getChapterContent(chapter.title, chapter.url);
        if (content == null) throw Exception("Failed to download chapter: ${chapter.title}:${chapter.url}");
        chapter.content = content;
        downloadedChapters.add(chapter);
        novel.downloadedChapters = downloadedChapters.length;
        sPort.send([NovelIsolateAction.saveDownloadedChapters, downloadedChapters]);
      }
      talker.info("[NovelFull] Downloaded ${downloadedChapters.length} chapters");

      novel.downloadedChapters = downloadedChapters.length;
      novel.isDownloaded = true;

      sPort.send([NovelIsolateAction.generateEPUB, novel, downloadedChapters]);
    } catch (e, st) {
      talker.handle(e, st, "[NovelFull] Failed to download novel");
    }

    rPort.close();
    sPort.send([NovelIsolateAction.done, novel]);
  }

  static Future<List<Chapter>> _getAllChapterLinks(String novelURL, Document document) async {
    final List<Chapter> chapters = [];

    final lastPageURL = document.querySelector("#list-chapter ul.pagination > li.last")?.querySelector("a")?.attributes["href"];
    final totalPages = lastPageURL != null ? int.tryParse(lastPageURL.split("=").last) ?? 1 : 1;

    for (var i = 1; i <= totalPages; i++) {
      document.querySelectorAll("#list-chapter .row ul.list-chapter > li").forEach((chapterEl) {
        final chapterLinkEl = chapterEl.querySelector("a");
        final title = chapterLinkEl?.text.trim();
        final url = chapterLinkEl?.attributes["href"];
        if (title != null && url != null) {
          chapters.add(Chapter(title: title, url: Uri.https(Source.novelfull.url, url).toString()));
        }
      });

      if (i + 1 > totalPages) break;
      final nextPageURI = Uri.parse("$novelURL?page=${i + 1}");
      final response = await http.get(nextPageURI);
      document = parse(response.body);
    }

    return chapters;
  }

  static Future<String?> _getChapterContent(String title, String chapterURL) async {
    try {
      final response = await http.get(Uri.parse(chapterURL));
      final document = parse(response.body);

      final contentEl = document.querySelector("#chapter-content");
      if (contentEl == null) throw Exception("Chapter content not found");
      contentEl.querySelectorAll("script").forEach((el) => el.remove());
      contentEl.querySelectorAll("iframe").forEach((el) => el.remove());

      String content = contentEl.innerHtml;
      content = content
          .replaceAll(RegExp(r'class=".*?"'), "")
          .replaceAll(RegExp(r'id=".*?"'), "")
          .replaceAll(RegExp(r'style=".*?"'), "")
          .replaceAll(RegExp(r'data-.*?=".*?"'), "")
          .replaceAll(RegExp(r'<!--.*?-->'), "")
          .replaceAll(
              RegExp(
                  r'<div align="left"[\s\S]*?If you find any errors \( Ads popup, ads redirect, broken links, non-standard content, etc.. \)[\s\S]*?<\/div>'),
              "");

      final titleHTML = "<h1>$title</h1>";
      final propagandaHTML = Chapter.getPropagandaHTML();

      return "$titleHTML\n$content\n$propagandaHTML";
    } catch (e, st) {
      talker.handle(e, st, "[NovelFull] Failed to get chapter content");
      return null;
    }
  }
}
