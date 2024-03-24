import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/models/sources/source_model.dart';
import 'package:novelscraper/theme.dart';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: const TitleText("Sources"),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final source in Source.values)
                InkWell(
                  onTap: () {
                    context.go("/sources/source/${source.name}", extra: source);
                  },
                  child: FractionallySizedBox(
                    widthFactor: 0.49,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            Image.asset("assets/${source.logoSrc}"),
                            const SizedBox(height: 8),
                            SmallText(source.name),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
