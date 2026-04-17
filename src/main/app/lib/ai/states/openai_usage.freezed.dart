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
mixin _$OpenaiUsageState {

 OpenAiUsageStats? get relevance; OpenAiUsageStats? get shortening; bool get loading; dynamic get error; StackTrace? get stackTrace;
/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenaiUsageStateCopyWith<OpenaiUsageState> get copyWith => _$OpenaiUsageStateCopyWithImpl<OpenaiUsageState>(this as OpenaiUsageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenaiUsageState&&(identical(other.relevance, relevance) || other.relevance == relevance)&&(identical(other.shortening, shortening) || other.shortening == shortening)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,relevance,shortening,loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'OpenaiUsageState(relevance: $relevance, shortening: $shortening, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $OpenaiUsageStateCopyWith<$Res>  {
  factory $OpenaiUsageStateCopyWith(OpenaiUsageState value, $Res Function(OpenaiUsageState) _then) = _$OpenaiUsageStateCopyWithImpl;
@useResult
$Res call({
 OpenAiUsageStats? relevance, OpenAiUsageStats? shortening, bool loading, dynamic error, StackTrace? stackTrace
});


$OpenAiUsageStatsCopyWith<$Res>? get relevance;$OpenAiUsageStatsCopyWith<$Res>? get shortening;
}
/// @nodoc
class _$OpenaiUsageStateCopyWithImpl<$Res>
    implements $OpenaiUsageStateCopyWith<$Res> {
  _$OpenaiUsageStateCopyWithImpl(this._self, this._then);

  final OpenaiUsageState _self;
  final $Res Function(OpenaiUsageState) _then;

/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? relevance = freezed,Object? shortening = freezed,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_self.copyWith(
relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as OpenAiUsageStats?,shortening: freezed == shortening ? _self.shortening : shortening // ignore: cast_nullable_to_non_nullable
as OpenAiUsageStats?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}
/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenAiUsageStatsCopyWith<$Res>? get relevance {
    if (_self.relevance == null) {
    return null;
  }

  return $OpenAiUsageStatsCopyWith<$Res>(_self.relevance!, (value) {
    _then(_self.copyWith(relevance: value));
  });
}/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenAiUsageStatsCopyWith<$Res>? get shortening {
    if (_self.shortening == null) {
    return null;
  }

  return $OpenAiUsageStatsCopyWith<$Res>(_self.shortening!, (value) {
    _then(_self.copyWith(shortening: value));
  });
}
}


/// Adds pattern-matching-related methods to [OpenaiUsageState].
extension OpenaiUsageStatePatterns on OpenaiUsageState {
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenaiUsageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenaiUsageState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenaiUsageState value)  $default,){
final _that = this;
switch (_that) {
case _OpenaiUsageState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenaiUsageState value)?  $default,){
final _that = this;
switch (_that) {
case _OpenaiUsageState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OpenAiUsageStats? relevance,  OpenAiUsageStats? shortening,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenaiUsageState() when $default != null:
return $default(_that.relevance,_that.shortening,_that.loading,_that.error,_that.stackTrace);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OpenAiUsageStats? relevance,  OpenAiUsageStats? shortening,  bool loading,  dynamic error,  StackTrace? stackTrace)  $default,) {final _that = this;
switch (_that) {
case _OpenaiUsageState():
return $default(_that.relevance,_that.shortening,_that.loading,_that.error,_that.stackTrace);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OpenAiUsageStats? relevance,  OpenAiUsageStats? shortening,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,) {final _that = this;
switch (_that) {
case _OpenaiUsageState() when $default != null:
return $default(_that.relevance,_that.shortening,_that.loading,_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _OpenaiUsageState implements OpenaiUsageState, WithError {
  const _OpenaiUsageState({this.relevance, this.shortening, this.loading = false, this.error, this.stackTrace});


@override final  OpenAiUsageStats? relevance;
@override final  OpenAiUsageStats? shortening;
@override@JsonKey() final  bool loading;
@override final  dynamic error;
@override final  StackTrace? stackTrace;

/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenaiUsageStateCopyWith<_OpenaiUsageState> get copyWith => __$OpenaiUsageStateCopyWithImpl<_OpenaiUsageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenaiUsageState&&(identical(other.relevance, relevance) || other.relevance == relevance)&&(identical(other.shortening, shortening) || other.shortening == shortening)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,relevance,shortening,loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'OpenaiUsageState(relevance: $relevance, shortening: $shortening, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$OpenaiUsageStateCopyWith<$Res> implements $OpenaiUsageStateCopyWith<$Res> {
  factory _$OpenaiUsageStateCopyWith(_OpenaiUsageState value, $Res Function(_OpenaiUsageState) _then) = __$OpenaiUsageStateCopyWithImpl;
@override @useResult
$Res call({
 OpenAiUsageStats? relevance, OpenAiUsageStats? shortening, bool loading, dynamic error, StackTrace? stackTrace
});


@override $OpenAiUsageStatsCopyWith<$Res>? get relevance;@override $OpenAiUsageStatsCopyWith<$Res>? get shortening;
}
/// @nodoc
class __$OpenaiUsageStateCopyWithImpl<$Res>
    implements _$OpenaiUsageStateCopyWith<$Res> {
  __$OpenaiUsageStateCopyWithImpl(this._self, this._then);

  final _OpenaiUsageState _self;
  final $Res Function(_OpenaiUsageState) _then;

/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? relevance = freezed,Object? shortening = freezed,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_OpenaiUsageState(
relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as OpenAiUsageStats?,shortening: freezed == shortening ? _self.shortening : shortening // ignore: cast_nullable_to_non_nullable
as OpenAiUsageStats?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}

/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenAiUsageStatsCopyWith<$Res>? get relevance {
    if (_self.relevance == null) {
    return null;
  }

  return $OpenAiUsageStatsCopyWith<$Res>(_self.relevance!, (value) {
    _then(_self.copyWith(relevance: value));
  });
}/// Create a copy of OpenaiUsageState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenAiUsageStatsCopyWith<$Res>? get shortening {
    if (_self.shortening == null) {
    return null;
  }

  return $OpenAiUsageStatsCopyWith<$Res>(_self.shortening!, (value) {
    _then(_self.copyWith(shortening: value));
  });
}
}

// dart format on
