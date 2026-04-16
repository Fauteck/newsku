import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassicFeedState {
  final List<FeedItem> items;
  final bool loading;
  final bool hasMore;
  final int page;
  final dynamic error;

  const ClassicFeedState({
    this.items = const [],
    this.loading = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  ClassicFeedState copyWith({
    List<FeedItem>? items,
    bool? loading,
    bool? hasMore,
    int? page,
    dynamic error,
  }) {
    return ClassicFeedState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}

class ClassicFeedCubit extends Cubit<ClassicFeedState> {
  final ScrollController scrollController = ScrollController();
  static const int _pageSize = 50;

  ClassicFeedCubit() : super(const ClassicFeedState()) {
    loadItems();
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }

  Future<void> refresh() async {
    emit(const ClassicFeedState(loading: true));
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
      );

      final newItems = page == 0 ? result.content : [...state.items, ...result.content];
      emit(ClassicFeedState(
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
