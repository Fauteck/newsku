import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motor/motor.dart';

final _df = DateFormat.yMMMd();

class DateBar extends StatelessWidget {
  final DateTime date;
  final bool isPinned;
  final bool isFirst;

  const DateBar({super.key, required this.date, required this.isPinned, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!isFirst && !isPinned) {
      return SizedBox.shrink();
    }
    return SingleMotionBuilder(
      motion: MaterialSpringMotion.expressiveEffectsDefault(),
      from: 0,
      value: isPinned ? 0 : 1,
      builder: (context, value, child) => Container(
        decoration: BoxDecoration(color: colors.surface),
        padding: .symmetric(vertical: lerpDouble(8, 64, value.clamp(0, 1))!),
        child: Row(
          mainAxisSize: .max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .center,
                spacing: lerpDouble(0, 8, value)!,
                children: [
                  Text(_df.format(date), style: textTheme.bodyLarge?.copyWith(fontSize: lerpDouble(13, 35, value))),
                  Center(child: SizedBox(width: lerpDouble(0, 500, value), height: lerpDouble(0, 3, value), child: Divider(thickness: 3)))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
