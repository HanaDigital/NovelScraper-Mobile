import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novelscraper/components/novel_list.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/stores/database_store.dart';
import 'package:novelscraper/theme.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: const TitleText("Library"),
      ),
      body: LibrarySearch(novels: Provider.of<DatabaseStore>(context).db.novels.values.toList()),
    );
  }
}

class LibrarySearch extends StatefulWidget {
  final List<Novel> novels;

  const LibrarySearch({super.key, required this.novels});

  @override
  State<LibrarySearch> createState() => _LibrarySearchState();
}

class _LibrarySearchState extends State<LibrarySearch> {
  final _searchController = TextEditingController();
  List<Novel> _searchedNovels = [];

  @override
  void initState() {
    _searchedNovels = widget.novels;
    super.initState();
  }

  void handleSearch(String query) {
    query = query.trim();
    if (query.isEmpty)
      setState(() => _searchedNovels = widget.novels);
    else
      setState(() {
        _searchedNovels = widget.novels.where((novel) => novel.title.toLowerCase().contains(query.toLowerCase())).toList();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ),

        // Library list of novels
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NovelList(
              novels: _searchedNovels,
              pathPrefix: "/library",
            ),
          ),
        ),
      ],
    );
  }
}
