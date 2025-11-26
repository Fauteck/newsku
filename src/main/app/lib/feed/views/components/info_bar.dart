import 'dart:math';

import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/feed_image.dart';
import 'package:app/feed/views/screens/feed_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class InfoBar extends StatelessWidget {
  final FeedItem item;

  const InfoBar({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Row(
      spacing: 8,
      children: [
        ClipRRect(
            borderRadius: .circular(20),
            child: FeedImage(item: item.feed!, width: 20, height: 20)),
        Expanded(
          child: Text(
            '${item.feed?.name ?? ''} - ${articleDateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.timeCreated))}',
            style: textTheme.labelMedium?.copyWith(color: colors.onSecondaryContainer),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: .circular(20)),
          padding: .symmetric(vertical: 2, horizontal: 8),
          child: Row(
            spacing: 4,
            crossAxisAlignment: .center,
            children: [
              Tooltip(
                message: item.reasoning,
                child: Row(spacing: 4, children: [Icon(Icons.label_important_outline, size: 15), Text(item.importance.toStringAsFixed(0))]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
