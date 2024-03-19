import 'package:novelscraper/models/source_model.dart';

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
}
