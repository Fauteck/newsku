// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magazine_tab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MagazineTab _$MagazineTabFromJson(Map<String, dynamic> json) => _MagazineTab(
  id: json['id'] as String?,
  name: json['name'] as String,
  displayOrder: (json['displayOrder'] as num).toInt(),
  isPublic: json['isPublic'] as bool? ?? false,
  aiPreference: json['aiPreference'] as String?,
  aiPromptId: json['aiPromptId'] as String?,
  minimumImportance: (json['minimumImportance'] as num?)?.toInt(),
);

Map<String, dynamic> _$MagazineTabToJson(_MagazineTab instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'displayOrder': instance.displayOrder,
  'isPublic': instance.isPublic,
  'aiPreference': instance.aiPreference,
  'aiPromptId': instance.aiPromptId,
  'minimumImportance': instance.minimumImportance,
};
