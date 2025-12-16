// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Paginated<T> _$PaginatedFromJson<T>(Map<String, dynamic> json, T Function(Object? json) fromJsonT) => _Paginated<T>(
  content: (json['content'] as List<dynamic>?)?.map(fromJsonT).toList() ?? const [],
  totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
  numberOfElements: (json['numberOfElements'] as num?)?.toInt() ?? 0,
  number: (json['number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PaginatedToJson<T>(_Paginated<T> instance, Object? Function(T value) toJsonT) =>
    <String, dynamic>{
      'content': instance.content.map(toJsonT).toList(),
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'numberOfElements': instance.numberOfElements,
      'number': instance.number,
    };
