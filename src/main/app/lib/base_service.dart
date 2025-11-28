import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as Preferences;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('BaseService');

abstract class BaseService {
  String get url;

  const BaseService();

  Future<String?> get token async {
    var token = (await SharedPreferences.getInstance()).getString('token');

    return token;
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
        value.forEach((element) => formattedQuery.add('$key=${element.toString()}'));
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

  void _processStatusCode(int statusCode, {bool logoutOn401 = true, String? body}) {
    switch (statusCode) {
      case 200:
        return;
      case 401:
        if (logoutOn401) {
          getIt.get<IdentityCubit>().logout();
        }
        throw Exception("Couldn't execute request, unauthorized}");
      default:
        throw Exception("Couldn't execute request ${statusCode} -> ${body}");
    }
  }
}
