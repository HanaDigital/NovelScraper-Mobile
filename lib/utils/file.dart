import 'dart:io';
import 'dart:convert';

import 'package:novelscraper/models/database_model.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _databaseFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}

Future<File> writeDatabase(Database db) async {
  final file = await _databaseFile;
  return file.writeAsString(jsonEncode(db.toJson()));
}

Future<Database?> readDatabase() async {
  try {
    final file = await _databaseFile;
    final contents = await file.readAsString();
    final json = jsonDecode(contents);
    return Database.fromJson(json);
  } catch (e) {
    return null;
  }
}
