import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:http/http.dart' as http;

import 'package:app/user/models/user.dart';

class UserService extends BaseService {
  @override
  final String url;

  UserService(this.url);

  Future<User> getUser() async {
    var uri = await formatUrl('/api/users');

    var response = await http.get(uri, headers: await headers);
    processResponse(response);

    Map<String, dynamic> json = jsonDecode(response.body);

    return User.fromJson(json);
  }

  Future<void> updateUser(User user) async {
    var uri = await formatUrl('/api/users');

    var response = await http.post(uri, body: jsonEncode(user), headers: await headers);
    processResponse(response);
  }
}
