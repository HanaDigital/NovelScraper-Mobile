import 'package:flutter/material.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/stores/database_store.dart';
import 'package:provider/provider.dart';

class NovelPage extends StatefulWidget {
  final Novel novel;

  const NovelPage({super.key, required this.novel});

  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  late Novel _novel;
  bool _isFetching = false;

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
      setState(() => _isFetching = true);
      final fetchedNovel = await _novel.fetchNovel();
      setState(() {
        _isFetching = false;
        _novel = fetchedNovel ?? _novel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText("Novel"),
      ),
      body: Center(
        child: Column(
          children: [
            MediumText(widget.novel.title),
            ElevatedButton(
              onPressed: () {
                Provider.of<DatabaseStore>(context, listen: false).setNovel(widget.novel);
              },
              child: const SmallText("Save Novel"),
            ),
          ],
        ),
      ),
    );
  }
}
