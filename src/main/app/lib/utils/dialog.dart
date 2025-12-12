import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<void> okCancelDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required Function() onOk,
  bool showCancel = true,
}) async {
  final locals = AppLocalizations.of(context)!;
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: content,
      actions: <Widget>[
        if (showCancel) TextButton(onPressed: () => Navigator.pop(context, null), child: Text(locals.cancel)),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onOk();
          },
          child: Text(locals.ok),
        ),
      ],
    ),
  );
}
