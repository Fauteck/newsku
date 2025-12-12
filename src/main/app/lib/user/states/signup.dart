import 'package:app/user/models/user.dart';
import 'package:app/user/services/login_service.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup.freezed.dart';

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
    await LoginService(serverUrl!).signup(User(username: state.username, email: state.email, password: state.password));
  }
}

@freezed
sealed class SignupState with _$SignupState {
  const factory SignupState({
    @Default(false) bool loading,
    String? username,
    String? email,
    String? password,
    String? repeatPassword,
  }) = _SignupState;

  const SignupState._();

  bool get invalidForm =>
      (password ?? '').isEmpty || password != repeatPassword || (username ?? '').isEmpty || (email ?? '').isEmpty;
}
