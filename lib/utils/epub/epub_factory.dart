import 'package:archive/archive_io.dart';
import 'package:novelscraper/models/chapter_model.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/utils/epub/epub_template.dart';
import 'package:novelscraper/utils/file.dart';

Future<void> generateEPUB(Novel novel, List<Chapter> chapters) async {
  final epubArchive = await EpubTemplate.getArchive(novel, chapters);
  final epubZip = ZipEncoder().encode(epubArchive);
  if (epubZip == null) return;
  writeBytesToDownloads("${novel.title}.epub", epubZip);
}
