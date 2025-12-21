// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Stats _$StatsFromJson(Map<String, dynamic> json) => _Stats(
  tagClicks:
      (json['tagClicks'] as List<dynamic>?)?.map((e) => TagClick.fromJson(e as Map<String, dynamic>)).toList() ??
      const [],
  feedClicks:
      (json['feedClicks'] as List<dynamic>?)?.map((e) => FeedClick.fromJson(e as Map<String, dynamic>)).toList() ??
      const [],
);

Map<String, dynamic> _$StatsToJson(_Stats instance) => <String, dynamic>{
  'tagClicks': instance.tagClicks,
  'feedClicks': instance.feedClicks,
};

_TagClick _$TagClickFromJson(Map<String, dynamic> json) =>
    _TagClick(tag: json['tag'] as String, clicks: (json['clicks'] as num).toInt());

Map<String, dynamic> _$TagClickToJson(_TagClick instance) => <String, dynamic>{
  'tag': instance.tag,
  'clicks': instance.clicks,
};

_FeedClick _$FeedClickFromJson(Map<String, dynamic> json) =>
    _FeedClick(feed: Feed.fromJson(json['feed'] as Map<String, dynamic>), clicks: (json['clicks'] as num).toInt());

Map<String, dynamic> _$FeedClickToJson(_FeedClick instance) => <String, dynamic>{
  'feed': instance.feed,
  'clicks': instance.clicks,
};
