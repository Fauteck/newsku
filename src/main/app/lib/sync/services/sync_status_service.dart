import 'dart:convert';

import 'package:app/base_service.dart';
import 'package:app/sync/models/sync_status_response.dart';
import 'package:http/http.dart' as http;

class SyncStatusService extends BaseService {
  @override
  final String url;

  const SyncStatusService(this.url);

  Future<SyncStatusResponse> getStatus() async {
    var uri = await formatUrl('/api/sync-status');
    var response = await http.get(uri, headers: await headers);
    processResponse(response);
    return SyncStatusResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
