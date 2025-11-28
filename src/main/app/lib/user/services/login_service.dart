import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:app/user/models/user.dart';
import 'package:http/http.dart' as http;

class LoginService extends BaseService {
  @override
  final String url;

  LoginService(this.url);

  Future<String> login({required String username, required String password}) async {
    var uri = await formatUrl('/login');
    var response = await http.post(uri, body: jsonEncode({'username': username, 'password': password}), headers: await headers);
    processResponse(response, logoutOn401: false);
    return response.body;
  }

  Future<void> signup(User user) async {
    var uri = await formatUrl('/signup');
    var response = await http.put(uri, body: jsonEncode(user), headers: await headers);

    processResponse(response);
  }
}
