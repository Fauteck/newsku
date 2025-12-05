import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/clickable_feed_item.dart';
import 'package:app/feed/views/components/feed_item_image.dart';
import 'package:app/feed/views/components/info_bar.dart';
import 'package:app/feed/views/components/item_content.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SearchResult extends StatelessWidget {
  final FeedItem item;
  final bool fullDate;

  const SearchResult({super.key, required this.item,  this.fullDate = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final breakPoint = BreakPoint.get(context);

    return Padding(
      padding: .symmetric(horizontal: 32, vertical: 16),
      child: ClickableFeedItem(
        item: item,
        child: Row(
          crossAxisAlignment: .center,
          children: [
            FeedItemImage(item: item, width: breakPoint == .mobile? 50 : 100, height: breakPoint == .mobile ? 50: 100, borderRadius: .circular(10)),
            Gap(32),
            Expanded(
              child: Column(
                crossAxisAlignment: .stretch,
                spacing: 8,
                children: [
                  Text(item.title ?? '', style: breakPoint == .mobile ? textTheme.titleMedium : textTheme.headlineSmall, maxLines: 2, overflow: .ellipsis),
                  ItemContent(item: item, maxLines: breakPoint == .mobile ? 1 : 3 , overflow: .ellipsis),
                  InfoBar(item: item, fullDate: fullDate,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
