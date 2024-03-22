import 'package:novelscraper/models/sources/novelfull.dart';
import 'package:novelscraper/models/sources/source_model.dart';

class Novel {
  final Source source;
  final String url;
  final String title;
  List<String> authors = [];
  List<String> genres = [];
  List<String> alternateTitles = [];
  String? description;
  String? coverURL;
  String? thumbnailURL;
  String? latestChapterName;
  int? totalChapters;
  int? downloadedChapters;
  String? status;
  String? rating;
  bool isDownloaded = false;
  bool inLibrary = false;

  Novel({required this.source, required this.url, required this.title});

  Future<Novel?> fetchNovel() async {
    switch (source) {
      case Source.novelfull:
        return NovelFull.fetchNovel(this);
    }
  }

  factory Novel.fromJson(Map<String, dynamic> json) {
    final novel = Novel(
      source: Source.values.firstWhere((element) => element.name == json["source"]),
      url: json["url"],
      title: json["title"],
    );

    if (json.containsKey("authors")) {
      novel.authors = List<String>.from(json["authors"]);
    }

    if (json.containsKey("genres")) {
      novel.genres = List<String>.from(json["genres"]);
    }

    if (json.containsKey("alternateTitles")) {
      novel.alternateTitles = List<String>.from(json["alternateTitles"]);
    }

    if (json.containsKey("description")) {
      novel.description = json["description"];
    }

    if (json.containsKey("coverURL")) {
      novel.coverURL = json["coverURL"];
    }

    if (json.containsKey("thumbnailURL")) {
      novel.thumbnailURL = json["thumbnailURL"];
    }

    if (json.containsKey("latestChapterName")) {
      novel.latestChapterName = json["latestChapterName"];
    }

    if (json.containsKey("totalChapters")) {
      novel.totalChapters = json["totalChapters"];
    }

    if (json.containsKey("downloadedChapters")) {
      novel.downloadedChapters = json["downloadedChapters"];
    }

    if (json.containsKey("status")) {
      novel.status = json["status"];
    }

    if (json.containsKey("rating")) {
      novel.rating = json["rating"];
    }

    if (json.containsKey("isDownloaded")) {
      novel.isDownloaded = json["isDownloaded"];
    }

    if (json.containsKey("inLibrary")) {
      novel.inLibrary = json["inLibrary"];
    }

    return novel;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "source": source.name,
      "url": url,
      "title": title,
    };

    if (authors.isNotEmpty) {
      json["authors"] = authors;
    }

    if (genres.isNotEmpty) {
      json["genres"] = genres;
    }

    if (alternateTitles.isNotEmpty) {
      json["alternateTitles"] = alternateTitles;
    }

    if (description != null) {
      json["description"] = description;
    }

    if (coverURL != null) {
      json["coverURL"] = coverURL;
    }

    if (thumbnailURL != null) {
      json["thumbnailURL"] = thumbnailURL;
    }

    if (latestChapterName != null) {
      json["latestChapterName"] = latestChapterName;
    }

    if (totalChapters != null) {
      json["totalChapters"] = totalChapters;
    }

    if (downloadedChapters != null) {
      json["downloadedChapters"] = downloadedChapters;
    }

    if (status != null) {
      json["status"] = status;
    }

    if (rating != null) {
      json["rating"] = rating;
    }

    if (isDownloaded) {
      json["isDownloaded"] = isDownloaded;
    }

    if (inLibrary) {
      json["inLibrary"] = inLibrary;
    }

    return json;
  }
}
