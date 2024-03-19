import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/source_model.dart';
import 'package:novelscraper/theme.dart';

class SourcePage extends StatefulWidget {
  final Source source;

  const SourcePage({super.key, required this.source});

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  final _searchController = TextEditingController();

  void handleSearch(String query) {
    print("Searching for $query");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: TitleText(widget.source.name),
      ),
      body: Row(
        children: [
          Expanded(
            child: TextField(
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
          ),
        ],
      ),
    );
  }
}
