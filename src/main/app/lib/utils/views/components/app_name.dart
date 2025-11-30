import 'package:app/main.dart';
import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  final TextStyle? style;
  final MainAxisAlignment? alignment;

  const AppName({super.key, this.style, this.alignment});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: alignment ?? .start,
      children: [
        Text('news', style: style?.copyWith(color: textTheme.bodyMedium?.color)),
        Text('ku', style: (style ?? textTheme.bodyMedium)?.copyWith(color: seedColor)),
      ],
    );
  }
}
