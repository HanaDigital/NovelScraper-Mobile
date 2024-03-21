import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novelscraper/components/novel_list.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/models/sources/novelfull.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:novelscraper/theme.dart';

class SourcePage extends StatefulWidget {
  final Source source;

  const SourcePage({super.key, required this.source});

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isSearched = false;
  List<Novel> _novels = [];

  void handleSearch(String query) async {
    setState(() => _isSearching = true);
    switch (widget.source) {
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
        title: TitleText(widget.source.name),
      ),
      body: Column(
        children: [
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
          if (!_isSearching && _novels.isNotEmpty) NovelList(novels: _novels),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            ),
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
