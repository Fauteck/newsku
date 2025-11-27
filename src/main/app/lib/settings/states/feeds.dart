import 'package:app/feed/models/feed.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/utils/utils.dart';
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
    emit(state.copyWith(loading: true));
    var feeds = await FeedService(serverUrl!).getFeeds();
    emit(state.copyWith(loading: false, feeds: feeds));
  }

  Future<void> addFeed() async {
    emit(state.copyWith(loading: true));
    final url = newFeedController.value.text;
    await FeedService(serverUrl!).addFeed(url);
    newFeedController.text = '';
    getFeeds();
  }

  Future<void> deleteFeed(Feed f) async {
    emit(state.copyWith(loading: true));
    await FeedService(serverUrl!).deleteFeed(f.id!);

    getFeeds();
  }
}

@freezed
sealed class FeedsSettingsState with _$FeedsSettingsState {
  const factory FeedsSettingsState({@Default([]) List<Feed> feeds, @Default(true) bool loading}) = _FeedsSettingsState;
}
