import 'dart:math';

import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/states/main_feed.dart';
import 'package:app/feed/views/components/date_bar.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/magazine/models/magazine_tab.dart';
import 'package:app/magazine/services/magazine_tab_service.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

// Match the authenticated feed's initial load (3 × 24h) so a shared link
// shows the same items the tab owner would see right after a refresh.
const int _initialBlockCount = 3;
const Duration _timeBlockDuration = Duration(hours: 24);

@RoutePage()
class PublicMagazineScreen extends StatefulWidget {
  final String tabId;

  const PublicMagazineScreen({super.key, @PathParam('tabId') required this.tabId});

  @override
  State<PublicMagazineScreen> createState() => _PublicMagazineScreenState();
}

class _PublicMagazineScreenState extends State<PublicMagazineScreen> {
  MagazineTab? _tab;
  Map<DateTimeRange, List<FeedItem>> _itemsByRange = {};
  List<LayoutBlock> _layout = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final url = serverUrl;
      if (url == null) {
        setState(() {
          _loading = false;
          _error = 'Server-URL nicht konfiguriert';
        });
        return;
      }
      final service = PublicMagazineService(url);

      final tabFuture = service.getTab(widget.tabId);
      final layoutFuture = service.getTabLayout(widget.tabId);

      DateTime cursor = DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
      final ranges = <DateTimeRange>[];
      for (int i = 0; i < _initialBlockCount; i++) {
        final from = cursor.subtract(_timeBlockDuration);
        ranges.add(DateTimeRange(start: from, end: cursor));
        cursor = from;
      }
      final itemsFutures = ranges.map(
        (r) => service.getItems(
          widget.tabId,
          from: r.start.millisecondsSinceEpoch,
          to: r.end.millisecondsSinceEpoch,
        ),
      );

      final tab = await tabFuture;
      final layout = await layoutFuture;
      final itemLists = await Future.wait(itemsFutures);

      if (!mounted) return;
      final byRange = <DateTimeRange, List<FeedItem>>{};
      for (int i = 0; i < ranges.length; i++) {
        byRange[ranges[i]] = itemLists[i];
      }
      setState(() {
        _tab = tab;
        _layout = layout;
        _itemsByRange = byRange;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<Widget> _buildSliversForRange({
    required BuildContext context,
    required DateTimeRange range,
    required List<FeedItem> immutableItems,
    required double padding,
    required bool isFirstRange,
  }) {
    final List<Widget> slivers = [];
    final List<FeedItem> items = List.from(immutableItems);

    for (final (index, block) in _layout.indexed) {
      if (items.isEmpty) break;

      final settings = block.settings ?? block.type.defaultSettings;
      List<FeedItem> blockItems;
      if (index == _layout.length - 1) {
        if (block.type.fixedSize || settings.lastBlockShowAll) {
          blockItems = List.from(items);
        } else {
          final size = settings.items ?? 0;
          blockItems = items
              .where((i) => settings.categoryId == null || i.feed?.category?.id == settings.categoryId)
              .take(size > 0 ? size : items.length)
              .toList();
        }
      } else {
        final size = block.type.fixedItemSize ?? settings.items ?? 0;
        blockItems = items
            .where((i) => settings.categoryId == null || i.feed?.category?.id == settings.categoryId)
            .take(size)
            .toList();
      }

      if (blockItems.isNotEmpty) {
        slivers.add(block.type.getSliver(context: context, items: blockItems, block: block));
      }
      for (final element in blockItems) {
        items.remove(element);
      }
    }

    for (int i = 0; i < slivers.length; i++) {
      slivers[i] = SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: padding + pu4),
        sliver: SliverStickyHeader.builder(
          builder: (context, state) =>
              DateBar(date: range.end, isPinned: state.isPinned, isFirst: isFirstRange && i == 0),
          sliver: slivers[i],
        ),
      );
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final hasItems = _itemsByRange.values.any((l) => l.isNotEmpty);

    return BlocProvider(
      create: (_) => MainFeedCubit(
        MainFeedState(currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999)),
        publicMode: true,
      ),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double padding = max(0, (constraints.maxWidth - BreakPoint.desktop.maxWidth) / 2);

            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(pu4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: colors.error)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _load();
                        },
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final appBar = SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: EdgeInsets.symmetric(horizontal: pu3),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Feedteck', style: textTheme.titleSmall?.copyWith(color: colors.onSurfaceVariant)),
                ),
              ),
              leadingWidth: 120,
              title: Text(
                _tab?.name ?? '',
                style: textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                BlocBuilder<IdentityCubit, IdentityState>(
                  bloc: getIt.get<IdentityCubit>(),
                  builder: (context, state) {
                    if (state.isLoggedIn) return const SizedBox.shrink();
                    return TextButton(
                      onPressed: () => AutoRouter.of(context).replaceAll([LandingRoute()]),
                      child: const Text('Anmelden'),
                    );
                  },
                ),
              ],
            );

            if (!hasItems) {
              return CustomScrollView(
                slivers: [
                  appBar,
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Keine Artikel vorhanden',
                        style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              );
            }

            final List<Widget> contentSlivers = [];
            int rangeIndex = 0;
            for (final entry in _itemsByRange.entries) {
              if (entry.value.isEmpty) continue;
              contentSlivers.addAll(
                _buildSliversForRange(
                  context: context,
                  range: entry.key,
                  immutableItems: entry.value,
                  padding: padding,
                  isFirstRange: rangeIndex == 0,
                ),
              );
              rangeIndex++;
            }

            return RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  appBar,
                  ...contentSlivers,
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
