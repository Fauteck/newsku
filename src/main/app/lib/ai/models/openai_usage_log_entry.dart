class OpenaiUsageLogEntry {
  final String id;
  final String useCase;
  final String model;
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final double? estimatedCostUsd;
  final DateTime createdAt;
  final String status;
  final String? errorMessage;
  final int? durationMs;

  const OpenaiUsageLogEntry({
    required this.id,
    required this.useCase,
    required this.model,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.estimatedCostUsd,
    required this.createdAt,
    this.status = 'OK',
    this.errorMessage,
    this.durationMs,
  });

  bool get isError => status == 'ERROR';

  factory OpenaiUsageLogEntry.fromJson(Map<String, dynamic> json) {
    return OpenaiUsageLogEntry(
      id: json['id'] as String,
      useCase: json['useCase'] as String? ?? '',
      model: json['model'] as String? ?? '',
      promptTokens: json['promptTokens'] as int?,
      completionTokens: json['completionTokens'] as int?,
      totalTokens: json['totalTokens'] as int?,
      estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      status: json['status'] as String? ?? 'OK',
      errorMessage: json['errorMessage'] as String?,
      durationMs: json['durationMs'] as int?,
    );
  }
}
