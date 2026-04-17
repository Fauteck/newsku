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

    final Map<String, dynamic> json = jsonDecode(response.body);
    return json.map(
      (key, value) => MapEntry(key, OpenAiUsageStats.fromJson(value as Map<String, Object?>)),
    );
  }
}
