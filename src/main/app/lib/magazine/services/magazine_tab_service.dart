import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:app/feed/models/feed_item.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/magazine/models/magazine_tab.dart';
import 'package:http/http.dart' as http;

const int _publicMaxPageSize = 2000;

class MagazineTabService extends BaseService {
  @override
  final String url;

  const MagazineTabService(this.url);

  Future<List<MagazineTab>> getTabs() async {
    final uri = await formatUrl('/api/magazine/tabs');
    final response = await http.get(uri, headers: await headers);
    processResponse(response);
    final Iterable list = jsonDecode(response.body);
    return list.map((e) => MagazineTab.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MagazineTab> createTab(MagazineTab tab) async {
    final uri = await formatUrl('/api/magazine/tabs');
    final response = await http.post(uri, headers: await headers, body: jsonEncode(tab));
    processResponse(response);
    return MagazineTab.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<MagazineTab> updateTab(MagazineTab tab) async {
    final uri = await formatUrl('/api/magazine/tabs/${tab.id}');
    final response = await http.put(uri, headers: await headers, body: jsonEncode(tab));
    processResponse(response);
    return MagazineTab.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteTab(String id) async {
    final uri = await formatUrl('/api/magazine/tabs/$id');
    final response = await http.delete(uri, headers: await headers);
    processResponse(response);
  }

  Future<List<LayoutBlock>> getTabLayout(String tabId) async {
    final uri = await formatUrl('/api/magazine/tabs/$tabId/layout');
    final response = await http.get(uri, headers: await headers);
    processResponse(response);
    final Iterable list = jsonDecode(response.body);
    return list.map((e) => LayoutBlock.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LayoutBlock>> setTabLayout(String tabId, List<LayoutBlock> blocks) async {
    final uri = await formatUrl('/api/magazine/tabs/$tabId/layout');
    final response = await http.put(uri, headers: await headers, body: jsonEncode(blocks));
    processResponse(response);
    final Iterable list = jsonDecode(response.body);
    return list.map((e) => LayoutBlock.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class PublicMagazineService extends BaseService {
  @override
  final String url;

  const PublicMagazineService(this.url);

  Future<MagazineTab> getTab(String tabId) async {
    final uri = await formatUrl('/api/public/magazine/$tabId');
    final response = await http.get(uri, headers: await headers);
    processResponse(response, logoutOn401: false);
    return MagazineTab.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<LayoutBlock>> getTabLayout(String tabId) async {
    final uri = await formatUrl('/api/public/magazine/$tabId/layout');
    final response = await http.get(uri, headers: await headers);
    processResponse(response, logoutOn401: false);
    final Iterable list = jsonDecode(response.body);
    return list.map((e) => LayoutBlock.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FeedItem>> getItems(
    String tabId, {
    int page = 0,
    int pageSize = _publicMaxPageSize,
    int? from,
    int? to,
  }) async {
    final query = <String, dynamic>{'page': page.toString(), 'pageSize': pageSize.toString()};
    if (from != null) query['from'] = from.toString();
    if (to != null) query['to'] = to.toString();
    final uri = await formatUrl('/api/public/magazine/$tabId/items', query: query);
    final response = await http.get(uri, headers: await headers);
    processResponse(response, logoutOn401: false);
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final Iterable list = map['content'] as List;
    return list.map((e) => FeedItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
