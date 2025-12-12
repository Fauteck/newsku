import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/clickable_feed_item.dart';
import 'package:app/feed/views/components/feed_item_image.dart';
import 'package:app/feed/views/components/info_bar.dart';
import 'package:app/feed/views/components/item_content.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../screens/feed_screen.dart';

const double _roundImageSize = 100;

class TopStories extends StatelessWidget {
  final List<FeedItem> items;
  final LayoutBlock block;

  const TopStories({super.key, required this.items, required this.block});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      clipBehavior: .none,
      constraints: BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: .circular(feedItemBorderRadius)),
      padding: .all(16),
      child: Row(
        spacing: 24,
        crossAxisAlignment: .stretch,
        children: [
          Align(
            alignment: .topCenter,
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                decoration: BoxDecoration(color: colors.tertiary, borderRadius: .circular(50)),
                padding: .symmetric(horizontal: 16),
                child: Text(
                  (block.settings ?? block.type.defaultSettings).title ?? '★ Top Stories',
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: textTheme.bodyLarge?.copyWith(fontSize: 25, color: colors.onTertiary),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 24,
              children: items
                  .skip(1)
                  .indexed
                  .map(
                    (e) => ClickableFeedItem(
                      item: e.$2,
                      child: Column(
                        children: [
                          Row(
                            spacing: 24,
                            children: [
                              FeedItemImage(
                                item: e.$2,
                                width: _roundImageSize,
                                height: _roundImageSize,
                                borderRadius: .circular(_roundImageSize),
                                border: .all(color: colors.tertiary, width: 5),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: .stretch,
                                  children: [
                                    Text(
                                      e.$2.title ?? '',
                                      style: textTheme.headlineMedium?.copyWith(height: 1.4),
                                      maxLines: 2,
                                      overflow: .ellipsis,
                                    ),
                                    InfoBar(item: e.$2),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (e.$1 < items.skip(1).length - 1) ...[
                            Gap(24),
                            Align(
                              alignment: .center,
                              child: SizedBox(
                                width: 200,
                                child: Divider(indent: 16, thickness: 3, radius: .circular(20)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (items.isNotEmpty)
            Expanded(
              child: ClickableFeedItem(
                item: items.first,
                child: SizedBox(
                  height: 300,
                  child: Column(
                    crossAxisAlignment: .stretch,
                    mainAxisAlignment: .start,
                    spacing: 24,
                    children: [
                      FeedItemImage(item: items.first, height: 200, borderRadius: .circular(feedItemBorderRadius)),
                      Text(
                        items.first.title ?? '',
                        style: textTheme.headlineLarge?.copyWith(height: 1.4),
                        maxLines: 3,
                        overflow: .ellipsis,
                      ),
                      Expanded(
                        child: ItemContent(item: items.first, maxLines: 2, overflow: .ellipsis),
                      ),
                      InfoBar(item: items.first),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
