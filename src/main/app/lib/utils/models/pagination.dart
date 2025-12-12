import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';

part 'pagination.g.dart';

@Freezed(genericArgumentFactories: true)
sealed class Paginated<T> with _$Paginated<T> {
  const factory Paginated({
    @Default([]) List<T> content,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
    @Default(0) int numberOfElements,
  }) = _Paginated;

  factory Paginated.fromJson(Map<String, Object?> json, T Function(Object?) fromJsonT) =>
      _$PaginatedFromJson(json, fromJsonT);
}
