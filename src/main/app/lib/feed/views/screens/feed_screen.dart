import 'dart:ui';

import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/models/time_block_feed.dart';
import 'package:app/feed/states/main_feed.dart';
import 'package:app/feed/views/components/date_bar.dart';
import 'package:app/feed/views/components/main_headline.dart';
import 'package:app/feed/views/components/notable_news.dart';
import 'package:app/feed/views/components/search_result.dart';
import 'package:app/feed/views/components/simple_news.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/user/views/components/fancy_side.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/app_logo.dart';
import 'package:app/utils/views/components/app_name.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:material_loading_indicator/loading_indicator.dart';
import 'package:motor/motor.dart';

final articleDateFormat = DateFormat.yMMMMd().add_Hm();
final double feedItemBorderRadius = 8;

@RoutePage()
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  SliverList? getHeadlines(TimeBlockFeed timeBlockFeed) {
    if (timeBlockFeed.headLineListCount > 0) {
      return SliverList.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return MainHeadline(feed: timeBlockFeed);
        },
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final breakPoint = BreakPoint.get(context);

    return Center(
      child: BlocProvider(
        create: (context) => MainFeedCubit(MainFeedState(currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999))),
        child: ErrorHandler<MainFeedCubit, MainFeedState>(
          child: BlocBuilder<MainFeedCubit, MainFeedState>(
            builder: (context, state) {
              var cubit = context.read<MainFeedCubit>();
              return Stack(
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
                                        firstChild: AppName(style: textTheme.titleLarge,),
                                        secondChild: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(controller: cubit.searchController, autofocus: true, onChanged: (value) => cubit.search(value), decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
                                                label: Text('Search')
                                              ),),
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
                                            child: Align(alignment: .centerLeft, child: AppLogo(color: colors.onSurface,size: 20,)),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        IconButton(onPressed: () => cubit.setSearch(!state.searchMode), icon: Icon(state.searchMode ? Icons.close : Icons.search)),
                                        if(!state.searchMode)IconButton(onPressed: () => cubit.refresh(), icon: Icon(Icons.refresh)),
                                        IconButton(onPressed: () => AutoRouter.of(context).push(SettingsRoute()).then((value) => cubit.refresh(),), icon: Icon(Icons.settings)),
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
                                        if (feed != null && feed.itemCount > 0) {
                                          var headlines = breakPoint != .mobile ? getHeadlines(feed) : null;

                                          var notableNews = List<FeedItem>.from(feed.notableNews);

                                          // on mobile, there's no real estate to build nice headlines so we put all as notable news
                                          if (breakPoint == .mobile) {
                                            notableNews.insertAll(0, feed.headlines.reversed.toList());

                                            if (feed.mainHeadline != null) {
                                              notableNews.insert(0, feed.mainHeadline!);
                                            }
                                          }

                                          return [
                                            // getDateHeader(value, state.timeBlock),
                                            if (headlines != null)
                                              SliverPadding(
                                                padding: .symmetric(horizontal: 16),
                                                sliver: SliverStickyHeader.builder(
                                                  builder: (context, state) => DateBar(date: value.end, isPinned: state.isPinned, isFirst: true),

                                                  sliver: headlines,
                                                ),
                                              ),
                                            if (notableNews.isNotEmpty)
                                              SliverPadding(
                                                padding: .only(left: 16, right: 16, top: headlines != null ? 64 : 0),
                                                sliver: SliverStickyHeader.builder(
                                                  builder: (context, state) => DateBar(date: value.end, isPinned: state.isPinned, isFirst: headlines == null),
                                                  sliver: SliverGrid.builder(
                                                    itemCount: notableNews.length,
                                                    itemBuilder: (context, index) => NotableNews(key: ValueKey(notableNews[index]), item: notableNews[index]),
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: switch (breakPoint) {
                                                        .mobile => 1,
                                                        .tablet => 2,
                                                        _ => 3,
                                                      },
                                                      crossAxisSpacing: 16,
                                                      mainAxisSpacing: 16,
                                                      mainAxisExtent: 450,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (feed.others.isNotEmpty) ...[
                                              SliverPadding(
                                                padding: .only(left: 16, right: 16, top: 64),
                                                sliver: SliverStickyHeader.builder(
                                                  builder: (context, state) => DateBar(date: value.end, isPinned: state.isPinned, isFirst: headlines == null && notableNews.isEmpty),
                                                  sliver: SliverGrid.builder(
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: switch (breakPoint) {
                                                        .mobile => 1,
                                                        _ => 2,
                                                      },
                                                      mainAxisExtent: 120,
                                                      mainAxisSpacing: 16,
                                                      crossAxisSpacing: 16,
                                                    ),
                                                    itemCount: feed.others.length,
                                                    itemBuilder: (context, index) => SimpleNews(key: ValueKey(feed.others[index]), item: feed.others[index]),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ];
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
                                    else if(!state.searchMode || (state.searchMode && state.searchResults.length == searchPageSize * (state.searchPage+1)) )
                                      SliverToBoxAdapter(
                                        child: Center(
                                          child: FilledButton.tonalIcon(onPressed: () => state.searchMode ? cubit.loadMoreSearchResults() : cubit.getFeed(), label: Text('Load more'), icon: Icon(Icons.expand_more)),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
