import 'package:app/config/models/oidc_config.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/user/services/login_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oidc/oidc.dart';
import 'package:logging/logging.dart';

part 'login.freezed.dart';

final _log = Logger('LoginCubit');

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

  Future<String?> oidcLogin(OidcConfig config) async {
    final manager = await _setupClient(config);

    OidcProviderMetadata? override;

    // PKCE handling
    if (kIsWeb) {
      final sha256 = OidcConstants_AuthorizeRequest_CodeChallengeMethod.s256;
      override = manager.discoveryDocument.copyWith(codeChallengeMethodsSupported: [sha256]);
    }

    final user = await manager.loginAuthorizationCodeFlow(discoveryDocumentOverride: override);

    return user?.token.accessToken;
  }

  Future<String> logInWithOidc() async {
    try {
      var config = getIt.get<IdentityCubit>().state.config;
      if (config?.oidcConfig != null) {
        final accessToken = await oidcLogin(config!.oidcConfig!);

        if (accessToken != null) {
          final token = await LoginService(serverUrl).loginWithOidcToken(accessToken);

          // emit(state.copyWith(loginError: ''));

          // usernamePasswordCubit.setToken(url, token);

          return token;
        }
      }
      throw Error();
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
      // emit(state.copyWith(loginError: e.toString().replaceFirst("Exception: ", '')));
      rethrow;
    }
  }

  Future<OidcUserManager> _setupClient(OidcConfig config) async {
    try {
      _log.fine("Setting oidc client");

      var basePort = Uri.base.port;

      String webUrl = kIsWeb ? '${Uri.base.scheme}://${Uri.base.host}${basePort != 80 && basePort != 443 ? ':$basePort' : ''}/redirect.html' : '';

      _log.fine(config);
      var redirectUri = kIsWeb
          // this url must be an actual html page.
          // see the file in /web/redirect.html for an example.
          //
          // for debugging in flutter, you must run this app with --web-port 22433
          ? Uri.parse(webUrl)
          : Uri.parse('com.github.lamarios.newsku:/oidcRedirect');
      final manager = OidcUserManager.lazy(
        discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(Uri.parse(config.issuer)),
        clientCredentials: OidcClientAuthentication.none(clientId: config.clientId),
        store: OidcMemoryStore(),
        settings: OidcUserManagerSettings(
          postLogoutRedirectUri: redirectUri,
          frontChannelLogoutUri: Uri(path: webUrl).replace(queryParameters: {...redirectUri.queryParameters, 'requestType': 'front-channel-logout'}),
          scope: ["openid", 'profile', 'email'],
          redirectUri: redirectUri,
          options: OidcPlatformSpecificOptions(web: OidcPlatformSpecificOptions_Web(broadcastChannel: 'oidc_flutter_web/redirect')),
        ),
      );

      await manager.init();
      return manager;
    } catch (e) {
      _log.severe(e);
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
sealed class LoginState with _$LoginState implements WithError {
  @Implements<WithError>()
  const factory LoginState({@Default(false) bool loading, @Default(false) bool failedLogin, @Default("") String username, @Default("") String password, dynamic error, StackTrace? stackTrace}) =
      _LoginState;
}
