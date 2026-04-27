enum SyncStatus { neverRun, running, success, partial, failed }

SyncStatus _parseStatus(String? raw) {
  switch (raw) {
    case 'NEVER_RUN':
      return SyncStatus.neverRun;
    case 'RUNNING':
      return SyncStatus.running;
    case 'SUCCESS':
      return SyncStatus.success;
    case 'PARTIAL':
      return SyncStatus.partial;
    case 'FAILED':
      return SyncStatus.failed;
    default:
      return SyncStatus.neverRun;
  }
}

class SyncStatusResponse {
  final int? lastSyncTime;
  final SyncStatus status;
  final String? errorMessage;
  final int? itemsAdded;
  final int? itemsUpdated;

  const SyncStatusResponse({
    this.lastSyncTime,
    this.status = SyncStatus.neverRun,
    this.errorMessage,
    this.itemsAdded,
    this.itemsUpdated,
  });

  bool get isTerminal =>
      status == SyncStatus.success ||
      status == SyncStatus.partial ||
      status == SyncStatus.failed;

  factory SyncStatusResponse.fromJson(Map<String, dynamic> json) {
    return SyncStatusResponse(
      lastSyncTime: json['lastSyncTime'] as int?,
      status: _parseStatus(json['status'] as String?),
      errorMessage: json['errorMessage'] as String?,
      itemsAdded: json['itemsAdded'] as int?,
      itemsUpdated: json['itemsUpdated'] as int?,
    );
  }
}
