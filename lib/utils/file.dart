import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:novelscraper/models/chapter_model.dart';
import 'package:novelscraper/models/database_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

final talker = TalkerFlutter.init();

Future<File?> writeEPUBToDownloads(String novelTitle, List<int> epub) async {
  try {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    final downloadPath = await _downloadPath;
    String filePath = join(downloadPath, "${getSafeFilename(novelTitle)}.epub");
    File file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    return await file.writeAsBytes(epub, flush: true);
  } catch (e, st) {
    talker.handle(e, st, "Failed to write to downloads");
    return null;
  }
}

Future<File?> writeStringToInternal(String filepath, String content) async {
  try {
    final path = await _localPath;
    final file = File(join(path, filepath));
    final fileExists = await file.exists();
    if (!fileExists) {
      await file.create(recursive: true);
    }
    talker.info("Writing to file: $filepath");
    return await file.writeAsString(content);
  } catch (e, st) {
    talker.handle(e, st, "Failed to write to internal storage");
    return null;
  }
}

Future<String?> readStringFromInternal(String filepath) async {
  try {
    final path = await _localPath;
    final file = File(join(path, filepath));
    talker.info("Reading from file: $filepath");
    final result = await file.readAsString();
    talker.info("Read from file: $result");
    return result;
  } catch (e, st) {
    talker.handle(e, st, "Failed to read from internal storage");
    return null;
  }
}

Future<Uint8List?> fetchImage(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  } catch (e, st) {
    talker.handle(e, st, "Failed to download image");
    return null;
  }
}

Future<File?> writeChaptersToDisk(String novelURL, List<Chapter> chapters) async {
  try {
    final path = await _localPath;
    Directory directory = Directory(join(path, "novels", getSafeFilename(novelURL)));
    await directory.create(recursive: true);
    final file = File(join(directory.path, "chapters.json"));
    final content = jsonEncode(chapters.map((chapter) => chapter.toJson()).toList());
    return await file.writeAsString(content);
  } catch (e, st) {
    talker.handle(e, st, "Failed to write to internal storage");
    return null;
  }
}

Future<List<Chapter>> readChaptersFromDisk(String novelURL) async {
  try {
    final path = await _localPath;
    final file = File(join(path, "novels", getSafeFilename(novelURL), "chapters.json"));
    final contents = await file.readAsString();
    final json = jsonDecode(contents);
    return json.map<Chapter>((chapter) => Chapter.fromJson(chapter)).toList();
  } catch (e, st) {
    talker.handle(e, st, "Failed to read from internal storage");
    return [];
  }
}

Future<File?> writeDatabaseToDisk(Database db) async {
  try {
    final file = await _databaseFile;
    return await file.writeAsString(jsonEncode(db.toJson()));
  } catch (e, st) {
    talker.handle(e, st, "Failed to write database");
    return null;
  }
}

Future<Database?> readDatabaseFromDisk() async {
  try {
    final file = await _databaseFile;
    final contents = await file.readAsString();
    final json = jsonDecode(contents);
    return Database.fromJson(json);
  } catch (e, st) {
    talker.handle(e, st, "Failed to read database");
    return null;
  }
}

Future<void> clearNovelFiles(String novelURL) async {
  try {
    final path = await _localPath;
    final directory = Directory(join(path, "novels", getSafeFilename(novelURL)));
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  } catch (e, st) {
    talker.handle(e, st, "Failed to clear chapter files");
  }
}

String getSafeFilename(String filename) {
  return filename.replaceAll(RegExp(r'[^\w\s\-]'), '');
}

Future<String> get _downloadPath async {
  Directory directory = Directory("dir");
  if (Platform.isAndroid) {
    directory = Directory("/storage/emulated/0/Download");
  } else {
    directory = await getApplicationDocumentsDirectory();
  }

  final path = directory.path;
  await Directory(path).create(recursive: true);
  return path;
}

Future<File> get _databaseFile async {
  final path = await _localPath;
  return File(join(path, "database.json"));
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
