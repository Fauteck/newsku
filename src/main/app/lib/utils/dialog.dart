import 'package:flutter/material.dart';

Future<void> okCancelDialog(
    BuildContext context, {
      required String title,
      required Widget content,
      required Function() onOk,
      bool showCancel = true,
    }) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: content,
      actions: <Widget>[
        if (showCancel) TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'OK');
            onOk();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
