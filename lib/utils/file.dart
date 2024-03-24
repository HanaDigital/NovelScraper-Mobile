import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:novelscraper/models/database_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

final talker = TalkerFlutter.init();

Future<File?> writeDatabase(Database db) async {
  try {
    final file = await _databaseFile;
    return file.writeAsString(jsonEncode(db.toJson()));
  } catch (e, st) {
    talker.handle(e, st, "Failed to write database");
    return null;
  }
}

Future<Database?> readDatabase() async {
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

Future<File?> writeBytesToDownloads(String filename, List<int> content) async {
  try {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    final downloadPath = await _downloadPath;
    String filePath = join(downloadPath, filename);
    File file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    return await file.writeAsBytes(content, flush: true);
  } catch (e, st) {
    talker.handle(e, st, "Failed to write to downloads");
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
  return File('$path/counter.txt');
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
