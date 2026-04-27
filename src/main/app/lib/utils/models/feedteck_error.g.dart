// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedteck_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedteckError _$FeedteckErrorFromJson(Map<String, dynamic> json) => _FeedteckError(
  type: $enumDecode(_$ErrorTypeEnumMap, json['type']),
  uuid: json['uuid'] as String?,
  message: json['message'] as String? ?? "",
);

Map<String, dynamic> _$FeedteckErrorToJson(_FeedteckError instance) => <String, dynamic>{
  'type': _$ErrorTypeEnumMap[instance.type]!,
  'uuid': instance.uuid,
  'message': instance.message,
};

const _$ErrorTypeEnumMap = {
  ErrorType.NewskuUserException: 'NewskuUserException',
  ErrorType.NewskuException: 'NewskuException',
};
