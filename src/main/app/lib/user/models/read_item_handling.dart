import 'package:flutter/cupertino.dart';

enum ReadItemHandling {
  none,
  dim,
  hide;

  String getLabel(BuildContext context) {
    return switch (this) {
      none => 'None',
      dim => 'Dim',
      hide => 'Hide',
    };
  }
}
