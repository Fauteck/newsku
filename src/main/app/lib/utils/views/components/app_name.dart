import 'package:app/utils/views/components/main_color_provider.dart';
import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  final TextStyle? style;
  final MainAxisAlignment? alignment;

  const AppName({super.key, this.style, this.alignment});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MainColorProvider(
      builder: (context, mainColor) {
        return Row(
          mainAxisAlignment: alignment ?? .start,
          children: [
            Text('news', style: (style ?? textTheme.bodyMedium)?.copyWith(color: textTheme.bodyMedium?.color)),
            Text('ku', style: (style ?? textTheme.bodyMedium)?.copyWith(color: mainColor)),
          ],
        );
      },
    );
  }
}
