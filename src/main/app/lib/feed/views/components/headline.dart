import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/clickable_feed_item.dart';
import 'package:app/feed/views/components/feed_item_image.dart';
import 'package:app/feed/views/components/info_bar.dart';
import 'package:app/feed/views/components/item_content.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Headline extends StatelessWidget {
  final FeedItem item;

  const Headline({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: .symmetric(horizontal: 4),
      child: ClickableFeedItem(
        item: item,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            FeedItemImage(item: item, height: 350, borderRadius: .circular(10)),
            Gap(16),
            Text(item.title ?? ' ', style: textTheme.displaySmall),
            Gap(8),
            ItemContent(item: item, maxLines: 5, style: textTheme.bodyLarge),
            Gap(16),
            InfoBar(item: item),
          ],
        ),
      ),
    );
  }
}
