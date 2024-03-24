import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novelscraper/models/database_model.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/novelfull.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:novelscraper/utils/file.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init();

class DatabaseStore extends ChangeNotifier {
  Database _db = Database.emptyDB;
  Timer? _dbSaveDebounce;
  Completer _dbSaveCompleter = Completer();

  final Map<String, double> _downloadTracker = {};

  DatabaseStore() {
    _dbSaveCompleter.complete();
    readDatabaseFromDisk().then((db) {
      if (db != null) {
        talker.info("[DatabaseStore] Loaded database");
        _db = db;
        notifyListeners();
      } else {
        talker.warning("[DatabaseStore] Created new database");
        writeDatabaseToDisk(_db);
      }
    });
  }

  void downloadNovel(Novel novel) async {
    _updateDownloadProgress(novel.url, 0);
    switch (novel.source) {
      case Source.novelfull:
        novel = await NovelFull.downloadNovel(novel);
    }
    _removeDownloadProgress(novel.url);

    db.novels[novel.url] = novel;
    _saveDB();
    notifyListeners();
  }

  void setNovel(Novel novel) {
    novel.inLibrary = true;
    _db.novels[novel.url] = novel;
    _saveDB();
    notifyListeners();
  }

  void removeNovel(String url) {
    _db.novels[url]?.inLibrary = false;
    _db.novels[url]?.isDownloaded = false;
    _db.novels.remove(url);
    clearNovelFiles(url);
    _saveDB();
    notifyListeners();
  }

  Database get db => _db;
  Map<String, double> get downloadTracker => _downloadTracker;

  void _updateDownloadProgress(String novelURL, double progress) {
    _downloadTracker[novelURL] = progress;
    notifyListeners();
  }

  void _removeDownloadProgress(String novelURL) {
    _downloadTracker.remove(novelURL);
    notifyListeners();
  }

  Future<void> _saveDB() async {
    if (_dbSaveDebounce?.isActive ?? false) _dbSaveDebounce?.cancel();
    if (!_dbSaveCompleter.isCompleted) await _dbSaveCompleter.future;
    _dbSaveCompleter = Completer();
    _dbSaveDebounce = Timer(const Duration(seconds: 1), () async {
      await writeDatabaseToDisk(_db);
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
