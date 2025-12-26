import 'package:app/user/models/user.dart';
import 'package:app/user/services/login_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup.freezed.dart';

const String emailRegex =
    r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(super.initialState);

  void setUsername(String? value) {
    emit(state.copyWith(username: value));
  }

  void setPassword(String? value) {
    emit(state.copyWith(password: value));
  }

  void setRepeatPassword(String? value) {
    emit(state.copyWith(repeatPassword: value));
  }

  void setEmail(String? email) {
    emit(state.copyWith(email: email));
  }

  Future<void> signup() async {
    try {
      emit(state.copyWith(loading: true));
      await LoginService(
        serverUrl!,
      ).signup(User(username: state.username, email: state.email, password: state.password));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
      rethrow;
    } finally {
      emit(state.copyWith(loading: false));
    }
  }
}

@freezed
sealed class SignupState with _$SignupState implements WithError {
  @Implements<WithError>()
  const factory SignupState({
    @Default(false) bool loading,
    String? username,
    String? email,
    String? password,
    String? repeatPassword,
    dynamic error,
    StackTrace? stackTrace,
  }) = _SignupState;

  const SignupState._();

  bool get invalidForm =>
      (password ?? '').isEmpty ||
      password != repeatPassword ||
      (username ?? '').isEmpty ||
      (email ?? '').isEmpty ||
      !RegExp(emailRegex).hasMatch(email ?? '');
}
