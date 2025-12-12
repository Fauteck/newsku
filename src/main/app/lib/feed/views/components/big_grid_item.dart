import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/clickable_feed_item.dart';
import 'package:app/feed/views/components/info_bar.dart';
import 'package:app/feed/views/components/item_content.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../screens/feed_screen.dart';
import 'feed_item_image.dart';

class BigGridItem extends StatelessWidget {
  final FeedItem item;

  const BigGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return ClickableFeedItem(
      item: item,
      child: Container(
        decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: .circular(feedItemBorderRadius)),
        child: Column(
          spacing: 0,
          crossAxisAlignment: .stretch,
          children: [
            FeedItemImage(
              item: item,
              height: 180,
              borderRadius: BorderRadius.vertical(top: .circular(feedItemBorderRadius)),
            ),
            Align(
              alignment: .centerLeft,
              child: Container(
                width: 100,
                height: 8,
                margin: .only(left: 8),
                decoration: BoxDecoration(color: colors.tertiary),
              ),
            ),
            Gap(8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: .stretch,
                  spacing: 8,
                  children: [
                    Text(
                      item.title ?? '',
                      style: textTheme.headlineSmall?.copyWith(height: 1.4),
                      maxLines: 3,
                      overflow: .ellipsis,
                    ),
                    // Expanded(child: Text(item.description ?? item.content ?? '', maxLines: 3,)),
                    Expanded(
                      child: ItemContent(item: item, maxLines: 4, overflow: .ellipsis),
                    ),
                    InfoBar(item: item),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
