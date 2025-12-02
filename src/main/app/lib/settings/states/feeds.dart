import 'dart:typed_data';

import 'package:app/feed/models/feed.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feeds.freezed.dart';

class FeedsSettingsCubit extends Cubit<FeedsSettingsState> {
  final TextEditingController newFeedController = TextEditingController();

  FeedsSettingsCubit(super.initialState) {
    getFeeds();
  }

  Future<void> getFeeds() async {
    try {
      emit(state.copyWith(loading: true));
      var feeds = await FeedService(serverUrl!).getFeeds();
      emit(state.copyWith(loading: false, feeds: feeds));
    } catch (e, s) {
      emit(state.copyWith(loading: false, error: e, stackTrace: s));
    }
  }

  Future<void> addFeed() async {
    try {
      emit(state.copyWith(loading: true));
      final url = newFeedController.value.text;
      await FeedService(serverUrl!).addFeed(url);
      newFeedController.text = '';
      getFeeds();
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  Future<void> deleteFeed(Feed f) async {
    try {
      emit(state.copyWith(loading: true));
      await FeedService(serverUrl!).deleteFeed(f.id!);

      getFeeds();
    } catch (e, s) {
      emit(state.copyWith(loading: false, error: e, stackTrace: s));
    }
  }

  Future<List<Feed>> importFeeds(Uint8List? bytes) async {
    if (bytes != null) {
      try {
        emit(state.copyWith(loading: true));

        var feeds = await FeedService(serverUrl!).importFeeds(bytes);

        getFeeds();

        return feeds;
      } catch (e, s) {
        emit(state.copyWith(error: e, stackTrace: s, loading: false));
        rethrow;
      }
    } else {
      return [];
    }
  }

  Future<void> exportFeed() async {
    var service = FeedService(serverUrl!);
    var feeds = await service.exportFeeds();
    FileSaver.instance.saveFile(name: 'feeds.opml', bytes: feeds);
  }
}

@freezed
sealed class FeedsSettingsState with _$FeedsSettingsState implements WithError {
  @Implements<WithError>()
  const factory FeedsSettingsState({@Default([]) List<Feed> feeds, @Default(true) bool loading, dynamic error, StackTrace? stackTrace}) = _FeedsSettingsState;
}
