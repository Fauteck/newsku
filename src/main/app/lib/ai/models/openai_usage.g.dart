// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OpenAiUsageStats _$OpenAiUsageStatsFromJson(Map<String, dynamic> json) => _OpenAiUsageStats(
  useCase: json['useCase'] as String,
  totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
  promptTokens: (json['promptTokens'] as num?)?.toInt() ?? 0,
  completionTokens: (json['completionTokens'] as num?)?.toInt() ?? 0,
  estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble(),
  callCount: (json['callCount'] as num?)?.toInt() ?? 0,
  monthlyLimit: (json['monthlyLimit'] as num?)?.toInt(),
);

Map<String, dynamic> _$OpenAiUsageStatsToJson(_OpenAiUsageStats instance) => <String, dynamic>{
  'useCase': instance.useCase,
  'totalTokens': instance.totalTokens,
  'promptTokens': instance.promptTokens,
  'completionTokens': instance.completionTokens,
  'estimatedCostUsd': instance.estimatedCostUsd,
  'callCount': instance.callCount,
  'monthlyLimit': instance.monthlyLimit,
};
