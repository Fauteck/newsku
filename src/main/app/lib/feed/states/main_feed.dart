import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/models/time_block.dart';
import 'package:app/feed/models/time_block_feed.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/utils/utils.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_feed.freezed.dart';

final searchPageSize = 100;

class MainFeedCubit extends Cubit<MainFeedState> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

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
      if (!state.searchMode && scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.95 && !state.loading) {
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
    searchController.dispose();
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

  void setSearch(bool enable) {
    emit(state.copyWith(searchMode: enable, searchPage: 0, searchResults: [], searchTerms: ''));
    searchController.text = '';
    scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeOutQuart);
  }

  Future<void> refresh() async {
    emit(state.copyWith(currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999), items: {}));
    // loading 3 to have a minimum of things to see
    await getFeed();
    await getFeed();
    await getFeed();
  }

  Future<void> search(String value) async {
    emit(state.copyWith(searchPage: 0, searchResults: []));
    EasyDebounce.debounce('search', Duration(milliseconds: 500), () async {
      final results = await FeedService(serverUrl!).search(query: value, page: state.searchPage, pageSize: searchPageSize);
      emit(state.copyWith(searchPage: 0, searchResults: results, searchTerms: value));
    });
  }

  Future<void> loadMoreSearchResults() async {
    final page = state.searchPage + 1;
    final results = await FeedService(serverUrl!).search(query: state.searchTerms, page: page, pageSize: searchPageSize);
    final feeds = List<FeedItem>.from(state.searchResults);
    feeds.addAll(results);
    emit(state.copyWith(searchResults: feeds, searchPage: page));
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
    @Default(false) bool searchMode,
    @Default('') String searchTerms,
    @Default([]) List<FeedItem> searchResults,
    @Default(0) int searchPage,
  }) = _MainFeedState;
}
