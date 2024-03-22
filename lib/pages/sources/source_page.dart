import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novelscraper/components/novel_list.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/novelfull.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:novelscraper/theme.dart';

class SourcePage extends StatefulWidget {
  final String sourceName;

  const SourcePage({super.key, required this.sourceName});

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  late final Source source;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isSearched = false;
  List<Novel> _novels = [];

  @override
  void initState() {
    source = Source.values.firstWhere((source) => source.name == widget.sourceName);
    super.initState();
  }

  void handleSearch(String query) async {
    query = query.trim();
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    switch (source) {
      case Source.novelfull:
        final novels = await NovelFull().search(query);
        setState(() => _novels = novels);
        break;
    }
    setState(() {
      _isSearching = false;
      _isSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: TitleText(source.name),
      ),
      body: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onSubmitted: handleSearch,
            style: GoogleFonts.questrial(
              textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            cursorColor: AppColors.textColor,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              label: MediumText("Search for a novel"),
            ),
            readOnly: _isSearching,
          ),

          // Novels list
          if (!_isSearching && _novels.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: NovelList(
                  novels: _novels,
                  pathPrefix: "/sources/source/${source.name}",
                ),
              ),
            ),

          // Loading indicator
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            ),

          // No novels found
          if (_novels.isEmpty && !_isSearching && _isSearched)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: AppColors.textColor, size: 18),
                  const SizedBox(width: 4),
                  const MediumText("No novels found"),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
