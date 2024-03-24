import 'package:flutter/material.dart';
import 'package:novelscraper/components/dialog.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/stores/database_store.dart';
import 'package:novelscraper/utils/epub/epub_factory.dart';
import 'package:provider/provider.dart';

class NovelPage extends StatefulWidget {
  final Novel novel;

  const NovelPage({super.key, required this.novel});

  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  late Novel _novel;
  bool _isLoading = false;

  @override
  void initState() {
    _novel = widget.novel;
    loadNovel();

    super.initState();
  }

  void loadNovel() async {
    Novel? dbNovel = Provider.of<DatabaseStore>(context, listen: false).db.novels[_novel.url];
    if (dbNovel != null) {
      setState(() => _novel = dbNovel);
    } else {
      setState(() => _isLoading = true);
      final fetchedNovel = await _novel.fetchNovel();
      setState(() {
        _isLoading = false;
        _novel = fetchedNovel ?? _novel;
      });
    }
  }

  saveNovel() {
    setState(() {
      _novel.inLibrary = true;
    });
    Provider.of<DatabaseStore>(context, listen: false).setNovel(_novel);
  }

  removeNovel() {
    setState(() {
      _novel.inLibrary = false;
    });
    Provider.of<DatabaseStore>(context, listen: false).removeNovel(_novel.url);
  }

  void downloadNovel() {
    talker.info("Downloading ${_novel.title}");
    generateEPUB(_novel, []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText("Novel"),
        actions: [
          if (_novel.inLibrary)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _isLoading ? null : downloadNovel,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isLoading
                      ? null
                      : () => confirmationDialog(
                            context: context,
                            title: "Delete Novel",
                            body: "Are you sure you want to delete ${_novel.title} from your library?",
                            confirmText: "Delete",
                            onConfirm: removeNovel,
                            type: DialogType.destructive,
                          ),
                ),
              ],
            ),
          if (!_novel.inLibrary)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : saveNovel,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (!_isLoading)
              Column(
                children: [
                  Image.network(_novel.coverURL ?? _novel.thumbnailURL ?? ""),
                  TitleText(_novel.title),
                  Text(_novel.authors.join(", ")),
                  Text(_novel.genres.join(", ")),
                  Text(_novel.alternateTitles.join(", ")),
                  Text(_novel.description ?? ""),
                  Text(_novel.rating ?? ""),
                  Text(_novel.latestChapterName ?? ""),
                  Text("${_novel.totalChapters} chapters"),
                  Text("${_novel.downloadedChapters} downloaded"),
                  Text(_novel.status ?? ""),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
