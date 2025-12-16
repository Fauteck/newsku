// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedError _$FeedErrorFromJson(Map<String, dynamic> json) => _FeedError(
  id: json['id'] as String,
  url: json['url'] as String?,
  timeCreated: (json['timeCreated'] as num).toInt(),
  error: json['error'] as String?,
  message: json['message'] as String,
);

Map<String, dynamic> _$FeedErrorToJson(_FeedError instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'timeCreated': instance.timeCreated,
  'error': instance.error,
  'message': instance.message,
};
