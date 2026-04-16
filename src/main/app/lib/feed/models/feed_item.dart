import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:app/feed/models/feed.dart';

part 'feed_item.freezed.dart';
part 'feed_item.g.dart';

@freezed
sealed class FeedItem with _$FeedItem {
  const factory FeedItem({
    String? id,
    String? guid,
    String? title,
    String? url,
    String? description,
    String? content,
    String? reasoning,
    String? imageUrl,
    @Default(false) bool read,
    @Default(false) bool saved,
    @Default(0) int importance,
    @Default(0) int timeCreated,
    @Default([]) List<String> tags,
    Feed? feed,
    /// AI-generated length-adapted title variant, used when the global
    /// "text shortening" preference is enabled.
    String? shortTitle,
    /// AI-generated length-adapted teaser variant, used when the global
    /// "text shortening" preference is enabled.
    String? shortTeaser,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, Object?> json) => _$FeedItemFromJson(json);
}
