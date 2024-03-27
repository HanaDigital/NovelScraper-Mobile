import 'package:novelscraper/models/novel_model.dart';

class Database {
  int lastId;
  final Map<String, Novel> novels;

  Database({
    required this.novels,
    this.lastId = 0,
  });

  static Database emptyDB = Database(
    novels: {},
    lastId: 0,
  );

  factory Database.fromJson(Map<String, dynamic> json) {
    int lastId = json['lastId'] ?? 0;

    final Map<String, Novel> novels = {};
    json.forEach((key, value) {
      final novel = Novel.fromJson(value);
      if (novel.id == null) {
        novel.id = lastId;
        lastId++;
      }
      novels[key] = novel;
    });

    return Database(
      novels: novels,
      lastId: lastId,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    novels.forEach((key, value) {
      json[key] = value.toJson();
    });
    json['lastId'] = lastId;
    return json;
  }
}
