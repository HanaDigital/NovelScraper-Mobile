import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novelscraper/models/database_model.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/utils/file.dart';

class DatabaseStore extends ChangeNotifier {
  Database _db = Database.emptyDB;
  Timer? _dbSaveDebounce;
  Completer _dbSaveCompleter = Completer();

  DatabaseStore() {
    _dbSaveCompleter.complete();
    readDatabase().then((db) {
      if (db != null) {
        _db = db;
        notifyListeners();
      } else {
        writeDatabase(_db);
      }
    });
  }

  void setNovel(Novel novel) {
    _db.novels[novel.url] = novel;
    _saveDB();
    notifyListeners();
  }

  void removeNovel(String url) {
    _db.novels.remove(url);
    _saveDB();
    notifyListeners();
  }

  Database get db => _db;

  void _saveDB() async {
    if (_dbSaveDebounce?.isActive ?? false) _dbSaveDebounce?.cancel();
    if (!_dbSaveCompleter.isCompleted) await _dbSaveCompleter.future;
    _dbSaveCompleter = Completer();
    _dbSaveDebounce = Timer(const Duration(seconds: 1), () async {
      await writeDatabase(_db);
      _dbSaveCompleter.complete();
    });
  }

  @override
  void dispose() {
    _dbSaveDebounce?.cancel();
    _dbSaveCompleter.complete();
    super.dispose();
  }
}
