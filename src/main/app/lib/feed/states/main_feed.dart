import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/models/time_block.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/services/layout.dart';
import 'package:app/magazine/models/magazine_tab.dart';
import 'package:app/magazine/services/magazine_tab_service.dart';
import 'package:app/main.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'main_feed.freezed.dart';

final searchPageSize = 100;

final _log = Logger('MainFeedCubit');

class MainFeedCubit extends Cubit<MainFeedState> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final List<String> readItems = [];

  // Incremented on every refresh/tab-switch so in-flight responses from a
  // previous request are silently discarded when they arrive late.
  int _requestVersion = 0;
  int _searchVersion = 0;

  MainFeedCubit(super.initialState) {
    init();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // Don't steal keys from text inputs
    if (FocusManager.instance.primaryFocus?.context?.widget is EditableText) return false;

    // When search is active, only handle Escape
    if (state.searchMode) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setSearch(false);
        return true;
      }
      return false;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyR:
        refresh();
        return true;
      case LogicalKeyboardKey.slash:
        setSearch(true);
        return true;
      case LogicalKeyboardKey.keyJ:
      case LogicalKeyboardKey.arrowDown:
        if (scrollController.hasClients) {
          scrollController.animateTo(
            (scrollController.offset + 300).clamp(0.0, scrollController.position.maxScrollExtent),
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
        return true;
      case LogicalKeyboardKey.keyK:
      case LogicalKeyboardKey.arrowUp:
        if (scrollController.hasClients) {
          scrollController.animateTo(
            (scrollController.offset - 300).clamp(0.0, scrollController.position.maxScrollExtent),
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
        return true;
    }
    return false;
  }

  Future<void> init() async {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    scrollController.addListener(() {
      if (!state.hasScrolled && scrollController.position.pixels > 0) {
        emit(state.copyWith(hasScrolled: true));
      } else if (state.hasScrolled && scrollController.position.pixels == 0) {
        emit(state.copyWith(hasScrolled: false));
      }
      if (!state.searchMode &&
          scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.95 &&
          !state.loading) {
        EasyThrottle.throttle('load-feed', Duration(seconds: 1), () {
          if (!state.loading) {
            getFeed();
          }
        });
      }
    });
    refresh();
  }

  @override
  Future<void> close() async {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    scrollController.dispose();
    searchController.dispose();
    super.close();
  }

  void readItem(String? id) {
    if (id == null) {
      return;
    }
    readItems.add(id);

    EasyDebounce.debounce('read-items-update', Duration(seconds: 1), () {
      _log.info('set read status of ${readItems.length} items');
      FeedService(serverUrl!).readItems(List.from(readItems));
      readItems.clear();
    });
  }

  Future<void> toggleSave(String id) async {
    try {
      final updated = await FeedService(serverUrl!).toggleSaved(id);
      // Update the item in all date buckets
      final newItems = state.items.map((range, list) {
        final newList = list.map((item) => item.id == id ? updated : item).toList();
        return MapEntry(range, newList);
      });
      emit(state.copyWith(items: newItems));
    } catch (e, s) {
      _log.severe('Could not toggle save for item $id', e);
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  Future<void> setSavedFilter(bool value) async {
    if (value) {
      try {
        emit(state.copyWith(loading: true, showSavedOnly: true));
        final saved = await FeedService(serverUrl!).getSavedItems();
        final key = DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.now(),
        );
        emit(state.copyWith(loading: false, items: {key: saved}));
      } catch (e, s) {
        emit(state.copyWith(loading: false, showSavedOnly: false, error: e, stackTrace: s));
      }
    } else {
      emit(state.copyWith(showSavedOnly: false));
      refresh();
    }
  }

  Future<void> getFeed() async {
    final version = ++_requestVersion;
    try {
      emit(state.copyWith(loading: true));
      var identityCubit = getIt.get<IdentityCubit>();
      var service = FeedService(identityCubit.state.serverUrl ?? '');

      final now = state.currentTime;
      final from = now.add(-state.timeBlock.duration);

      var key = DateTimeRange(start: from, end: now);

      final activeTab = state.activeTab;
      var data = List<FeedItem>.from(
        await service
            .getFeedItems(
              page: 0,
              pageSize: 999999,
              from: from.millisecondsSinceEpoch,
              to: now.millisecondsSinceEpoch,
              minimumImportance: activeTab?.minimumImportance,
            )
            .then((value) => value.content),
      );

      // Discard stale response if a newer request was started.
      if (version != _requestVersion) return;

      // if required, we sort by read status then by the importance
      if (identityCubit.currentUser?.readItemHandling == .unreadFirstThenDim) {
        data.sort((a, b) {
          final readSort = (a.read == b.read ? 0 : (a.read ? 1 : -1));

          if (readSort == 0) {
            return b.importance.compareTo(a.importance);
          } else {
            return readSort;
          }
        });
      }

      // we need to sort the data into the headlines and stuff
      var map = Map<DateTimeRange, List<FeedItem>>.from(state.items);
      map[key] = data;

      emit(state.copyWith(loading: false, items: map, currentTime: from));
    } catch (e, s) {
      if (version != _requestVersion) return;
      emit(state.copyWith(error: e, stackTrace: s, loading: false));
      rethrow;
    }
  }

  void setSearch(bool enable) {
    emit(state.copyWith(searchMode: enable, searchPage: 0, searchResults: [], searchTerms: ''));
    searchController.text = '';
    scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeOutQuart);
  }

  Future<void> setActiveTab(MagazineTab? tab) async {
    // Invalidate in-flight feed requests for the previous tab.
    _requestVersion++;
    emit(state.copyWith(activeTab: tab, items: {}, currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999)));
    await refresh();
  }

  Future<void> refresh() async {
    // Invalidate any in-flight getFeed() calls from a previous refresh cycle.
    _requestVersion++;
    try {
      emit(state.copyWith(loading: true));
      final activeTab = state.activeTab;
      final Future<List<LayoutBlock>> layoutFuture = activeTab != null
          ? MagazineTabService(serverUrl!).getTabLayout(activeTab.id!)
          : LayoutService(serverUrl!).getLayout();
      final layout = layoutFuture;

      final errorCount = FeedService(serverUrl!).countLast24Hours();

      emit(
        state.copyWith(
          currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
          items: {},
          layout: await layout,
          errorCount: await errorCount,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s, loading: false));
      _log.severe("Error getting layout or error count", e);
      return;
    }

    try {
      // loading 3 to have a minimum of things to see
      await getFeed();
      await getFeed();
      await getFeed();
    } catch (e) {
      _log.severe('Couldn\'t refresh feed', e);
    }
  }

  Future<void> search(String value) async {
    final version = ++_searchVersion;
    emit(state.copyWith(searchPage: 0, searchResults: []));
    EasyDebounce.debounce('search', Duration(milliseconds: 500), () async {
      try {
        final results = await FeedService(
          serverUrl!,
        ).search(query: value, page: state.searchPage, pageSize: searchPageSize);
        if (version != _searchVersion) return;
        emit(state.copyWith(searchPage: 0, searchResults: results, searchTerms: value));
      } catch (e, s) {
        if (version != _searchVersion) return;
        emit(state.copyWith(error: e, stackTrace: s));
      }
    });
  }

  Future<void> loadMoreSearchResults() async {
    try {
      emit(state.copyWith(loading: true));
      final page = state.searchPage + 1;
      final results = await FeedService(
        serverUrl!,
      ).search(query: state.searchTerms, page: page, pageSize: searchPageSize);
      final feeds = List<FeedItem>.from(state.searchResults);
      feeds.addAll(results);
      emit(state.copyWith(searchResults: feeds, searchPage: page, loading: false));
    } catch (e, s) {
      emit(state.copyWith(loading: false, error: e, stackTrace: s));
    }
  }
}

@freezed
sealed class MainFeedState with _$MainFeedState implements WithError {
  @Implements<WithError>()
  const factory MainFeedState({
    @Default(false) bool hasScrolled,
    required DateTime currentTime,
    @Default(TimeBlock.one_day) TimeBlock timeBlock,
    @Default(true) bool loading,
    @Default({}) Map<DateTimeRange, List<FeedItem>> items,
    @Default(false) bool searchMode,
    @Default('') String searchTerms,
    @Default([]) List<FeedItem> searchResults,
    @Default(0) int searchPage,
    @Default([]) List<LayoutBlock> layout,
    @Default(0) int errorCount,
    @Default(false) bool showSavedOnly,
    MagazineTab? activeTab,
    dynamic error,
    StackTrace? stackTrace,
  }) = _MainFeedState;
}
