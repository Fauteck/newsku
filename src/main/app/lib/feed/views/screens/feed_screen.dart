import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/models/time_block_feed.dart';
import 'package:app/feed/states/main_feed.dart';
import 'package:app/feed/views/components/date_bar.dart';
import 'package:app/feed/views/components/main_headline.dart';
import 'package:app/feed/views/components/notable_news.dart';
import 'package:app/feed/views/components/simple_news.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:material_loading_indicator/loading_indicator.dart';

final articleDateFormat = DateFormat.yMMMMd().add_Hm();
final double feedItemBorderRadius = 8;

@RoutePage()
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  /*
  SliverPersistentHeader getDateHeader(DateTimeRange range, TimeBlock timeBlock) {
    var dateToShow = _df.format(range.end);
    return SliverPersistentHeader(pinned: true, floating: false, delegate: DateBareDelegate(text: dateToShow));
    // return SliverAppBar(pinned: true, snap: false, floating: false, title: Text(dateToShow));
  }
*/

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

  int gridSize(BuildContext context) {
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final breakPoint = BreakPoint.get(context);

    return Center(
      child: BlocProvider(
        create: (context) => MainFeedCubit(MainFeedState(currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999))),
        child: BlocBuilder<MainFeedCubit, MainFeedState>(
          builder: (context, state) {
            var cubit = context.read<MainFeedCubit>();
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: BreakPoint.desktop.maxWidth),
              child: Center(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: .symmetric(horizontal: 16),
                        child: CustomScrollView(
                          controller: cubit.scrollController,
                          slivers: [
                            ...state.items.keys.expand((value) {
                              var feed = state.items[value];
                              if (feed != null) {
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
                                    SliverStickyHeader.builder(
                                      builder: (context, state) => DateBar(date: value.end, isPinned: state.isPinned, isFirst: true),

                                      sliver: headlines,
                                    ),
                                  if (notableNews.isNotEmpty)
                                    SliverStickyHeader.builder(
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
                                  SliverStickyHeader.builder(
                                    builder: (context, state) => DateBar(date: value.end, isPinned: state.isPinned, isFirst: headlines == null && notableNews.isEmpty),
                                    sliver: SliverList.builder(
                                      itemCount: feed.others.length,
                                      itemBuilder: (context, index) => SimpleNews(key: ValueKey(feed.others[index]), item: feed.others[index]),
                                    ),
                                  ),
                                ];
                              } else {
                                return <Widget>[];
                              }
                            }),
                            if (state.loading) SliverToBoxAdapter(child: Center(child: SizedBox(width: 50, height: 50, child: LoadingIndicator()))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
