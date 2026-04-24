import 'package:app/config/models/config.dart';
import 'package:app/user/models/user.dart';
import 'package:app/user/services/server_url_service.dart';
import 'package:app/user/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

part 'identity.freezed.dart';

final _log = Logger('IdentityCubit');

class IdentityCubit extends Cubit<IdentityState> {
  IdentityCubit(super.initialState);

  bool get isLoggedIn {
    return state.serverUrl != null && state.token != null && !JwtDecoder.isExpired(state.token ?? '');
  }

  Future<void> init() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var server = prefs.getString('server');

    if (kIsWeb && !kDebugMode) {
      Uri base = Uri.base;
      server = '${base.scheme}://${base.host}';

      if (base.port != 80 && base.port != 443) {
        server += ':${base.port}';
      }
    }

    Config? serverConfig;
    if (server != null) {
      try {
        serverConfig = await ServerUrlService(server).getConfig();
      } catch (e) {
        server = null;
        token = null;
        _log.severe('Failed to log config from server, logging out', e);
      }
    }

    User? user;
    if (token != null && server != null) {
      user = await UserService(server).getUser();
    }

    emit(state.copyWith(serverUrl: server, token: token, config: serverConfig, currentUser: user));
  }

  void setUrl(String? serverUrl, {Config? config}) {
    emit(state.copyWith(serverUrl: serverUrl, config: config));
  }

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    var removeServer = !kIsWeb || kDebugMode;
    if (removeServer) {
      prefs.remove('server');
    }
    emit(state.copyWith(serverUrl: removeServer ? null : state.serverUrl, token: null));
  }

  Future<void> setToken(String token) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('server', state.serverUrl!);

    User? user;
    if (state.serverUrl != null) {
      user = await UserService(state.serverUrl!).getUser();
    }

    emit(state.copyWith(token: token, currentUser: user));
  }

  Future<void> getUser() async {
    if (isLoggedIn) {
      final user = await UserService(state.serverUrl!).getUser();
      emit(state.copyWith(currentUser: user));
    }
  }

  User? get currentUser => state.currentUser;
}

@freezed
sealed class IdentityState with _$IdentityState {
  const factory IdentityState({String? token, String? serverUrl, Config? config, User? currentUser}) = _IdentityState;

  const IdentityState._();

  bool get isLoggedIn {
    return serverUrl != null && token != null && !JwtDecoder.isExpired(token ?? '');
  }
}
