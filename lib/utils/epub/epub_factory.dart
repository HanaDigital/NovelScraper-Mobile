import 'package:archive/archive_io.dart';
import 'package:novelscraper/models/chapter_model.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/utils/epub/epub_template.dart';

Future<List<int>?> generateEPUB(Novel novel, List<Chapter> chapters) async {
  final epubArchive = await EpubTemplate.getArchive(novel, chapters);
  final epubZip = ZipEncoder().encode(epubArchive);
  return epubZip;
}
