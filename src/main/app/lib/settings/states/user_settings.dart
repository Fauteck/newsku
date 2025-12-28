import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/user/models/email_digest_frequency.dart';
import 'package:app/user/models/user.dart';
import 'package:app/user/services/user_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';

class UserSettingsCubit extends Cubit<UserSettingsState> {
  final TextEditingController password = TextEditingController(text: '');
  final TextEditingController repeatPassword = TextEditingController(text: '');

  UserSettingsCubit(super.initialState) {
    password.addListener(() => emit(state.copyWith(password: password.value.text)));
    repeatPassword.addListener(() => emit(state.copyWith(repeatPassword: repeatPassword.value.text)));
  }

  @override
  Future<void> close() {
    password.dispose();
    repeatPassword.dispose();
    return super.close();
  }

  Future<void> updateUser(User user) async {
    try {
      emit(state.copyWith(loading: true));
      await UserService(serverUrl!).updateUser(user);
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> resetPassword() async {
    var user = identityCubit.currentUser;
    if (user != null) {
      user = user.copyWith(password: password.value.text);
      await updateUser(user);
      emit(state.copyWith(password: '', repeatPassword: ''));
      repeatPassword.text = '';
      password.text = '';
    }
  }

  Future<void> setDigestPreference(List<EmailDigestFrequency> list) async {
    var user = identityCubit.currentUser;
    if (user != null) {
      emit(state.copyWith(digest: list));
      user = user.copyWith(emailDigest: list);
      await updateUser(user);
    }
  }
}

@freezed
sealed class UserSettingsState with _$UserSettingsState implements WithError {
  @Implements<WithError>()
  const factory UserSettingsState({
    @Default(false) bool loading,
    @Default("") String password,
    @Default("") String repeatPassword,
    @Default([]) List<EmailDigestFrequency> digest,
    dynamic error,
    StackTrace? stackTrace,
  }) = _UserSettingsState;
}
