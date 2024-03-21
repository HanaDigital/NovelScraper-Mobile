import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novelscraper/theme.dart';

class SmallText extends StatelessWidget {
  final String text;

  const SmallText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.questrial(
        textStyle: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class MediumText extends StatelessWidget {
  final String text;

  const MediumText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.questrial(
        textStyle: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class HeadingText extends StatelessWidget {
  final String text;

  const HeadingText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.alexandria(textStyle: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class TitleText extends StatelessWidget {
  final String text;

  const TitleText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: GoogleFonts.alexandria(textStyle: Theme.of(context).textTheme.titleMedium));
  }
}

class SpanTitleText extends StatelessWidget {
  final String text;

  const SpanTitleText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        style: GoogleFonts.alexandria(
          textStyle: Theme.of(context).textTheme.titleMedium,
          color: AppColors.titleColor,
          fontSize: 14,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
        ),
        text: text,
      ),
    );
  }
}
