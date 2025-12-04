// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LayoutBlock _$LayoutBlockFromJson(Map<String, dynamic> json) => _LayoutBlock(
  id: json['id'] as String?,
  type: $enumDecode(_$LayoutBlockTypesEnumMap, json['type']),
  order: (json['order'] as num).toInt(),
  settings: json['settings'] == null
      ? null
      : LayoutBlockSettings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LayoutBlockToJson(_LayoutBlock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$LayoutBlockTypesEnumMap[instance.type]!,
      'order': instance.order,
      'settings': instance.settings,
    };

const _$LayoutBlockTypesEnumMap = {
  LayoutBlockTypes.bigHeadline: 'bigHeadline',
  LayoutBlockTypes.topStories: 'topStories',
  LayoutBlockTypes.bigGrid: 'bigGrid',
  LayoutBlockTypes.smallGrid: 'smallGrid',
};
