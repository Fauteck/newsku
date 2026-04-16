import 'package:app/feed/models/feed_item.dart';
import 'package:app/home/state/local_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motor/motor.dart';

class ItemTitle extends StatelessWidget {
  final FeedItem item;
  final bool hovered;
  final int? maxLines;
  final TextStyle? style;
  final TextOverflow? overflow;

  const ItemTitle({super.key, required this.item, this.maxLines, this.style, this.overflow, required this.hovered});

  @override
  Widget build(BuildContext outerContext) {
    return SingleMotionBuilder(
      motion: LinearMotion(Duration(milliseconds: 250)),
      value: hovered ? 1 : 0,
      from: 0,
      builder: (context, value, child) {
        final textTheme = Theme.of(context).textTheme;
        final colors = Theme.of(context).colorScheme;
        var textStyle = style ?? textTheme.bodyMedium;

        // When the global "Textkürzung" preference is enabled and the backend
        // provided an AI-rewritten shortTitle, render that as a full string
        // (no clamp/ellipsis). Otherwise render the original title.
        final shorten = context.select((LocalPreferencesCubit p) => p.state.truncateText);
        final hasShort = (item.shortTitle ?? '').isNotEmpty;
        final text = (shorten && hasShort) ? item.shortTitle! : (item.title ?? '');

        return Text(
          key: Key('item-title'),
          text,
          style: (textStyle)?.copyWith(color: Color.lerp(textStyle.color, colors.primary, value)),
          maxLines: (shorten && hasShort) ? null : maxLines,
          overflow: (shorten && hasShort) ? null : overflow,
        );
      },
    );
  }
}
