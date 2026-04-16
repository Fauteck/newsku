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
  emailDigest:
      (json['emailDigest'] as List<dynamic>?)?.map((e) => $enumDecode(_$EmailDigestFrequencyEnumMap, e)).toList() ??
      const [],
  freshRssUsername: json['freshRssUsername'] as String?,
  freshRssApiPassword: json['freshRssApiPassword'] as String?,
  freshRssUrl: json['freshRssUrl'] as String?,
  openAiApiKey: json['openAiApiKey'] as String?,
  openAiModel: json['openAiModel'] as String?,
  openAiUrl: json['openAiUrl'] as String?,
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
  'emailDigest': instance.emailDigest.map((e) => _$EmailDigestFrequencyEnumMap[e]!).toList(),
  'freshRssUsername': instance.freshRssUsername,
  'freshRssApiPassword': instance.freshRssApiPassword,
  'freshRssUrl': instance.freshRssUrl,
  'openAiApiKey': instance.openAiApiKey,
  'openAiModel': instance.openAiModel,
  'openAiUrl': instance.openAiUrl,
};

const _$ReadItemHandlingEnumMap = {
  ReadItemHandling.none: 'none',
  ReadItemHandling.dim: 'dim',
  ReadItemHandling.hide: 'hide',
  ReadItemHandling.unreadFirstThenDim: 'unreadFirstThenDim',
};

const _$EmailDigestFrequencyEnumMap = {
  EmailDigestFrequency.daily: 'daily',
  EmailDigestFrequency.weekly: 'weekly',
  EmailDigestFrequency.monthly: 'monthly',
};
