import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/models/time_block.dart';
import 'package:app/feed/models/time_block_feed.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_feed.freezed.dart';

class MainFeedCubit extends Cubit<MainFeedState> {
  final ScrollController scrollController = ScrollController();

  MainFeedCubit(super.initialState) {
    init();
  }

  Future<void> init() async {
    scrollController.addListener(() {
      if (!state.hasScrolled && scrollController.position.pixels > 0) {
        emit(state.copyWith(hasScrolled: true));
      } else if (state.hasScrolled && scrollController.position.pixels == 0) {
        emit(state.copyWith(hasScrolled: false));
      }
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.95 && !state.loading) {
        EasyThrottle.throttle('load-feed', Duration(seconds: 1), () {
          if (!state.loading) {
            getFeed();
          }
        });
      }
    });
    getFeed();
  }

  @override
  Future<void> close() async {
    scrollController.dispose();
    super.close();
  }

  Future<void> getFeed() async {
    emit(state.copyWith(loading: true));
    var service = FeedService(getIt.get<IdentityCubit>().state.serverUrl ?? '');

    final now = state.currentTime;
    final from = now.add(-state.timeBlock.duration);

    var key = DateTimeRange(start: from, end: now);

    var data = List<FeedItem>.from(await service.getFeedItems(page: 0, pageSize: 50, from: from.millisecondsSinceEpoch, to: now.millisecondsSinceEpoch).then((value) => value.content));

    // we need to sort the data into the headlines and stuff
    var feed = TimeBlockFeed();

    if (data.isNotEmpty) {
      // the data comes sorted by rank, date desc
      feed.mainHeadline = data.removeAt(0);
    }

    // 3 headlines
    for (var i = 0; i < 3; i++) {
      if (data.isNotEmpty) {
        feed.headlines.add(data.removeAt(0));
      }
    }

    // 6 notable news
    for (var i = 0; i < 6; i++) {
      if (data.isNotEmpty) {
        feed.notableNews.add(data.removeAt(0));
      }
    }

    feed.others = data;

    var map = Map<DateTimeRange, TimeBlockFeed>.from(state.items);
    map[key] = feed;

    emit(state.copyWith(loading: false, items: map, currentTime: from));
  }

  Future<void> refresh() async {
    emit(state.copyWith(currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999), items: {}));
    // loading 3 to have a minimum of things to see
    await getFeed();
    await getFeed();
    await getFeed();
  }
}

@freezed
sealed class MainFeedState with _$MainFeedState {
  const factory MainFeedState({
    @Default(false) bool hasScrolled,
    required DateTime currentTime,
    @Default(TimeBlock.one_day) TimeBlock timeBlock,
    @Default(true) bool loading,
    @Default({}) Map<DateTimeRange, TimeBlockFeed> items,
  }) = _MainFeedState;
}
