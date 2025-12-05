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
  dimReadItems: json['dimReadItems'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'password': instance.password,
  'email': instance.email,
  'feedItemPreference': instance.feedItemPreference,
  'oidcSub': instance.oidcSub,
  'minimumImportance': instance.minimumImportance,
  'dimReadItems': instance.dimReadItems,
};
