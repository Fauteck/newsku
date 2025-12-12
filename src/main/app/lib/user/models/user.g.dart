// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String?,
  username: json['username'] as String?,
  password: json['password'] as String?,
  email: json['email'] as String?,
  feedItemPreference: json['feedItemPreference'] as String?,
  oidcSub: json['oidcSub'] as String?,
  minimumImportance: (json['minimumImportance'] as num?)?.toInt() ?? 0,
  firstTimeSetupDone: json['firstTimeSetupDone'] as bool? ?? false,
  readItemHandling: $enumDecodeNullable(_$ReadItemHandlingEnumMap, json['readItemHandling']) ?? ReadItemHandling.none,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'password': instance.password,
  'email': instance.email,
  'feedItemPreference': instance.feedItemPreference,
  'oidcSub': instance.oidcSub,
  'minimumImportance': instance.minimumImportance,
  'firstTimeSetupDone': instance.firstTimeSetupDone,
  'readItemHandling': _$ReadItemHandlingEnumMap[instance.readItemHandling]!,
};

const _$ReadItemHandlingEnumMap = {
  ReadItemHandling.none: 'none',
  ReadItemHandling.dim: 'dim',
  ReadItemHandling.hide: 'hide',
};
