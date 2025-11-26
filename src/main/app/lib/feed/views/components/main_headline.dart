import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/models/time_block_feed.dart';
import 'package:app/feed/views/components/feed_image.dart';
import 'package:app/feed/views/components/feed_item_image.dart';
import 'package:app/feed/views/components/info_bar.dart';
import 'package:app/feed/views/components/item_content.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../screens/feed_screen.dart';

const double _roundImageSize = 100;

class MainHeadline extends StatelessWidget {
  final TimeBlockFeed feed;

  const MainHeadline({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      clipBehavior: .none,
      constraints: BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(color: colors.surfaceContainerHigh,
      borderRadius: .circular(feedItemBorderRadius)
      ),
      margin: .only(bottom: 16),
      padding: .all(16),
      child: Row(
        spacing: 24,
        crossAxisAlignment: .stretch,
        children: [
          Align(
            alignment: .topCenter,
            child: SizedBox(
              height: 200,
              child: RotatedBox(
                quarterTurns: 1,
                child: Container(
                    decoration: BoxDecoration(
                        color: colors.tertiary,
                        borderRadius: .circular(50)
                    ),
                    padding: .symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: .center,
                      spacing: 8,
                      children: [
                        Icon(Icons.star, color: colors.onTertiary,),
                        Text('Top Stories', style: textTheme.bodyLarge?.copyWith(fontSize: 25, color: colors.onTertiary, fontWeight: .bold),),
                      ],
                    )),
              ),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 24,
              children: feed.headlines.indexed
                  .map(
                    (e) => Column(
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
                                  Text(e.$2.title ?? '', style: textTheme.headlineMedium, maxLines: 2, overflow: .ellipsis),
                                  InfoBar(item: e.$2),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (e.$1 < feed.headlines.length - 1) ...[
                          Gap(24),
                          Align(
                            alignment: .centerLeft,
                            child: SizedBox(width: 200, child: Divider(indent: 16, thickness: 3, radius: .circular(20))),
                          ),
                        ],
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          if (feed.mainHeadline != null)
            Expanded(
              child: SizedBox(
                height: 300,
                child: Column(
                  crossAxisAlignment: .stretch,
                  mainAxisAlignment: .start,
                  spacing: 24,
                  children: [
                    FeedItemImage(item: feed.mainHeadline!, height: 200, borderRadius: .circular(feedItemBorderRadius),),
                    Text(feed.mainHeadline?.title ?? '', style: textTheme.headlineLarge),
                    Expanded(child: ItemContent(item: feed.mainHeadline!)),
                    InfoBar(item: feed.mainHeadline!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
