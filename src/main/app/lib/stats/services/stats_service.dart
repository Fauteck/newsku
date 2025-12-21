import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:http/http.dart' as http;
import 'package:app/stats/model/stats.dart';

class StatsService extends BaseService {
  @override
  final String url;

  StatsService(this.url);

  Future<Stats> getStats({required int from, required int to}) async {
    var uri = await formatUrl('/api/clicks', query: {'from': from, 'to': to});

    var response = await http.get(uri, headers: await headers);

    processResponse(response);

    Map<String, dynamic> json = jsonDecode(response.body);

    return Stats.fromJson(json);
  }
}
