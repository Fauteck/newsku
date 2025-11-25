import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/utils/models/pagination.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_feed.freezed.dart';

class MainFeedCubit extends Cubit<MainFeedState> {
  MainFeedCubit(super.initialState) {
    init();
  }

  Future<void> init() async {
    var service = FeedService(getIt.get<IdentityCubit>().state.serverUrl ?? '');

    final now = DateTime.now();
    final from = now.add(Duration(hours: -24));

    var data = await service.getFeed(page: 0, pageSize: 50, from: from.millisecondsSinceEpoch, to: now.millisecondsSinceEpoch);

    emit(state.copyWith(loading: false, items: data));
  }
}

@freezed
sealed class MainFeedState with _$MainFeedState {
  const factory MainFeedState({@Default(Paginated<FeedItem>()) Paginated<FeedItem> items, @Default(true) bool loading}) = _MainFeedState;
}
