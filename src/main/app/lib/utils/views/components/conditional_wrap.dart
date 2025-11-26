import 'package:flutter/cupertino.dart';

class ConditionalWrap extends StatelessWidget {
  final bool wrapIf;
  final Widget Function(Widget child) wrapper;
  final Widget child;

  const ConditionalWrap({super.key, required this.wrapIf, required this.wrapper, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!wrapIf) {
      return child;
    } else {
      return wrapper(child);
    }
  }
}
