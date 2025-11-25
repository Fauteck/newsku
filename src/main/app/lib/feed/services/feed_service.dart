import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:app/feed/models/feed_item.dart';
import 'package:app/utils/models/pagination.dart';
import 'package:http/http.dart' as http;

class FeedService extends BaseService {
  final String url;

  FeedService(this.url);

  Future<Paginated<FeedItem>> getFeed({required int page, required int pageSize, required int from, required int to}) async {
    var uri = await formatUrl('/api/feeds/items', query: {'page': page, 'pageSize': pageSize, 'from': from, 'to': to});

    var response = await http.get(uri, headers: await headers);

    processResponse(response);

    Map<String, dynamic> json = jsonDecode(response.body);

    return Paginated<FeedItem>.fromJson(json, (feedItem) => FeedItem.fromJson(feedItem as Map<String, dynamic>));
  }
}
