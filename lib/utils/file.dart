import 'dart:io';
import 'dart:convert';
import 'package:novelscraper/models/database_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';

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

Future<void> writeToDownloads(String filename, String content) async {
  try {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) throw Exception("Permission denied");
    }
    final directory = await _downloadDirectory;
    final file = File('$directory/$filename');
    await file.writeAsString(content);
  } catch (e, st) {
    talker.handle(e, st, "Failed to write to downloads");
  }
}

Future<String?> get _downloadDirectory async {
  bool dirDownloadExists = true;
  String? directory;
  if (Platform.isIOS) {
    directory = (await getDownloadsDirectory())?.toString();
  } else if (Platform.isAndroid) {
    directory = "/storage/emulated/0/Download/";
    dirDownloadExists = await Directory(directory).exists();
    if (!dirDownloadExists) {
      directory = "/storage/emulated/0/Downloads/";
    }
  } else
    throw Exception("Platform not supported");
  return directory;
}

Future<File> get _databaseFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
