import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmallText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const SmallText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.questrial(
        textStyle: Theme.of(context).textTheme.bodySmall,
      ).merge(style),
    );
  }
}

class MediumText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MediumText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.questrial(
        textStyle: Theme.of(context).textTheme.bodyMedium,
      ).merge(style),
    );
  }
}

class HeadingText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const HeadingText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.questrial(
        textStyle: Theme.of(context).textTheme.headlineMedium,
      ).merge(style),
    );
  }
}

class TitleText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TitleText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.questrial(
        textStyle: Theme.of(context).textTheme.titleMedium,
      ).merge(style),
    );
  }
}

class SpanMediumText extends StatelessWidget {
  final String _text;
  final TextOverflow overflow;
  final int maxLines;
  final bool softWrap;
  final TextStyle? style;

  const SpanMediumText(
    this._text, {
    super.key,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.softWrap = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      text: TextSpan(
        style: GoogleFonts.alexandria(
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ).merge(style),
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
  final TextStyle? style;

  const SpanSmallText(
    this._text, {
    super.key,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.softWrap = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      text: TextSpan(
        style: GoogleFonts.alexandria(
          textStyle: Theme.of(context).textTheme.bodySmall,
        ).merge(style),
        text: _text,
      ),
    );
  }
}
