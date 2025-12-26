// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsku_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NewskuError _$NewskuErrorFromJson(Map<String, dynamic> json) => _NewskuError(
  type: $enumDecode(_$ErrorTypeEnumMap, json['type']),
  uuid: json['uuid'] as String?,
  message: json['message'] as String? ?? "",
);

Map<String, dynamic> _$NewskuErrorToJson(_NewskuError instance) => <String, dynamic>{
  'type': _$ErrorTypeEnumMap[instance.type]!,
  'uuid': instance.uuid,
  'message': instance.message,
};

const _$ErrorTypeEnumMap = {
  ErrorType.NewskuUserException: 'NewskuUserException',
  ErrorType.NewskuException: 'NewskuException',
};
