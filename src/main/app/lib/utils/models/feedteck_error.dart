import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedteck_error.freezed.dart';

part 'feedteck_error.g.dart';

@freezed
sealed class FeedteckError with _$FeedteckError implements Error {
  @Implements<Error>()
  const factory FeedteckError({
    required ErrorType type,
    required String? uuid,
    @Default("") String message,
    @override @JsonKey(includeToJson: false, includeFromJson: false) StackTrace? stackTrace,
  }) = _FeedteckError;

  const FeedteckError._();

  factory FeedteckError.fromJson(Map<String, Object?> json) => _$FeedteckErrorFromJson(json);
}

enum ErrorType { NewskuUserException, NewskuException }
