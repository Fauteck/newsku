import 'dart:convert';

import 'package:app/ai/models/ai_prompt.dart';
import 'package:app/base_service.dart';
import 'package:http/http.dart' as http;

class AiPromptService extends BaseService {
  @override
  final String url;

  const AiPromptService(this.url);

  Future<List<AiPrompt>> getPrompts() async {
    final uri = await formatUrl('/api/ai/prompts');
    final response = await http.get(uri, headers: await headers);
    processResponse(response);
    final Iterable list = jsonDecode(response.body);
    return list.map((e) => AiPrompt.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AiPrompt> createPrompt(AiPrompt prompt) async {
    final uri = await formatUrl('/api/ai/prompts');
    final response = await http.post(uri, headers: await headers, body: jsonEncode(prompt));
    processResponse(response);
    return AiPrompt.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AiPrompt> updatePrompt(AiPrompt prompt) async {
    final uri = await formatUrl('/api/ai/prompts/${prompt.id}');
    final response = await http.put(uri, headers: await headers, body: jsonEncode(prompt));
    processResponse(response);
    return AiPrompt.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deletePrompt(String id) async {
    final uri = await formatUrl('/api/ai/prompts/$id');
    final response = await http.delete(uri, headers: await headers);
    processResponse(response);
  }
}
