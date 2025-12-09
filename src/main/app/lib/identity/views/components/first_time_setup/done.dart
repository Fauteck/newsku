import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Done extends StatelessWidget {
  const Done({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      spacing: 32,
      children: [
        Text(locals.setupComplete, style: textTheme.displaySmall),
        Icon(Icons.check, size: 100),
      ],
    );
  }
}
