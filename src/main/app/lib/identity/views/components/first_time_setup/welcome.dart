import 'dart:ui';

import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SingleMotionBuilder(
      motion: Motion.linear(Duration(milliseconds: 250)),
      from: 0,
      value: 1,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: lerpDouble(0.9, 1, value), child: child),
      ),
      child: Column(
        crossAxisAlignment: .center,
        mainAxisAlignment: .center,
        spacing: 32,
        children: [
          AppLogo(color: localPreferences.themeColor, size: 100),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 350),
            child: Text(locals.welcomeText, style: textTheme.bodyLarge, textAlign: .center),
          ),
        ],
      ),
    );
  }
}
