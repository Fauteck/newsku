// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'openai_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OpenAiUsageStats {

 String get useCase; int get totalTokens; int get promptTokens; int get completionTokens; double? get estimatedCostUsd; int get callCount; int? get monthlyLimit;
/// Create a copy of OpenAiUsageStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenAiUsageStatsCopyWith<OpenAiUsageStats> get copyWith => _$OpenAiUsageStatsCopyWithImpl<OpenAiUsageStats>(this as OpenAiUsageStats, _$identity);

  /// Serializes this OpenAiUsageStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenAiUsageStats&&(identical(other.useCase, useCase) || other.useCase == useCase)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd)&&(identical(other.callCount, callCount) || other.callCount == callCount)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,useCase,totalTokens,promptTokens,completionTokens,estimatedCostUsd,callCount,monthlyLimit);

@override
String toString() {
  return 'OpenAiUsageStats(useCase: $useCase, totalTokens: $totalTokens, promptTokens: $promptTokens, completionTokens: $completionTokens, estimatedCostUsd: $estimatedCostUsd, callCount: $callCount, monthlyLimit: $monthlyLimit)';
}


}

/// @nodoc
abstract mixin class $OpenAiUsageStatsCopyWith<$Res>  {
  factory $OpenAiUsageStatsCopyWith(OpenAiUsageStats value, $Res Function(OpenAiUsageStats) _then) = _$OpenAiUsageStatsCopyWithImpl;
@useResult
$Res call({
 String useCase, int totalTokens, int promptTokens, int completionTokens, double? estimatedCostUsd, int callCount, int? monthlyLimit
});




}
/// @nodoc
class _$OpenAiUsageStatsCopyWithImpl<$Res>
    implements $OpenAiUsageStatsCopyWith<$Res> {
  _$OpenAiUsageStatsCopyWithImpl(this._self, this._then);

  final OpenAiUsageStats _self;
  final $Res Function(OpenAiUsageStats) _then;

/// Create a copy of OpenAiUsageStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? useCase = null,Object? totalTokens = null,Object? promptTokens = null,Object? completionTokens = null,Object? estimatedCostUsd = freezed,Object? callCount = null,Object? monthlyLimit = freezed,}) {
  return _then(_self.copyWith(
useCase: null == useCase ? _self.useCase : useCase // ignore: cast_nullable_to_non_nullable
as String,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: freezed == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double?,callCount: null == callCount ? _self.callCount : callCount // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: freezed == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenAiUsageStats].
extension OpenAiUsageStatsPatterns on OpenAiUsageStats {
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenAiUsageStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenAiUsageStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenAiUsageStats value)  $default,){
final _that = this;
switch (_that) {
case _OpenAiUsageStats():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenAiUsageStats value)?  $default,){
final _that = this;
switch (_that) {
case _OpenAiUsageStats() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String useCase,  int totalTokens,  int promptTokens,  int completionTokens,  double? estimatedCostUsd,  int callCount,  int? monthlyLimit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenAiUsageStats() when $default != null:
return $default(_that.useCase,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.estimatedCostUsd,_that.callCount,_that.monthlyLimit);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String useCase,  int totalTokens,  int promptTokens,  int completionTokens,  double? estimatedCostUsd,  int callCount,  int? monthlyLimit)  $default,) {final _that = this;
switch (_that) {
case _OpenAiUsageStats():
return $default(_that.useCase,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.estimatedCostUsd,_that.callCount,_that.monthlyLimit);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String useCase,  int totalTokens,  int promptTokens,  int completionTokens,  double? estimatedCostUsd,  int callCount,  int? monthlyLimit)?  $default,) {final _that = this;
switch (_that) {
case _OpenAiUsageStats() when $default != null:
return $default(_that.useCase,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.estimatedCostUsd,_that.callCount,_that.monthlyLimit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenAiUsageStats implements OpenAiUsageStats {
  const _OpenAiUsageStats({required this.useCase, this.totalTokens = 0, this.promptTokens = 0, this.completionTokens = 0, this.estimatedCostUsd, this.callCount = 0, this.monthlyLimit});
  factory _OpenAiUsageStats.fromJson(Map<String, dynamic> json) => _$OpenAiUsageStatsFromJson(json);

@override final  String useCase;
@override@JsonKey() final  int totalTokens;
@override@JsonKey() final  int promptTokens;
@override@JsonKey() final  int completionTokens;
@override final  double? estimatedCostUsd;
@override@JsonKey() final  int callCount;
@override final  int? monthlyLimit;

/// Create a copy of OpenAiUsageStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenAiUsageStatsCopyWith<_OpenAiUsageStats> get copyWith => __$OpenAiUsageStatsCopyWithImpl<_OpenAiUsageStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenAiUsageStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenAiUsageStats&&(identical(other.useCase, useCase) || other.useCase == useCase)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd)&&(identical(other.callCount, callCount) || other.callCount == callCount)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,useCase,totalTokens,promptTokens,completionTokens,estimatedCostUsd,callCount,monthlyLimit);

@override
String toString() {
  return 'OpenAiUsageStats(useCase: $useCase, totalTokens: $totalTokens, promptTokens: $promptTokens, completionTokens: $completionTokens, estimatedCostUsd: $estimatedCostUsd, callCount: $callCount, monthlyLimit: $monthlyLimit)';
}


}

/// @nodoc
abstract mixin class _$OpenAiUsageStatsCopyWith<$Res> implements $OpenAiUsageStatsCopyWith<$Res> {
  factory _$OpenAiUsageStatsCopyWith(_OpenAiUsageStats value, $Res Function(_OpenAiUsageStats) _then) = __$OpenAiUsageStatsCopyWithImpl;
@override @useResult
$Res call({
 String useCase, int totalTokens, int promptTokens, int completionTokens, double? estimatedCostUsd, int callCount, int? monthlyLimit
});




}
/// @nodoc
class __$OpenAiUsageStatsCopyWithImpl<$Res>
    implements _$OpenAiUsageStatsCopyWith<$Res> {
  __$OpenAiUsageStatsCopyWithImpl(this._self, this._then);

  final _OpenAiUsageStats _self;
  final $Res Function(_OpenAiUsageStats) _then;

/// Create a copy of OpenAiUsageStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? useCase = null,Object? totalTokens = null,Object? promptTokens = null,Object? completionTokens = null,Object? estimatedCostUsd = freezed,Object? callCount = null,Object? monthlyLimit = freezed,}) {
  return _then(_OpenAiUsageStats(
useCase: null == useCase ? _self.useCase : useCase // ignore: cast_nullable_to_non_nullable
as String,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: freezed == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double?,callCount: null == callCount ? _self.callCount : callCount // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: freezed == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
