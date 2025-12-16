import 'package:app/feed/models/feed.dart';
import 'package:app/feed/models/feed_error.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/utils/models/pagination.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_errors.freezed.dart';

class FeedErrorsCubit extends Cubit<FeedErrorsState> {
  final int pageSize = 50;
  final Feed feed;

  FeedErrorsCubit(super.initialState, {required this.feed}) {
    init();
  }

  Future<void> init() async {
    final errors = await getErrors(0);
    emit(state.copyWith(errors: errors));
  }

  Future<Paginated<FeedError>> getErrors(int page) async {
    emit(state.copyWith(loading: true));
    try {
      return await FeedService(serverUrl!).getErrors(feedId: feed.id!, page: page, pageSize: pageSize);
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
      rethrow;
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> switchPage(int page) async {
    final errors = await getErrors(page);
    emit(state.copyWith(page: page, errors: errors));
  }
}

@freezed
sealed class FeedErrorsState with _$FeedErrorsState implements WithError {
  @Implements<WithError>()
  const factory FeedErrorsState({
    @Default(0) int page,
    @Default(true) bool loading,
    dynamic error,
    StackTrace? stackTrace,
    @Default(Paginated()) Paginated<FeedError> errors,
  }) = _FeedErrorsState;
}
