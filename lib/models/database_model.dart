import 'package:novelscraper/models/novel_model.dart';

class Database {
  final Map<String, Novel> novels;

  Database({
    required this.novels,
  });

  static Database emptyDB = Database(
    novels: {},
  );

  factory Database.fromJson(Map<String, dynamic> json) {
    final Map<String, Novel> novels = {};
    json.forEach((key, value) {
      novels[key] = Novel.fromJson(value);
    });
    return Database(
      novels: novels,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    novels.forEach((key, value) {
      json[key] = value.toJson();
    });
    return json;
  }
}
