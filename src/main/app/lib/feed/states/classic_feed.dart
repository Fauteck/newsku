import 'package:app/feed/models/feed.dart';
import 'package:app/feed/models/feed_category.dart';
import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ClassicFeedSort { chronological, importance }

class ClassicFeedState {
  final List<FeedItem> items;
  final bool loading;
  final bool hasMore;
  final int page;
  final dynamic error;
  final ClassicFeedSort sort;
  final String? feedId;
  final String? categoryId;
  final List<Feed> feeds;
  final List<FeedCategory> categories;

  const ClassicFeedState({
    this.items = const [],
    this.loading = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
    this.sort = ClassicFeedSort.chronological,
    this.feedId,
    this.categoryId,
    this.feeds = const [],
    this.categories = const [],
  });

  ClassicFeedState copyWith({
    List<FeedItem>? items,
    bool? loading,
    bool? hasMore,
    int? page,
    dynamic error,
    ClassicFeedSort? sort,
    String? feedId,
    String? categoryId,
    bool clearFeedId = false,
    bool clearCategoryId = false,
    List<Feed>? feeds,
    List<FeedCategory>? categories,
  }) {
    return ClassicFeedState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error ?? this.error,
      sort: sort ?? this.sort,
      feedId: clearFeedId ? null : (feedId ?? this.feedId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      feeds: feeds ?? this.feeds,
      categories: categories ?? this.categories,
    );
  }
}

class ClassicFeedCubit extends Cubit<ClassicFeedState> {
  final ScrollController scrollController = ScrollController();
  static const int _pageSize = 50;

  ClassicFeedCubit() : super(const ClassicFeedState()) {
    _loadFilters();
    loadItems();
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }

  Future<void> _loadFilters() async {
    try {
      final service = FeedService(serverUrl!);
      final feeds = await service.getFeeds();
      final categories = await service.getFeedCategories();
      emit(state.copyWith(feeds: feeds, categories: categories));
    } catch (_) {
      // silently ignore; filters stay empty, items still load
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(loading: true, items: [], page: 0, hasMore: true));
    await _fetchPage(0);
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    emit(state.copyWith(loading: true));
    await _fetchPage(state.page + 1);
  }

  Future<void> loadItems() async {
    emit(state.copyWith(loading: true));
    await _fetchPage(0);
  }

  void setSort(ClassicFeedSort sort) {
    if (sort == state.sort) return;
    emit(state.copyWith(sort: sort, items: [], page: 0, hasMore: true));
    loadItems();
  }

  void setCategoryFilter(String? categoryId) {
    if (categoryId == state.categoryId) return;
    emit(state.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      feedId: null,
      clearFeedId: true,
      items: [],
      page: 0,
      hasMore: true,
    ));
    loadItems();
  }

  void setFeedFilter(String? feedId) {
    if (feedId == state.feedId) return;
    emit(state.copyWith(
      feedId: feedId,
      clearFeedId: feedId == null,
      items: [],
      page: 0,
      hasMore: true,
    ));
    loadItems();
  }

  Future<void> _fetchPage(int page) async {
    try {
      final service = FeedService(serverUrl!);
      final now = DateTime.now().millisecondsSinceEpoch;
      final from = DateTime.now().subtract(const Duration(days: 90)).millisecondsSinceEpoch;

      final result = await service.getFeedItems(
        page: page,
        pageSize: _pageSize,
        from: from,
        to: now,
        minimumImportance: 0,
        sort: state.sort == ClassicFeedSort.chronological ? 'chronological' : 'importance',
        feedId: state.feedId,
        categoryId: state.categoryId,
      );

      final newItems = page == 0 ? result.content : [...state.items, ...result.content];
      emit(state.copyWith(
        items: newItems,
        loading: false,
        hasMore: page + 1 < result.totalPages,
        page: page,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e));
    }
  }
}
