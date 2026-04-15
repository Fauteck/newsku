import 'package:app/feed/views/components/feed_image.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/stats/model/stats.dart';
import 'package:app/stats/services/stats_service.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class InsightsWidget extends StatefulWidget {
  const InsightsWidget({super.key});

  @override
  State<InsightsWidget> createState() => _InsightsWidgetState();
}

class _InsightsWidgetState extends State<InsightsWidget> {
  late Future<Stats> _statsFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 7));
    _statsFuture = StatsService(serverUrl!).getStats(
      from: from.millisecondsSinceEpoch,
      to: now.millisecondsSinceEpoch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locals = AppLocalizations.of(context)!;

    return FutureBuilder<Stats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final topTags = stats.tagClicks.take(5).toList();
        final topFeeds = stats.feedClicks.take(3).toList();

        if (topTags.isEmpty && topFeeds.isEmpty) {
          return SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.zero,
          color: colors.surfaceContainerLow,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => AutoRouter.of(context).push(StatsRoute()),
            child: Padding(
              padding: EdgeInsets.all(pu4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: pu3,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, size: 16, color: colors.primary),
                      SizedBox(width: pu2),
                      Text(
                        locals.insightsTitle,
                        style: textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, size: 16, color: colors.onSurfaceVariant),
                    ],
                  ),
                  if (topTags.isNotEmpty) ...[
                    Text(locals.insightsTopTags, style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                    Wrap(
                      spacing: pu2,
                      runSpacing: pu,
                      children: topTags
                          .map(
                            (t) => Chip(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.symmetric(horizontal: pu, vertical: 0),
                              labelPadding: EdgeInsets.zero,
                              label: Text(
                                '${t.tag} (${t.clicks})',
                                style: textTheme.labelSmall,
                              ),
                              backgroundColor: colors.secondaryContainer,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (topFeeds.isNotEmpty) ...[
                    Text(
                      locals.insightsTopSources,
                      style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: pu2,
                      children: topFeeds
                          .map(
                            (f) => Row(
                              spacing: pu2,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FeedImage(item: f.feed, width: 16, height: 16),
                                ),
                                Expanded(
                                  child: Text(
                                    f.feed.name ?? '',
                                    style: textTheme.labelSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  f.clicks.toString(),
                                  style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
