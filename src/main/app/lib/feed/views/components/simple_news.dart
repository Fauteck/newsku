import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/clickable_feed_item.dart';
import 'package:app/feed/views/components/feed_item_image.dart';
import 'package:app/feed/views/components/info_bar.dart';
import 'package:app/feed/views/components/item_content.dart';
import 'package:app/feed/views/screens/feed_screen.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SimpleNews extends StatelessWidget {
  final FeedItem item;

  const SimpleNews({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return ClickableFeedItem(
      item: item,
      child: Container(
        // constraints: BoxConstraints(maxHeight: 100),
        // margin: .only(top: 16),
        decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: .circular(feedItemBorderRadius)),
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              child: Padding(
                padding: .symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: .stretch,
                  spacing: 4,
                  children: [
                    Text(item.title ?? '', style: textTheme.bodyLarge, overflow: .ellipsis, maxLines: 2,),
                    Expanded(
                      child: Align(
                          alignment: .centerLeft,
                          child: ItemContent(item: item, maxLines: 1, overflow: .ellipsis,)),
                    ),
                    InfoBar(item: item),
                  ],
                ),
              ),
            ),
            Align(
              alignment: .centerLeft,
              child: Container(width: 4, height: 50, decoration: BoxDecoration(color: colors.tertiary)),
            ),
            FeedItemImage(
              item: item,
              borderRadius: .horizontal(right: .circular(feedItemBorderRadius)),
              width: switch (BreakPoint.get(context)) {
                .mobile => 20,
                .tablet => 50,
                _ => 70,
              },
            ),
          ],
        ),
      ),
    );
  }
}
