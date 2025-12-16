import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed.freezed.dart';
part 'feed.g.dart';

@freezed
sealed class Feed with _$Feed {
  const factory Feed({
    String? id,
    String? name,
    String? description,
    String? url,
    String? itemPreference,
    String? image,
    @Default(0) int errorsInLast24Hours,
  }) = _Feed;

  factory Feed.fromJson(Map<String, Object?> json) => _$FeedFromJson(json);
}
