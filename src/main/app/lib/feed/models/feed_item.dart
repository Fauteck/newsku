import 'package:freezed_annotation/freezed_annotation.dart';

import 'feed.dart';

part 'feed_item.freezed.dart';
part 'feed_item.g.dart';

@freezed
sealed class FeedItem with _$FeedItem {
  const factory FeedItem({
    String? id,
    String? guid,
    String? title,
    String? description,
    String? content,
    String? reasoning,
    String? imageUrl,
    @Default(0) int importance,
    @Default(0) int timeCreated,
    Feed? feed,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, Object?> json)
      => _$FeedItemFromJson(json);
}