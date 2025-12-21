import 'package:app/feed/models/feed.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats.freezed.dart';

part 'stats.g.dart';

@freezed
sealed class Stats with _$Stats {
  const factory Stats({@Default([]) List<TagClick> tagClicks, @Default([]) List<FeedClick> feedClicks}) = _Stats;

  factory Stats.fromJson(Map<String, Object?> json) => _$StatsFromJson(json);
}

@freezed
sealed class TagClick with _$TagClick {
  const factory TagClick({required String tag, required int clicks}) = _TagClick;

  factory TagClick.fromJson(Map<String, Object?> json) => _$TagClickFromJson(json);
}

@freezed
sealed class FeedClick with _$FeedClick {
  const factory FeedClick({required Feed feed, required int clicks}) = _FeedClick;

  factory FeedClick.fromJson(Map<String, Object?> json) => _$FeedClickFromJson(json);
}
