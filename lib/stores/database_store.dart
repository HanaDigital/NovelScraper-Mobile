import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novelscraper/models/chapter_model.dart';
import 'package:novelscraper/models/database_model.dart';
import 'package:novelscraper/models/novel_isolate.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/novelfull.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:novelscraper/utils/epub/epub_factory.dart';
import 'package:novelscraper/utils/file.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init();

class DatabaseStore extends ChangeNotifier {
  Database _db = Database.emptyDB;
  Timer? _dbSaveDebounce;
  Completer _dbSaveCompleter = Completer();

  final Map<String, NovelIsolate> _novelIsolates = {};

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

  Future<void> downloadNovelWithIsolate(Novel novel) async {
    Future<void> Function(Map<String, Object>) isolateDownloadFunction;
    switch (novel.source) {
      case Source.novelfull:
        isolateDownloadFunction = NovelFull.downloadNovel;
    }

    final rPort = ReceivePort();
    final preDownloadedChapters = await readChaptersFromDisk(novel.url);
    final isolate = await Isolate.spawn(isolateDownloadFunction, {
      'sPort': rPort.sendPort,
      'novel': novel,
      'preDownloadedChapters': preDownloadedChapters,
    });
    NovelIsolate novelIsolate = NovelIsolate(isolate: isolate, rPort: rPort);
    _novelIsolates[novel.url] = novelIsolate;
    notifyListeners();

    rPort.listen((message) {
      if (message is List && message.isNotEmpty && message[0] is NovelIsolateAction) {
        switch (message[0]) {
          case NovelIsolateAction.setSendPort:
            _novelIsolates[novel.url]?.sPort = message[1];
            break;
          case NovelIsolateAction.setPercentage:
            _novelIsolates[novel.url]?.downloadPercentage = message[1];
            notifyListeners();
            break;
          case NovelIsolateAction.saveDownloadedChapters:
            List<Chapter> downloadedChapters = message[1];
            writeChaptersToDisk(novel.url, downloadedChapters);
            break;
          case NovelIsolateAction.generateEPUB:
            talker.info("[DatabaseStore] Generating EPUB");
            novel = message[1];
            List<Chapter> downloadedChapters = message[2];
            generateEPUB(novel, downloadedChapters).then((epub) async {
              if (epub != null) {
                await writeEPUBToDownloads(novel.title, epub);
                talker.info("[DatabaseStore] Created EPUB for novel: ${novel.title}");
              } else {
                talker.error("[DatabaseStore] Failed to create EPUB for novel: ${novel.title}");
              }
            });
            break;
          case NovelIsolateAction.done:
            talker.info("[DatabaseStore] Cleaning up isolate");
            novel = message[1];
            _db.novels[novel.url] = novel;
            _novelIsolates[novel.url]?.rPort.close();
            _novelIsolates[novel.url]?.isolate.kill();
            _novelIsolates.remove(novel.url);
            _saveDB();
            notifyListeners();
            break;
        }
      } else {
        talker.error("[DatabaseStore] Unknown isolate message: $message");
      }
    });
  }

  void cancelDownload(Novel novel) {
    _novelIsolates[novel.url]?.cancel = true;
    _novelIsolates[novel.url]?.sPort?.send([NovelIsolateAction.cancel]);
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
    _db.novels[url]?.downloadedChapters = 0;
    _db.novels.remove(url);
    clearNovelFiles(url);
    _saveDB();
    notifyListeners();
  }

  Database get db => _db;
  Map<String, NovelIsolate> get novelIsolates => _novelIsolates;

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
