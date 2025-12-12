import 'dart:ui';

import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/main_color_provider.dart';
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class Done extends StatelessWidget {
  const Done({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return MainColorProvider(
      builder: (context, color) {
        return SingleMotionBuilder(
          motion: MaterialSpringMotion.expressiveSpatialSlow(),
          from: 0,
          value: 1,
          builder: (context, value, child) => Opacity(
            opacity: value.clamp(0, 1),
            child: Transform.scale(scale: lerpDouble(0.9, 1, value), child: child),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              spacing: 32,
              children: [
                Text(locals.setupComplete, style: textTheme.displaySmall),
                Icon(Icons.check, size: 100, color: color),
              ],
            ),
          ),
        );
      },
    );
  }
}
