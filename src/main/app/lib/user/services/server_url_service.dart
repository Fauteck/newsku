import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:app/config/models/config.dart';
import 'package:http/http.dart' as http;

class ServerUrlService extends BaseService {
  @override
  final String url;

  ServerUrlService(this.url);

  Future<Config> getConfig() async {
    var uri = await formatUrl("/config");
    var response = await http.get(uri);

    processResponse(response);
    Map<String, dynamic> json = jsonDecode(response.body);

    return Config.fromJson(json);
  }
}
