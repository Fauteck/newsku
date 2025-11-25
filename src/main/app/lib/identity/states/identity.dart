import 'package:app/config/models/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

part 'identity.freezed.dart';

class IdentityCubit extends Cubit<IdentityState> {
  IdentityCubit(super.initialState);

  bool get isLoggedIn {
    return state.serverUrl != null && state.token != null && !JwtDecoder.isExpired(state.token ?? '');
  }

  Future<void> init() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var server = prefs.getString('server');

    emit(state.copyWith(serverUrl: server, token: token));
  }

  void setUrl(String? serverUrl, {Config? config}) {
    emit(state.copyWith(serverUrl: serverUrl, config: config));
  }

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('server');
    emit(state.copyWith(serverUrl: null, token: null));
  }

  Future<void> setToken(String token) async {
    emit(state.copyWith(token: token));
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('server', state.serverUrl!);
  }
}

@freezed
sealed class IdentityState with _$IdentityState {
  const factory IdentityState({String? token, String? serverUrl, Config? config}) = _IdentityState;
}
