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

 String get useCase; int get totalTokens; int get promptTokens; int get completionTokens; double? get estimatedCostUsd; int get callCount; int? get monthlyLimit; List<OpenAiModelUsage> get modelBreakdown;
/// Create a copy of OpenAiUsageStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenAiUsageStatsCopyWith<OpenAiUsageStats> get copyWith => _$OpenAiUsageStatsCopyWithImpl<OpenAiUsageStats>(this as OpenAiUsageStats, _$identity);

  /// Serializes this OpenAiUsageStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenAiUsageStats&&(identical(other.useCase, useCase) || other.useCase == useCase)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd)&&(identical(other.callCount, callCount) || other.callCount == callCount)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&const DeepCollectionEquality().equals(other.modelBreakdown, modelBreakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,useCase,totalTokens,promptTokens,completionTokens,estimatedCostUsd,callCount,monthlyLimit,const DeepCollectionEquality().hash(modelBreakdown));

@override
String toString() {
  return 'OpenAiUsageStats(useCase: $useCase, totalTokens: $totalTokens, promptTokens: $promptTokens, completionTokens: $completionTokens, estimatedCostUsd: $estimatedCostUsd, callCount: $callCount, monthlyLimit: $monthlyLimit, modelBreakdown: $modelBreakdown)';
}


}

/// @nodoc
abstract mixin class $OpenAiUsageStatsCopyWith<$Res>  {
  factory $OpenAiUsageStatsCopyWith(OpenAiUsageStats value, $Res Function(OpenAiUsageStats) _then) = _$OpenAiUsageStatsCopyWithImpl;
@useResult
$Res call({
 String useCase, int totalTokens, int promptTokens, int completionTokens, double? estimatedCostUsd, int callCount, int? monthlyLimit, List<OpenAiModelUsage> modelBreakdown
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
@pragma('vm:prefer-inline') @override $Res call({Object? useCase = null,Object? totalTokens = null,Object? promptTokens = null,Object? completionTokens = null,Object? estimatedCostUsd = freezed,Object? callCount = null,Object? monthlyLimit = freezed,Object? modelBreakdown = null,}) {
  return _then(_self.copyWith(
useCase: null == useCase ? _self.useCase : useCase // ignore: cast_nullable_to_non_nullable
as String,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: freezed == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double?,callCount: null == callCount ? _self.callCount : callCount // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: freezed == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int?,modelBreakdown: null == modelBreakdown ? _self.modelBreakdown : modelBreakdown // ignore: cast_nullable_to_non_nullable
as List<OpenAiModelUsage>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String useCase,  int totalTokens,  int promptTokens,  int completionTokens,  double? estimatedCostUsd,  int callCount,  int? monthlyLimit,  List<OpenAiModelUsage> modelBreakdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenAiUsageStats() when $default != null:
return $default(_that.useCase,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.estimatedCostUsd,_that.callCount,_that.monthlyLimit,_that.modelBreakdown);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String useCase,  int totalTokens,  int promptTokens,  int completionTokens,  double? estimatedCostUsd,  int callCount,  int? monthlyLimit,  List<OpenAiModelUsage> modelBreakdown)  $default,) {final _that = this;
switch (_that) {
case _OpenAiUsageStats():
return $default(_that.useCase,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.estimatedCostUsd,_that.callCount,_that.monthlyLimit,_that.modelBreakdown);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String useCase,  int totalTokens,  int promptTokens,  int completionTokens,  double? estimatedCostUsd,  int callCount,  int? monthlyLimit,  List<OpenAiModelUsage> modelBreakdown)?  $default,) {final _that = this;
switch (_that) {
case _OpenAiUsageStats() when $default != null:
return $default(_that.useCase,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.estimatedCostUsd,_that.callCount,_that.monthlyLimit,_that.modelBreakdown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenAiUsageStats implements OpenAiUsageStats {
  const _OpenAiUsageStats({required this.useCase, this.totalTokens = 0, this.promptTokens = 0, this.completionTokens = 0, this.estimatedCostUsd, this.callCount = 0, this.monthlyLimit, final  List<OpenAiModelUsage> modelBreakdown = const <OpenAiModelUsage>[]}): _modelBreakdown = modelBreakdown;
  factory _OpenAiUsageStats.fromJson(Map<String, dynamic> json) => _$OpenAiUsageStatsFromJson(json);

@override final  String useCase;
@override@JsonKey() final  int totalTokens;
@override@JsonKey() final  int promptTokens;
@override@JsonKey() final  int completionTokens;
@override final  double? estimatedCostUsd;
@override@JsonKey() final  int callCount;
@override final  int? monthlyLimit;
 final  List<OpenAiModelUsage> _modelBreakdown;
@override@JsonKey() List<OpenAiModelUsage> get modelBreakdown {
  if (_modelBreakdown is EqualUnmodifiableListView) return _modelBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelBreakdown);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenAiUsageStats&&(identical(other.useCase, useCase) || other.useCase == useCase)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd)&&(identical(other.callCount, callCount) || other.callCount == callCount)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&const DeepCollectionEquality().equals(other._modelBreakdown, _modelBreakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,useCase,totalTokens,promptTokens,completionTokens,estimatedCostUsd,callCount,monthlyLimit,const DeepCollectionEquality().hash(_modelBreakdown));

@override
String toString() {
  return 'OpenAiUsageStats(useCase: $useCase, totalTokens: $totalTokens, promptTokens: $promptTokens, completionTokens: $completionTokens, estimatedCostUsd: $estimatedCostUsd, callCount: $callCount, monthlyLimit: $monthlyLimit, modelBreakdown: $modelBreakdown)';
}


}

/// @nodoc
abstract mixin class _$OpenAiUsageStatsCopyWith<$Res> implements $OpenAiUsageStatsCopyWith<$Res> {
  factory _$OpenAiUsageStatsCopyWith(_OpenAiUsageStats value, $Res Function(_OpenAiUsageStats) _then) = __$OpenAiUsageStatsCopyWithImpl;
@override @useResult
$Res call({
 String useCase, int totalTokens, int promptTokens, int completionTokens, double? estimatedCostUsd, int callCount, int? monthlyLimit, List<OpenAiModelUsage> modelBreakdown
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
@override @pragma('vm:prefer-inline') $Res call({Object? useCase = null,Object? totalTokens = null,Object? promptTokens = null,Object? completionTokens = null,Object? estimatedCostUsd = freezed,Object? callCount = null,Object? monthlyLimit = freezed,Object? modelBreakdown = null,}) {
  return _then(_OpenAiUsageStats(
useCase: null == useCase ? _self.useCase : useCase // ignore: cast_nullable_to_non_nullable
as String,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: freezed == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double?,callCount: null == callCount ? _self.callCount : callCount // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: freezed == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int?,modelBreakdown: null == modelBreakdown ? _self._modelBreakdown : modelBreakdown // ignore: cast_nullable_to_non_nullable
as List<OpenAiModelUsage>,
  ));
}


}

/// @nodoc
mixin _$OpenAiModelUsage {

 String get model; int get totalTokens; int get promptTokens; int get completionTokens; int get callCount; double? get estimatedCostUsd;
/// Create a copy of OpenAiModelUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenAiModelUsageCopyWith<OpenAiModelUsage> get copyWith => _$OpenAiModelUsageCopyWithImpl<OpenAiModelUsage>(this as OpenAiModelUsage, _$identity);

  /// Serializes this OpenAiModelUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenAiModelUsage&&(identical(other.model, model) || other.model == model)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.callCount, callCount) || other.callCount == callCount)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,model,totalTokens,promptTokens,completionTokens,callCount,estimatedCostUsd);

@override
String toString() {
  return 'OpenAiModelUsage(model: $model, totalTokens: $totalTokens, promptTokens: $promptTokens, completionTokens: $completionTokens, callCount: $callCount, estimatedCostUsd: $estimatedCostUsd)';
}


}

/// @nodoc
abstract mixin class $OpenAiModelUsageCopyWith<$Res>  {
  factory $OpenAiModelUsageCopyWith(OpenAiModelUsage value, $Res Function(OpenAiModelUsage) _then) = _$OpenAiModelUsageCopyWithImpl;
@useResult
$Res call({
 String model, int totalTokens, int promptTokens, int completionTokens, int callCount, double? estimatedCostUsd
});




}
/// @nodoc
class _$OpenAiModelUsageCopyWithImpl<$Res>
    implements $OpenAiModelUsageCopyWith<$Res> {
  _$OpenAiModelUsageCopyWithImpl(this._self, this._then);

  final OpenAiModelUsage _self;
  final $Res Function(OpenAiModelUsage) _then;

/// Create a copy of OpenAiModelUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? model = null,Object? totalTokens = null,Object? promptTokens = null,Object? completionTokens = null,Object? callCount = null,Object? estimatedCostUsd = freezed,}) {
  return _then(_self.copyWith(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,callCount: null == callCount ? _self.callCount : callCount // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: freezed == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenAiModelUsage].
extension OpenAiModelUsagePatterns on OpenAiModelUsage {
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenAiModelUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenAiModelUsage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenAiModelUsage value)  $default,){
final _that = this;
switch (_that) {
case _OpenAiModelUsage():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenAiModelUsage value)?  $default,){
final _that = this;
switch (_that) {
case _OpenAiModelUsage() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String model,  int totalTokens,  int promptTokens,  int completionTokens,  int callCount,  double? estimatedCostUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenAiModelUsage() when $default != null:
return $default(_that.model,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.callCount,_that.estimatedCostUsd);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String model,  int totalTokens,  int promptTokens,  int completionTokens,  int callCount,  double? estimatedCostUsd)  $default,) {final _that = this;
switch (_that) {
case _OpenAiModelUsage():
return $default(_that.model,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.callCount,_that.estimatedCostUsd);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String model,  int totalTokens,  int promptTokens,  int completionTokens,  int callCount,  double? estimatedCostUsd)?  $default,) {final _that = this;
switch (_that) {
case _OpenAiModelUsage() when $default != null:
return $default(_that.model,_that.totalTokens,_that.promptTokens,_that.completionTokens,_that.callCount,_that.estimatedCostUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenAiModelUsage implements OpenAiModelUsage {
  const _OpenAiModelUsage({required this.model, this.totalTokens = 0, this.promptTokens = 0, this.completionTokens = 0, this.callCount = 0, this.estimatedCostUsd});
  factory _OpenAiModelUsage.fromJson(Map<String, dynamic> json) => _$OpenAiModelUsageFromJson(json);

@override final  String model;
@override@JsonKey() final  int totalTokens;
@override@JsonKey() final  int promptTokens;
@override@JsonKey() final  int completionTokens;
@override@JsonKey() final  int callCount;
@override final  double? estimatedCostUsd;

/// Create a copy of OpenAiModelUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenAiModelUsageCopyWith<_OpenAiModelUsage> get copyWith => __$OpenAiModelUsageCopyWithImpl<_OpenAiModelUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenAiModelUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenAiModelUsage&&(identical(other.model, model) || other.model == model)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.callCount, callCount) || other.callCount == callCount)&&(identical(other.estimatedCostUsd, estimatedCostUsd) || other.estimatedCostUsd == estimatedCostUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,model,totalTokens,promptTokens,completionTokens,callCount,estimatedCostUsd);

@override
String toString() {
  return 'OpenAiModelUsage(model: $model, totalTokens: $totalTokens, promptTokens: $promptTokens, completionTokens: $completionTokens, callCount: $callCount, estimatedCostUsd: $estimatedCostUsd)';
}


}

/// @nodoc
abstract mixin class _$OpenAiModelUsageCopyWith<$Res> implements $OpenAiModelUsageCopyWith<$Res> {
  factory _$OpenAiModelUsageCopyWith(_OpenAiModelUsage value, $Res Function(_OpenAiModelUsage) _then) = __$OpenAiModelUsageCopyWithImpl;
@override @useResult
$Res call({
 String model, int totalTokens, int promptTokens, int completionTokens, int callCount, double? estimatedCostUsd
});




}
/// @nodoc
class __$OpenAiModelUsageCopyWithImpl<$Res>
    implements _$OpenAiModelUsageCopyWith<$Res> {
  __$OpenAiModelUsageCopyWithImpl(this._self, this._then);

  final _OpenAiModelUsage _self;
  final $Res Function(_OpenAiModelUsage) _then;

/// Create a copy of OpenAiModelUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? model = null,Object? totalTokens = null,Object? promptTokens = null,Object? completionTokens = null,Object? callCount = null,Object? estimatedCostUsd = freezed,}) {
  return _then(_OpenAiModelUsage(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,callCount: null == callCount ? _self.callCount : callCount // ignore: cast_nullable_to_non_nullable
as int,estimatedCostUsd: freezed == estimatedCostUsd ? _self.estimatedCostUsd : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
