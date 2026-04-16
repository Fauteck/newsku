// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_block_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LayoutBlockSettings _$LayoutBlockSettingsFromJson(Map<String, dynamic> json) => _LayoutBlockSettings(
  title: json['title'] as String?,
  items: (json['items'] as num?)?.toInt(),
  categoryId: json['categoryId'] as String?,
  aiPromptId: json['aiPromptId'] as String?,
  lastBlockShowAll: json['lastBlockShowAll'] as bool? ?? true,
);

Map<String, dynamic> _$LayoutBlockSettingsToJson(_LayoutBlockSettings instance) => <String, dynamic>{
  'title': instance.title,
  'items': instance.items,
  'categoryId': instance.categoryId,
  'aiPromptId': instance.aiPromptId,
  'lastBlockShowAll': instance.lastBlockShowAll,
};
