import 'package:app/stats/model/stats.dart';
import 'package:app/stats/services/stats_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_state.freezed.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit(super.initialState) {
    getStats();
  }

  Future<void> getStats() async {
    try {
      emit(state.copyWith(loading: true));
      var now = DateTime.now();
      var from = now.add(Duration(days: -30));
      var stats = await StatsService(
        serverUrl!,
      ).getStats(from: from.millisecondsSinceEpoch, to: now.millisecondsSinceEpoch);
      emit(state.copyWith(loading: false, stats: stats));
    } catch (e, s) {
      emit(state.copyWith(loading: false, error: e, stackTrace: s));
    }
  }
}

@freezed
sealed class StatsState with _$StatsState implements WithError {
  @Implements<WithError>()
  const factory StatsState({
    @Default(Stats()) Stats stats,
    dynamic error,
    StackTrace? stackTrace,
    @Default(true) bool loading,
  }) = _StatsState;
}
