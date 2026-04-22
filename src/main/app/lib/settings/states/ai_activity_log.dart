import 'package:app/ai/models/openai_usage_log_entry.dart';
import 'package:app/ai/services/openai_usage_service.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiActivityLogState {
  final bool loading;
  final List<OpenaiUsageLogEntry> entries;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final dynamic error;

  const AiActivityLogState({
    this.loading = true,
    this.entries = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalElements = 0,
    this.error,
  });

  AiActivityLogState copyWith({
    bool? loading,
    List<OpenaiUsageLogEntry>? entries,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    dynamic error,
  }) {
    return AiActivityLogState(
      loading: loading ?? this.loading,
      entries: entries ?? this.entries,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      error: error ?? this.error,
    );
  }

  bool get hasMore => currentPage < totalPages - 1;
}

class AiActivityLogCubit extends Cubit<AiActivityLogState> {
  static const int _pageSize = 50;

  AiActivityLogCubit() : super(const AiActivityLogState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final result = await OpenaiUsageService(serverUrl!).getLog(page: 0, size: _pageSize);
      emit(AiActivityLogState(
        loading: false,
        entries: result.entries,
        currentPage: 0,
        totalPages: result.totalPages,
        totalElements: result.totalElements,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loading) return;
    emit(state.copyWith(loading: true));
    try {
      final nextPage = state.currentPage + 1;
      final result = await OpenaiUsageService(serverUrl!).getLog(page: nextPage, size: _pageSize);
      emit(state.copyWith(
        loading: false,
        entries: [...state.entries, ...result.entries],
        currentPage: nextPage,
        totalPages: result.totalPages,
        totalElements: result.totalElements,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e));
    }
  }
}
