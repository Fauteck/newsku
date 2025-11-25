import 'package:app/user/services/login_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  final String serverUrl;

  LoginCubit(super.initialState, {required this.serverUrl});

  Future<String> login() async {
    try {
      return await LoginService(serverUrl).login(username: state.username, password: state.password);
    } catch (e) {
      emit(state.copyWith(failedLogin: true));
      rethrow;
    }
  }

  void setUser(String value) {
    emit(state.copyWith(username: value));
  }

  void setPassword(String value) {
    emit(state.copyWith(password: value));
  }
}

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState({@Default(false) bool loading, @Default(false) bool failedLogin, @Default("") String username, @Default("") String password}) = _LoginState;
}
