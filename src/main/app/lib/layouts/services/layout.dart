import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:http/http.dart' as http;

class LayoutService extends BaseService {
  @override
  final String url;

  const LayoutService(this.url);

  Future<List<LayoutBlock>> getLayout() async {
    final uri = await formatUrl('/api/layout');

    final response = await http.get(uri, headers: await headers);

    processResponse(response);

    Iterable i = jsonDecode(response.body) as Iterable;

    return i.map((e) => LayoutBlock.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LayoutBlock>> setLayout(List<LayoutBlock> blocks) async {
    final uri = await formatUrl('/api/layout');

    final response = await http.put(uri, headers: await headers, body: jsonEncode(blocks));

    processResponse(response);

    Iterable i = jsonDecode(response.body) as Iterable;

    return i.map((e) => LayoutBlock.fromJson(e as Map<String, dynamic>)).toList();
  }
}
