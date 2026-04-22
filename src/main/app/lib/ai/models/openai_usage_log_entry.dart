class OpenaiUsageLogEntry {
  final String id;
  final String useCase;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final double? estimatedCostUsd;
  final DateTime createdAt;

  const OpenaiUsageLogEntry({
    required this.id,
    required this.useCase,
    required this.model,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.estimatedCostUsd,
    required this.createdAt,
  });

  factory OpenaiUsageLogEntry.fromJson(Map<String, dynamic> json) {
    return OpenaiUsageLogEntry(
      id: json['id'] as String,
      useCase: json['useCase'] as String? ?? '',
      model: json['model'] as String? ?? '',
      promptTokens: json['promptTokens'] as int? ?? 0,
      completionTokens: json['completionTokens'] as int? ?? 0,
      totalTokens: json['totalTokens'] as int? ?? 0,
      estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }
}
