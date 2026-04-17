import 'dart:convert';

import 'package:app/ai/models/openai_usage.dart';
import 'package:app/base_service.dart';
import 'package:http/http.dart' as http;

class OpenaiUsageService extends BaseService {
  @override
  final String url;

  OpenaiUsageService(this.url);

  /// Fetches current month's usage keyed by use case (RELEVANCE / SHORTENING).
  Future<Map<String, OpenAiUsageStats>> getMonthlyUsage() async {
    final uri = await formatUrl('/api/openai/usage');
    final response = await http.get(uri, headers: await headers);
    processResponse(response);

    return _parse(response.body);
  }

  /// Fetches usage aggregated over an arbitrary [from, to] window
  /// (epoch millis, UTC).
  Future<Map<String, OpenAiUsageStats>> getUsage(int fromMs, int toMs) async {
    final uri = await formatUrl(
      '/api/openai/usage',
      query: {'from': fromMs, 'to': toMs},
    );
    final response = await http.get(uri, headers: await headers);
    processResponse(response);

    return _parse(response.body);
  }

  Map<String, OpenAiUsageStats> _parse(String body) {
    final Map<String, dynamic> json = jsonDecode(body);
    return json.map(
      (key, value) => MapEntry(key, OpenAiUsageStats.fromJson(value as Map<String, Object?>)),
    );
  }
}
