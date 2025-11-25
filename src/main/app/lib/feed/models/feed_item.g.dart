// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedItem _$FeedItemFromJson(Map<String, dynamic> json) => _FeedItem(
  id: json['id'] as String?,
  guid: json['guid'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  content: json['content'] as String?,
  reasoning: json['reasoning'] as String?,
  imageUrl: json['imageUrl'] as String?,
  importance: (json['importance'] as num?)?.toInt() ?? 0,
  timeCreated: (json['timeCreated'] as num?)?.toInt() ?? 0,
  feed: json['feed'] == null
      ? null
      : Feed.fromJson(json['feed'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FeedItemToJson(_FeedItem instance) => <String, dynamic>{
  'id': instance.id,
  'guid': instance.guid,
  'title': instance.title,
  'description': instance.description,
  'content': instance.content,
  'reasoning': instance.reasoning,
  'imageUrl': instance.imageUrl,
  'importance': instance.importance,
  'timeCreated': instance.timeCreated,
  'feed': instance.feed,
};
