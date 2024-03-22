import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class SpanMediumText extends StatelessWidget {
  final String _text;
  final TextOverflow overflow;
  final int maxLines;
  final bool softWrap;

  const SpanMediumText(this._text, {super.key, this.overflow = TextOverflow.ellipsis, this.maxLines = 1, this.softWrap = true});

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      text: TextSpan(
        style: GoogleFonts.alexandria(
          textStyle: Theme.of(context).textTheme.bodyMedium,
          fontWeight: FontWeight.bold,
        ),
        text: _text,
      ),
    );
  }
}

class SpanSmallText extends StatelessWidget {
  final String _text;
  final TextOverflow overflow;
  final int maxLines;
  final bool softWrap;

  const SpanSmallText(this._text, {super.key, this.overflow = TextOverflow.ellipsis, this.maxLines = 1, this.softWrap = true});

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      text: TextSpan(
        style: GoogleFonts.alexandria(
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
        text: _text,
      ),
    );
  }
}
