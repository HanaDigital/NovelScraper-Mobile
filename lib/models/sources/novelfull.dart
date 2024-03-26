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

    // PORT LISTENER TO CANCEL DOWNLOAD IF REQUESTED
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

      final response = await http.get(Uri.parse(novel.url));
      Document document = parse(response.body);

      final lastPageURL = document.querySelector("#list-chapter ul.pagination > li.last")?.querySelector("a")?.attributes["href"];
      final totalPages = lastPageURL != null ? int.tryParse(lastPageURL.split("=").last) ?? 1 : 1;

      const batch = 10; // BATCH OF CHAPTERS TO DOWNLOAD AT ONCE
      List<Chapter> chapters = [];
      for (var i = 1; i <= totalPages; i++) {
        // GET ALL CHAPTERS ON PAGE
        List<Chapter> pageChapters = [];
        document.querySelectorAll("#list-chapter .row ul.list-chapter > li").forEach((chapterEl) {
          final chapterLinkEl = chapterEl.querySelector("a");
          final title = chapterLinkEl?.text.trim();
          final url = chapterLinkEl?.attributes["href"];
          if (title == null && url == null) throw Exception("Chapter title or url not found");
          pageChapters.add(Chapter(title: title!, url: Uri.https(Source.novelfull.url, url!).toString()));
        });
        talker.info("[NovelFull] Downloading chapters: ${chapters.length + 1} to ${chapters.length + pageChapters.length}");

        int skip = 0;
        while (skip < pageChapters.length) {
          // CHECK IF DOWNLOAD IS CANCELED
          if (cancel) throw Exception("Download canceled");

          // CREATE BATCH OF CHAPTERS TO DOWNLOAD
          final batchChapters = pageChapters.skip(skip).take(batch).toList();

          final List<Future<Chapter>> downloadedChapters = [];
          for (int i = 0; i < batchChapters.length; i++) {
            // CHECK IF CHAPTER IS ALREADY DOWNLOADED
            final chapter = batchChapters[i];
            final chaptersIndex = chapters.length + i;
            if (preDownloadedChapters.length > chaptersIndex) {
              final downloadedChapter = preDownloadedChapters[chaptersIndex];
              if (downloadedChapter.content != null &&
                  downloadedChapter.title == chapter.title &&
                  downloadedChapter.url == chapter.url) {
                chapter.content = downloadedChapter.content;
                downloadedChapters.add(Future.value(chapter));
                continue;
              }
            }

            // DOWNLOAD CHAPTER CONTENT IF NOT ALREADY DOWNLOADED
            downloadedChapters.add(_getChapterContent(chapter));
          }

          // WAIT FOR BATCH TO COMPLETE DOWNLOADING
          chapters = [...chapters, ...(await Future.wait(downloadedChapters))];
          novel.downloadedChapters = chapters.length;
          skip += batch;

          // SEND DOWNLOAD PERCENTAGE TO UI
          final percentage = num.parse((((chapters.length) / (novel.totalChapters ?? 0)) * 100).toStringAsFixed(2));
          sPort.send([NovelIsolateAction.setPercentage, percentage]);
        }

        // GET NEXT PAGE IF AVAILABLE
        if (i + 1 > totalPages) break;
        final nextPageURI = Uri.parse("${novel.url}?page=${i + 1}");
        final response = await http.get(nextPageURI);
        document = parse(response.body);
      }
      novel.isDownloaded = true;
      novel.totalChapters = chapters.length;
      talker.info("[NovelFull] Downloaded ${novel.totalChapters} chapters");

      // REQUEST TO GENERATE EPUB
      sPort.send([NovelIsolateAction.generateEPUB, novel, chapters]);
    } catch (e, st) {
      talker.handle(e, st, "[NovelFull] Failed to download novel");
    }

    rPort.close();
    sPort.send([NovelIsolateAction.done, novel]);
  }

  static Future<Chapter> _getChapterContent(Chapter chapter) async {
    final response = await http.get(Uri.parse(chapter.url));
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

    final titleHTML = "<h1>${chapter.title}</h1>";
    final propagandaHTML = Chapter.getPropagandaHTML();

    content = "$titleHTML\n$content\n$propagandaHTML";
    chapter.content = content;
    return chapter;
  }
}
