import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/source_model.dart';

class Database {
  final Map<String, Source> sources;
  final Map<String, Novel> novels;

  const Database({
    required this.sources,
    required this.novels,
  });

  static Database db = Database(
    sources: Source.values.asMap().map((_, source) => MapEntry(source.name, source)),
    novels: {},
  );
}
