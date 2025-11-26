import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final double? height;
  final double? width;

  const ImagePlaceholder({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: colors.secondaryContainer),
      child: Center(child: Icon(Icons.image_outlined, color: colors.onSecondaryContainer.withValues(alpha: 0.5),),),
    );
  }
}
