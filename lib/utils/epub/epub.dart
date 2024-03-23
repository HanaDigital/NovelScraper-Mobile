import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:novelscraper/utils/file.dart';

void generateEPUB() {
  final archive = Archive();
  final archiveFile = ArchiveFile("test.txt", 4, "Hello World");
  archive.addFile(archiveFile);
  final zipFile = ZipEncoder().encode(archive);
  if (zipFile == null) return;
  writeToDownloads("test.zip", base64Encode(zipFile));
}
