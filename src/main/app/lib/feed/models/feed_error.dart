import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_error.freezed.dart';

part 'feed_error.g.dart';

@freezed
sealed class FeedError with _$FeedError {
  const factory FeedError({
    required String id,
    String? url,
    required int timeCreated,
    String? error,
    required String message,
  }) = _FeedError;

  factory FeedError.fromJson(Map<String, Object?> json) => _$FeedErrorFromJson(json);
}
