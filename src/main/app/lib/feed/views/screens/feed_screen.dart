import 'dart:ui';

import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/states/main_feed.dart';
import 'package:app/feed/views/components/date_bar.dart';
import 'package:app/feed/views/components/search_result.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/user/views/components/fancy_side.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/app_logo.dart';
import 'package:app/utils/views/components/app_name.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:material_loading_indicator/loading_indicator.dart';
import 'package:motor/motor.dart';

final articleDateFormat = DateFormat.Hm();
final double feedItemBorderRadius = 8;

final _log = Logger('FeedScreen');

@RoutePage()
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  List<Widget> buildSlivers({required BuildContext context, required DateTimeRange<DateTime> timeRange, required List<FeedItem> immutableItems, required List<LayoutBlock> blocks}) {
    List<Widget> slivers = [];
    _log.fine('Building Slivers, TimeRange: $timeRange, Layout blocks: ${blocks.length}, Items: ${immutableItems.length}');

    List<FeedItem> items = List.from(immutableItems);

    // for each block, we try to fit items
    for (final (index, block) in blocks.indexed) {
      if (items.isEmpty) {
        break;
      }

      List<FeedItem> blockItems = [];
      if (index == blocks.length - 1) {
        // if we're in the last block, we take all items
        blockItems = List.from(items);
      } else {
        int blockSize = block.type.fixedItemSize ?? block.settings?.items ?? 0;
        _log.fine('${block.type}: Block Size: $blockSize');
        // we take the items the block is expecting
        blockItems.addAll(items.take(blockSize).toList());
      }
      _log.fine('Block item: ${blockItems.length}');

      slivers.add(block.type.getSliver(context: context, items: blockItems, block: block));

      // we remove them from the main list
      for (var element in blockItems) {
        items.remove(element);
      }
    }

    for (int i = 0; i < slivers.length; i++) {
      slivers[i] = SliverPadding(
        padding: .symmetric(horizontal: 16),
        sliver: SliverStickyHeader.builder(
          builder: (context, state) => DateBar(date: timeRange.end, isPinned: state.isPinned, isFirst: i == 0),

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

    return BlocProvider(
      create: (context) => MainFeedCubit(MainFeedState(currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999))),
      child: ErrorHandler<MainFeedCubit, MainFeedState>(
        child: BlocBuilder<MainFeedCubit, MainFeedState>(
          builder: (context, state) {
            var cubit = context.read<MainFeedCubit>();
            return Center(
              child: Stack(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: BreakPoint.desktop.maxWidth),
                    child: Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: .symmetric(horizontal: 0),
                              child: RefreshIndicator(
                                onRefresh: () => cubit.refresh(),
                                child: CustomScrollView(
                                  controller: cubit.scrollController,
                                  slivers: [
                                    SliverAppBar(
                                      floating: true,
                                      snap: true,
                                      elevation: 0,
                                      scrolledUnderElevation: 0,
                                      leadingWidth: 150,
                                      title: AnimatedCrossFade(
                                        firstChild: AppName(style: textTheme.titleLarge),
                                        secondChild: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: cubit.searchController,
                                                autofocus: true,
                                                onChanged: (value) => cubit.search(value),
                                                decoration: InputDecoration(border: UnderlineInputBorder(), label: Text('Search')),
                                              ),
                                            ),
                                          ],
                                        ),
                                        crossFadeState: state.searchMode ? .showSecond : .showFirst,
                                        duration: Duration(milliseconds: 250),
                                      ),
                                      leading: ClipPath(
                                        clipper: FancySide(),
                                        child: Container(
                                          decoration: BoxDecoration(color: seedColor),
                                          child: Padding(
                                            padding: .only(left: 24),
                                            child: Align(
                                              alignment: .centerLeft,
                                              child: AppLogo(color: colors.onSurface, size: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        IconButton(onPressed: () => cubit.setSearch(!state.searchMode), icon: Icon(state.searchMode ? Icons.close : Icons.search)),
                                        if (!state.searchMode) IconButton(onPressed: () => cubit.refresh(), icon: Icon(Icons.refresh)),
                                        if (!(context.read<IdentityCubit>().state.config?.demoMode ?? false))
                                          IconButton(onPressed: () => AutoRouter.of(context).push(SettingsRoute()).then((value) => cubit.refresh()), icon: Icon(Icons.settings)),
                                      ],
                                    ),
                                    if (state.searchMode)
                                      SliverList.builder(
                                        itemCount: state.searchResults.length,
                                        itemBuilder: (context, index) {
                                          return SearchResult(key: ValueKey(state.searchResults[index]), item: state.searchResults[index]);
                                        },
                                      )
                                    else
                                      ...state.items.keys.expand((value) {
                                        var feed = state.items[value];
                                        if (feed != null && feed.isNotEmpty) {
                                          return buildSlivers(context: context, timeRange: value, immutableItems: feed, blocks: state.layout);
                                        } else {
                                          return [
                                            SliverStickyHeader.builder(
                                              builder: (context, state) => DateBar(date: value.end, isPinned: state.isPinned, isFirst: true),
                                              sliver: SliverToBoxAdapter(
                                                child: SizedBox(
                                                  height: 500,
                                                  child: Column(
                                                    mainAxisAlignment: .center,
                                                    spacing: 24,
                                                    children: [
                                                      Icon(Icons.newspaper, size: 50, color: colors.onSurface),
                                                      Text('No news', style: textTheme.titleLarge),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ];
                                        }
                                      }),
                                    if (state.loading)
                                      SliverToBoxAdapter(
                                        child: Center(child: SizedBox(width: 50, height: 50, child: LoadingIndicator())),
                                      )
                                    else if (!state.searchMode || (state.searchMode && state.searchResults.length == searchPageSize * (state.searchPage + 1)))
                                      SliverToBoxAdapter(
                                        child: Center(
                                          child: FilledButton.tonalIcon(
                                            onPressed: () => state.searchMode ? cubit.loadMoreSearchResults() : cubit.getFeed(),
                                            label: Text('Load more'),
                                            icon: Icon(Icons.expand_more),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleMotionBuilder(
                    motion: MaterialSpringMotion.expressiveSpatialDefault(),
                    from: 0,
                    value: state.hasScrolled ? 1 : 0,
                    builder: (context, value, child) => Positioned(
                      right: 30,
                      bottom: lerpDouble(-100, 30, value),
                      child: Opacity(opacity: value.clamp(0, 1), child: child!),
                    ),
                    child: FloatingActionButton(
                      onPressed: () => cubit.scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuart),
                      child: Icon(Icons.arrow_upward),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
