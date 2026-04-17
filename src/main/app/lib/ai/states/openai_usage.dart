import 'package:app/ai/models/openai_usage.dart';
import 'package:app/ai/services/openai_usage_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'openai_usage.freezed.dart';

enum UsagePeriod { day, week, month }

class OpenaiUsageCubit extends Cubit<OpenaiUsageState> {
  OpenaiUsageCubit(super.initialState) {
    refresh();
  }

  Future<void> refresh() => _load(state.period);

  Future<void> setPeriod(UsagePeriod period) {
    if (period == state.period) return Future.value();
    emit(state.copyWith(period: period));
    return _load(period);
  }

  Future<void> _load(UsagePeriod period) async {
    try {
      emit(state.copyWith(loading: true));
      final window = _windowFor(period);
      final stats = await OpenaiUsageService(serverUrl!).getUsage(window[0], window[1]);
      emit(state.copyWith(
        relevance: stats['RELEVANCE'],
        shortening: stats['SHORTENING'],
        loading: false,
      ));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s, loading: false));
    }
  }

  /// UTC window [fromMs, toMs) matching the selected period.
  static List<int> _windowFor(UsagePeriod period) {
    final now = DateTime.now().toUtc();
    late DateTime start;
    late DateTime end;
    switch (period) {
      case UsagePeriod.day:
        start = DateTime.utc(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;
      case UsagePeriod.week:
        // ISO week: Monday is the first day. weekday: Mon=1..Sun=7.
        final startOfToday = DateTime.utc(now.year, now.month, now.day);
        start = startOfToday.subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 7));
        break;
      case UsagePeriod.month:
        start = DateTime.utc(now.year, now.month, 1);
        end = DateTime.utc(now.year, now.month + 1, 1);
        break;
    }
    return [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch];
  }
}

@freezed
sealed class OpenaiUsageState with _$OpenaiUsageState implements WithError {
  @Implements<WithError>()
  const factory OpenaiUsageState({
    OpenAiUsageStats? relevance,
    OpenAiUsageStats? shortening,
    @Default(false) bool loading,
    @Default(UsagePeriod.month) UsagePeriod period,
    dynamic error,
    StackTrace? stackTrace,
  }) = _OpenaiUsageState;
}
