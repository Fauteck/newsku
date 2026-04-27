import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  final IconData? icon;
  final double? iconSize;

  /// When true, the placeholder represents a load failure (e.g. blocked
  /// hotlink, deleted image) rather than a transient loading state, and
  /// renders a broken-image icon over a subdued error tint.
  final bool isError;

  const ImagePlaceholder({
    super.key,
    this.height,
    this.width,
    this.icon,
    this.iconSize,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isError ? colors.errorContainer : colors.secondaryContainer;
    final foreground = isError ? colors.onErrorContainer : colors.onSecondaryContainer;
    final effectiveIcon = isError
        ? Icons.broken_image_outlined
        : (icon ?? Icons.image_outlined);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: background),
      child: Center(
        child: Icon(
          effectiveIcon,
          size: iconSize,
          color: foreground.withValues(alpha: isError ? 0.7 : 0.5),
        ),
      ),
    );
  }
}
