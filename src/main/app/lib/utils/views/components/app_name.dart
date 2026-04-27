import 'package:app/utils/views/components/main_color_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppName extends StatelessWidget {
  final TextStyle? style;
  final MainAxisAlignment? alignment;
  final VoidCallback? onTap;

  const AppName({super.key, this.style, this.alignment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effectiveStyle = style ?? textTheme.bodyMedium;
    final iconSize = (effectiveStyle?.fontSize ?? 14) * 1.6;

    return MainColorProvider(
      builder: (context, mainColor) {
        Widget content = Row(
          mainAxisAlignment: alignment ?? MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/feedteck.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text('Feed', style: effectiveStyle?.copyWith(color: textTheme.bodyMedium?.color)),
            Text('teck', style: effectiveStyle?.copyWith(color: mainColor)),
          ],
        );
        if (onTap != null) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(onTap: onTap, child: content),
          );
        }
        return content;
      },
    );
  }
}
