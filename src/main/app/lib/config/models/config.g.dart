// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Config _$ConfigFromJson(Map<String, dynamic> json) => _Config(
  demoMode: json['demoMode'] as bool? ?? false,
  backendVersion: json['backendVersion'] as String,
  allowSignup: json['allowSignup'] as bool,
  canResetPassword: json['canResetPassword'] as bool? ?? false,
  oidcConfig: json['oidcConfig'] == null ? null : OidcConfig.fromJson(json['oidcConfig'] as Map<String, dynamic>),
  announcement: json['announcement'] as String? ?? "",
);

Map<String, dynamic> _$ConfigToJson(_Config instance) => <String, dynamic>{
  'demoMode': instance.demoMode,
  'backendVersion': instance.backendVersion,
  'allowSignup': instance.allowSignup,
  'canResetPassword': instance.canResetPassword,
  'oidcConfig': instance.oidcConfig,
  'announcement': instance.announcement,
};
