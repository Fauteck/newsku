import 'package:app/ai/models/ai_prompt.dart';
import 'package:app/ai/services/ai_prompt_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_prompts.freezed.dart';

class AiPromptsCubit extends Cubit<AiPromptsState> {
  AiPromptsCubit(super.initialState) {
    loadPrompts();
  }

  Future<void> loadPrompts() async {
    try {
      emit(state.copyWith(loading: true));
      final prompts = await AiPromptService(serverUrl!).getPrompts();
      emit(state.copyWith(prompts: prompts, loading: false));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s, loading: false));
    }
  }

  Future<AiPrompt?> createPrompt(String name, String content) async {
    try {
      final prompt = AiPrompt(name: name, content: content);
      final created = await AiPromptService(serverUrl!).createPrompt(prompt);
      emit(state.copyWith(prompts: [...state.prompts, created]));
      return created;
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
      return null;
    }
  }

  Future<void> updatePrompt(AiPrompt prompt) async {
    try {
      final updated = await AiPromptService(serverUrl!).updatePrompt(prompt);
      final newPrompts = state.prompts.map((p) => p.id == updated.id ? updated : p).toList();
      emit(state.copyWith(prompts: newPrompts));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  Future<void> deletePrompt(AiPrompt prompt) async {
    if (prompt.id == null) return;
    try {
      await AiPromptService(serverUrl!).deletePrompt(prompt.id!);
      final newPrompts = state.prompts.where((p) => p.id != prompt.id).toList();
      emit(state.copyWith(prompts: newPrompts));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }
}

@freezed
sealed class AiPromptsState with _$AiPromptsState implements WithError {
  @Implements<WithError>()
  const factory AiPromptsState({
    @Default([]) List<AiPrompt> prompts,
    @Default(false) bool loading,
    dynamic error,
    StackTrace? stackTrace,
  }) = _AiPromptsState;
}
