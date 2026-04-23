import 'dart:convert';

import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/utils/models/newsku_error.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

final _log = Logger('BaseService');
const _secureStorage = FlutterSecureStorage();

abstract class BaseService {
  String get url;

  const BaseService();

  Future<String?> get token async {
    return _secureStorage.read(key: 'token');
  }

  Future<Map<String, String>> get headers async {
    var headers = {'Content-Type': 'application/json'};

    var token = await this.token;
    if (token != null) {
      token = "Bearer $token";
      headers['Authorization'] = token;
    }

    return headers;
  }

  Future<Uri> formatUrl(String url, {Map<String, dynamic>? query, List<String>? params}) async {
    final serverUrl = this.url;

    if (serverUrl.isEmpty) {
      getIt.get<IdentityCubit>().logout();
      throw Exception("No server url, going back to login screen");
    }

    url = serverUrl + url;

    params ??= [];
    query ??= {};

    params.asMap().forEach((key, value) {
      url = url.replaceFirst('{$key}', value);
    });

    List<String> formattedQuery = [];
    query.forEach((key, value) {
      if (value is List) {
        for (var element in value) {
          formattedQuery.add('$key=${element.toString()}');
        }
      } else {
        formattedQuery.add('$key=${value.toString()}');
      }
    });

    if (formattedQuery.isNotEmpty) {
      url += '?${formattedQuery.join("&")}';
    }

    _log.fine("Calling $url");
    return Uri.parse(url);
  }

  void processResponse(Response response, {bool logoutOn401 = true}) {
    _processStatusCode(response.statusCode, body: response.body, logoutOn401: logoutOn401);
  }

  void _processNewskuError(String? body) {
    if (body == null) {
      return;
    }
    late NewskuError error;
    try {
      error = NewskuError.fromJson(jsonDecode(body));
    } catch (e) {
      _log.fine("Not a Newsku error");
      return;
    }
    throw error;
  }

  void _processStatusCode(int statusCode, {bool logoutOn401 = true, String? body}) {
    switch (statusCode) {
      case 200:
        return;
      case 401:
        if (logoutOn401) {
          getIt.get<IdentityCubit>().logout();
        }
        _processNewskuError(body);
        throw Exception("Couldn't execute request, unauthorized}");
      default:
        _processNewskuError(body);
        throw Exception("Couldn't execute request $statusCode -> $body");
    }
  }
}
