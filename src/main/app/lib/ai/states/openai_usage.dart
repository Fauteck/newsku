import 'package:app/ai/models/openai_usage.dart';
import 'package:app/ai/services/openai_usage_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'openai_usage.freezed.dart';

class OpenaiUsageCubit extends Cubit<OpenaiUsageState> {
  OpenaiUsageCubit(super.initialState) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      emit(state.copyWith(loading: true));
      final stats = await OpenaiUsageService(serverUrl!).getMonthlyUsage();
      emit(state.copyWith(
        relevance: stats['RELEVANCE'],
        shortening: stats['SHORTENING'],
        loading: false,
      ));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s, loading: false));
    }
  }
}

@freezed
sealed class OpenaiUsageState with _$OpenaiUsageState implements WithError {
  @Implements<WithError>()
  const factory OpenaiUsageState({
    OpenAiUsageStats? relevance,
    OpenAiUsageStats? shortening,
    @Default(false) bool loading,
    dynamic error,
    StackTrace? stackTrace,
  }) = _OpenaiUsageState;
}
