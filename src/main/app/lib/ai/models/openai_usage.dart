import 'package:freezed_annotation/freezed_annotation.dart';

part 'openai_usage.freezed.dart';

part 'openai_usage.g.dart';

@freezed
sealed class OpenAiUsageStats with _$OpenAiUsageStats {
  const factory OpenAiUsageStats({
    required String useCase,
    @Default(0) int totalTokens,
    @Default(0) int promptTokens,
    @Default(0) int completionTokens,
    double? estimatedCostUsd,
    @Default(0) int callCount,
    int? monthlyLimit,
  }) = _OpenAiUsageStats;

  factory OpenAiUsageStats.fromJson(Map<String, Object?> json) =>
      _$OpenAiUsageStatsFromJson(json);
}
