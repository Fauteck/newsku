import 'package:flutter/material.dart';

class PreviewContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  const PreviewContainer({super.key, this.width, this.height, this.borderRadius, this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: borderRadius),
      child: child,
    );
  }
}
