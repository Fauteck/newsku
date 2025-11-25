import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:http/http.dart' as http;

class LoginService extends BaseService {
  @override
  final String url;

  LoginService(this.url);

  Future<String> login({required String username, required String password}) async {
    var uri = await formatUrl('/login');
    var response = await http.post(uri, body: jsonEncode({'username': username, 'password': password}), headers: await headers);
    processResponse(response);
    return response.body;
  }
}
