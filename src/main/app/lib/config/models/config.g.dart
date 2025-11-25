// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Config _$ConfigFromJson(Map<String, dynamic> json) => _Config(
  allowSignup: json['allowSignup'] as bool,
  oidcConfig: json['oidcConfig'] == null
      ? null
      : OidcConfig.fromJson(json['oidcConfig'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConfigToJson(_Config instance) => <String, dynamic>{
  'allowSignup': instance.allowSignup,
  'oidcConfig': instance.oidcConfig,
};
