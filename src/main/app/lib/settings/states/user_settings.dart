import 'package:app/user/models/email_digest_frequency.dart';
import 'package:app/user/models/user.dart';
import 'package:app/user/services/user_service.dart';
import 'package:app/user/states/signup.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';

class UserSettingsCubit extends Cubit<UserSettingsState> {
  final TextEditingController password = TextEditingController(text: '');
  final TextEditingController repeatPassword = TextEditingController(text: '');
  late final TextEditingController email;
  late final TextEditingController gReaderUsername;
  late final TextEditingController gReaderApiPassword;
  late final TextEditingController gReaderUrl;

  UserSettingsCubit(super.initialState) {
    email = TextEditingController(text: state.email);
    gReaderUsername = TextEditingController(text: state.gReaderUsername);
    gReaderApiPassword = TextEditingController(text: '');
    gReaderUrl = TextEditingController(text: identityCubit.currentUser?.gReaderUrl ?? '');

    password.addListener(() => emit(state.copyWith(password: password.value.text.trim())));
    repeatPassword.addListener(() => emit(state.copyWith(repeatPassword: repeatPassword.value.text.trim())));
    email.addListener(() => emit(state.copyWith(email: email.value.text.trim())));
    gReaderUsername.addListener(() => emit(state.copyWith(gReaderUsername: gReaderUsername.value.text.trim())));
  }

  @override
  Future<void> close() {
    password.dispose();
    repeatPassword.dispose();
    email.dispose();
    gReaderUsername.dispose();
    gReaderApiPassword.dispose();
    gReaderUrl.dispose();
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

  Future<void> updateEmail() async {
    var user = identityCubit.currentUser;
    if (user != null) {
      user = user.copyWith(email: email.value.text.trim());
      await updateUser(user);
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

  Future<void> updateGReaderCredentials() async {
    var user = identityCubit.currentUser;
    if (user != null) {
      final apiPassword = gReaderApiPassword.value.text;
      final url = gReaderUrl.value.text.trim();
      user = user.copyWith(
        gReaderUsername: gReaderUsername.value.text.trim(),
        gReaderApiPassword: apiPassword.isNotEmpty ? apiPassword : null,
        gReaderUrl: url.isNotEmpty ? url : null,
      );
      await updateUser(user);
      gReaderApiPassword.text = '';
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
    @Default("") String email,
    @Default([]) List<EmailDigestFrequency> digest,
    @Default("") String gReaderUsername,
    dynamic error,
    StackTrace? stackTrace,
  }) = _UserSettingsState;

  const UserSettingsState._();

  bool get validEmail => RegExp(emailRegex).hasMatch(email);
}
