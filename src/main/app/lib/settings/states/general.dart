import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/user/models/read_item_handling.dart';
import 'package:app/user/models/user.dart';
import 'package:app/user/services/user_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'general.freezed.dart';

class GeneralSettingsCubit extends Cubit<GeneralSettingsState> {
  final TextEditingController preferenceController = TextEditingController(text: '');
  final TextEditingController openAiApiKeyController = TextEditingController(text: '');
  final TextEditingController openAiModelController = TextEditingController(text: '');
  final TextEditingController openAiUrlController = TextEditingController(text: '');

  GeneralSettingsCubit(super.initialState) {
    getUser();
  }

  @override
  Future<void> close() async {
    preferenceController.dispose();
    openAiApiKeyController.dispose();
    openAiModelController.dispose();
    openAiUrlController.dispose();
    super.close();
  }

  Future<void> getUser() async {
    try {
      emit(state.copyWith(loading: true));
      final user = await UserService(serverUrl!).getUser();
      preferenceController.text = user.feedItemPreference ?? '';
      openAiApiKeyController.text = user.openAiApiKey ?? '';
      openAiModelController.text = user.openAiModel ?? 'gpt-4o-mini';
      openAiUrlController.text = user.openAiUrl ?? 'https://api.openai.com/v1';
      emit(state.copyWith(user: user));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> updateUser() async {
    try {
      emit(state.copyWith(loading: true));
      await UserService(serverUrl!).updateUser(state.user!);
      await getIt.get<IdentityCubit>().getUser();
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> setReadItemPreference(ReadItemHandling? pref) async {
    if (state.user != null && pref != null) {
      emit(state.copyWith.user!(readItemHandling: pref));
      await updateUser();
    }
  }

  Future<void> setAiPreferences() async {
    if (state.user != null) {
      emit(state.copyWith.user!(feedItemPreference: preferenceController.value.text));
      await updateUser();
    }
  }

  Future<void> setAndSaveImportance(double importance) async {
    if (state.user != null) {
      emit(state.copyWith.user!(minimumImportance: importance.toInt()));
      EasyDebounce.debounce('importance update', Duration(milliseconds: 250), updateUser);
    }
  }

  Future<void> saveOpenAiSettings() async {
    if (state.user != null) {
      final apiKey = openAiApiKeyController.value.text.trim();
      final model = openAiModelController.value.text.trim();
      final url = openAiUrlController.value.text.trim();
      emit(state.copyWith.user!(
        openAiApiKey: apiKey.isNotEmpty ? apiKey : null,
        openAiModel: model.isNotEmpty ? model : null,
        openAiUrl: url.isNotEmpty ? url : null,
      ));
      await updateUser();
    }
  }

  Future<void> updateAiPromptId(String? promptId) async {
    if (state.user == null) return;
    emit(state.copyWith(user: state.user!.copyWith(aiPromptId: promptId)));
    EasyDebounce.debounce('ai-prompt-id-update', Duration(milliseconds: 500), updateUser);
  }
}

@freezed
sealed class GeneralSettingsState with _$GeneralSettingsState implements WithError {
  @Implements<WithError>()
  const factory GeneralSettingsState({
    User? user,
    @Default(true) bool loading,
    dynamic error,
    StackTrace? stackTrace,
    @Default('') String password,
    @Default('') String repeatPassword,
  }) = _GeneralSettingsState;
}
