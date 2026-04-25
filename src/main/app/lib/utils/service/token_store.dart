import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure token storage.
///
/// On native platforms (Android/iOS/Desktop) uses flutter_secure_storage
/// (Keystore / Keychain / libsecret). On web SharedPreferences is used
/// because flutter_secure_storage on web relies on sessionStorage which
/// would break cross-session persistence.
class TokenStore {
  static const _tokenKey = 'token';
  static const _serverKey = 'server';

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> readToken() async {
    if (kIsWeb) {
      return (await SharedPreferences.getInstance()).getString(_tokenKey);
    }
    final value = await _secure.read(key: _tokenKey);
    if (value != null) return value;
    // One-time migration from SharedPreferences
    final legacy = (await SharedPreferences.getInstance()).getString(_tokenKey);
    if (legacy != null) {
      await _secure.write(key: _tokenKey, value: legacy);
      await (await SharedPreferences.getInstance()).remove(_tokenKey);
    }
    return legacy;
  }

  Future<void> writeToken(String token) async {
    if (kIsWeb) {
      await (await SharedPreferences.getInstance()).setString(_tokenKey, token);
    } else {
      await _secure.write(key: _tokenKey, value: token);
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      await (await SharedPreferences.getInstance()).remove(_tokenKey);
    } else {
      await _secure.delete(key: _tokenKey);
    }
  }

  Future<String?> readServer() async {
    return (await SharedPreferences.getInstance()).getString(_serverKey);
  }

  Future<void> writeServer(String server) async {
    await (await SharedPreferences.getInstance()).setString(_serverKey, server);
  }

  Future<void> deleteServer() async {
    await (await SharedPreferences.getInstance()).remove(_serverKey);
  }
}
