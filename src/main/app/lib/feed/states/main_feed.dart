import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/models/time_block.dart';
import 'package:app/feed/models/time_block_feed.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_feed.freezed.dart';

class MainFeedCubit extends Cubit<MainFeedState> {
  final ScrollController scrollController = ScrollController(initialScrollOffset: -100,keepScrollOffset: false);

  MainFeedCubit(super.initialState) {
    getFeed();
    scrollController.addListener(() {
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.8 && !state.loading) {
        EasyDebounce.debounce('load-feed', Duration(milliseconds: 500), getFeed);
      }
    });
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

    var data = List<FeedItem>.from(await service.getFeed(page: 0, pageSize: 50, from: from.millisecondsSinceEpoch, to: now.millisecondsSinceEpoch).then((value) => value.content));

    // we need to sort the data into the headlines and stuff
    var feed = TimeBlockFeed();

    // the data comes sorted by rank, date desc
    feed.mainHeadline = data.where((element) => element.importance >= 90).firstOrNull;
    if (feed.mainHeadline != null) {
      data.remove(feed.mainHeadline);
    }

    feed.headlines = data.where((element) => element.importance >= 80).take(3).toList();
    feed.headlines.forEach((element) => data.remove(element));

    feed.notableNews = data.where((element) => element.importance >= 60).take(6).toList();
    feed.notableNews.forEach((element) => data.remove(element));

    feed.others = data;

    feed.headlines.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));
    feed.notableNews.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));
    feed.others.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));

    var map = Map<DateTimeRange, TimeBlockFeed>.from(state.items);
    map[key] = feed;

    emit(state.copyWith(loading: false, items: map, currentTime: from));
  }
}

@freezed
sealed class MainFeedState with _$MainFeedState {
  const factory MainFeedState({required DateTime currentTime, @Default(TimeBlock.one_day) TimeBlock timeBlock, @Default(true) bool loading, @Default({}) Map<DateTimeRange, TimeBlockFeed> items}) =
      _MainFeedState;
}
