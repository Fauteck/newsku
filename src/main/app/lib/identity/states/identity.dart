import 'package:app/config/models/config.dart';
import 'package:app/user/services/server_url_service.dart';
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
      }catch(e){
        server = null;
        token = null;
        _log.severe('Failed to log config from server, logging out',e);
      }
    }

    emit(state.copyWith(serverUrl: server, token: token, config: serverConfig));
  }

  void setUrl(String? serverUrl, {Config? config}) {
    emit(state.copyWith(serverUrl: serverUrl, config: config));
  }

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    if(!kIsWeb || kDebugMode ) {
      prefs.remove('server');
    }
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

  const IdentityState._();

  bool get isLoggedIn {
    return serverUrl != null && token != null && !JwtDecoder.isExpired(token ?? '');
  }
}
