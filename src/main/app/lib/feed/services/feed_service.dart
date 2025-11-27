import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:app/feed/models/feed.dart';
import 'package:app/feed/models/feed_item.dart';
import 'package:app/utils/models/pagination.dart';
import 'package:http/http.dart' as http;

class FeedService extends BaseService {
  final String url;

  const FeedService(this.url);

  Future<void> deleteFeed(String id) async {
    var uri = await formatUrl('/api/feeds/$id');

    var response = await http.delete(uri, headers: await headers);
    processResponse(response);
  }

  Future<List<Feed>> getFeeds() async {
    var uri = await formatUrl('/api/feeds');

    var response = await http.get(uri, headers: await headers);

    processResponse(response);

    Iterable i = jsonDecode(response.body);

    return i.map((e) => Feed.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Feed> addFeed(String url) async {
    var uri = await formatUrl('/api/feeds');

    var response = await http.put(uri, headers: await headers, body: url);

    processResponse(response);

    Map<String, dynamic> feed = jsonDecode(response.body);

    return Feed.fromJson(feed);
  }

  Future<Paginated<FeedItem>> getFeedItems({required int page, required int pageSize, required int from, required int to}) async {
    var uri = await formatUrl('/api/feeds/items', query: {'page': page, 'pageSize': pageSize, 'from': from, 'to': to});

    var response = await http.get(uri, headers: await headers);

    processResponse(response);

    Map<String, dynamic> json = jsonDecode(response.body);

    return Paginated<FeedItem>.fromJson(json, (feedItem) => FeedItem.fromJson(feedItem as Map<String, dynamic>));
  }
}
