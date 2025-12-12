import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/feed_image.dart';
import 'package:app/feed/views/screens/feed_screen.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/dialog.dart';
import 'package:flutter/material.dart';

class InfoBar extends StatelessWidget {
  final FeedItem item;
  final bool fullDate;

  const InfoBar({super.key, required this.item, this.fullDate = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    return Row(
      spacing: 8,
      children: [
        ClipRRect(
          borderRadius: .circular(20),
          child: FeedImage(item: item.feed!, width: 20, height: 20),
        ),
        Expanded(
          child: Text(
            item.feed?.name ?? '',
            style: textTheme.labelMedium?.copyWith(color: colors.onSecondaryContainer),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        Text(
          (fullDate ? fullArticleDateFormat : articleDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(item.timeCreated),
          ),
          style: textTheme.labelMedium?.copyWith(color: colors.onSecondaryContainer),
        ),
        InkWell(
          onTap: () => okCancelDialog(
            context,
            title: locals.reasoning,
            content: ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: Text(item.reasoning ?? '')),
            onOk: () {},
            showCancel: false,
          ),
          child: Container(
            decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: .circular(20)),
            padding: .symmetric(vertical: 2, horizontal: 8),
            child: Row(
              spacing: 4,
              crossAxisAlignment: .center,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    Icon(Icons.label_important_outline, size: 12),
                    Text(item.importance.toStringAsFixed(0), style: textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
