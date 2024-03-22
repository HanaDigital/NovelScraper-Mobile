import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novelscraper/components/novel_list.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/stores/database_store.dart';
import 'package:novelscraper/theme.dart';
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init();

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _searchController = TextEditingController();
  String _query = "";

  void handleSearch(String query) {
    setState(() => _query = query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: const TitleText("Library"),
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
          ),

          // Library list of novels
          Consumer<DatabaseStore>(
            builder: (context, dbStore, child) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NovelList(
                    novels: dbStore.db.novels.values.where((novel) {
                      if (_query.isEmpty) return true;
                      if (novel.title.toLowerCase().contains(_query.toLowerCase())) return true;
                      return false;
                    }).toList(),
                    pathPrefix: "/library",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
