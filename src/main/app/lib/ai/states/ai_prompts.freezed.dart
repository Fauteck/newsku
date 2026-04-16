// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_prompts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiPromptsState {

 List<AiPrompt> get prompts; bool get loading; dynamic get error; StackTrace? get stackTrace;
/// Create a copy of AiPromptsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiPromptsStateCopyWith<AiPromptsState> get copyWith => _$AiPromptsStateCopyWithImpl<AiPromptsState>(this as AiPromptsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiPromptsState&&const DeepCollectionEquality().equals(other.prompts, prompts)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(prompts),loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'AiPromptsState(prompts: $prompts, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AiPromptsStateCopyWith<$Res>  {
  factory $AiPromptsStateCopyWith(AiPromptsState value, $Res Function(AiPromptsState) _then) = _$AiPromptsStateCopyWithImpl;
@useResult
$Res call({
 List<AiPrompt> prompts, bool loading, dynamic error, StackTrace? stackTrace
});


}
/// @nodoc
class _$AiPromptsStateCopyWithImpl<$Res>
    implements $AiPromptsStateCopyWith<$Res> {
  _$AiPromptsStateCopyWithImpl(this._self, this._then);

  final AiPromptsState _self;
  final $Res Function(AiPromptsState) _then;

/// Create a copy of AiPromptsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompts = null,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_self.copyWith(
prompts: null == prompts ? _self.prompts : prompts // ignore: cast_nullable_to_non_nullable
as List<AiPrompt>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}
}


/// Adds pattern-matching-related methods to [AiPromptsState].
extension AiPromptsStatePatterns on AiPromptsState {
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiPromptsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiPromptsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiPromptsState value)  $default,){
final _that = this;
switch (_that) {
case _AiPromptsState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiPromptsState value)?  $default,){
final _that = this;
switch (_that) {
case _AiPromptsState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AiPrompt> prompts,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiPromptsState() when $default != null:
return $default(_that.prompts,_that.loading,_that.error,_that.stackTrace);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AiPrompt> prompts,  bool loading,  dynamic error,  StackTrace? stackTrace)  $default,) {final _that = this;
switch (_that) {
case _AiPromptsState():
return $default(_that.prompts,_that.loading,_that.error,_that.stackTrace);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AiPrompt> prompts,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,) {final _that = this;
switch (_that) {
case _AiPromptsState() when $default != null:
return $default(_that.prompts,_that.loading,_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _AiPromptsState implements AiPromptsState, WithError {
  const _AiPromptsState({final  List<AiPrompt> prompts = const [], this.loading = false, this.error, this.stackTrace}): _prompts = prompts;


 final  List<AiPrompt> _prompts;
@override@JsonKey() List<AiPrompt> get prompts {
  if (_prompts is EqualUnmodifiableListView) return _prompts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prompts);
}

@override@JsonKey() final  bool loading;
@override final  dynamic error;
@override final  StackTrace? stackTrace;

/// Create a copy of AiPromptsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiPromptsStateCopyWith<_AiPromptsState> get copyWith => __$AiPromptsStateCopyWithImpl<_AiPromptsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiPromptsState&&const DeepCollectionEquality().equals(other._prompts, _prompts)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_prompts),loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'AiPromptsState(prompts: $prompts, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$AiPromptsStateCopyWith<$Res> implements $AiPromptsStateCopyWith<$Res> {
  factory _$AiPromptsStateCopyWith(_AiPromptsState value, $Res Function(_AiPromptsState) _then) = __$AiPromptsStateCopyWithImpl;
@override @useResult
$Res call({
 List<AiPrompt> prompts, bool loading, dynamic error, StackTrace? stackTrace
});


}
/// @nodoc
class __$AiPromptsStateCopyWithImpl<$Res>
    implements _$AiPromptsStateCopyWith<$Res> {
  __$AiPromptsStateCopyWithImpl(this._self, this._then);

  final _AiPromptsState _self;
  final $Res Function(_AiPromptsState) _then;

/// Create a copy of AiPromptsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompts = null,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_AiPromptsState(
prompts: null == prompts ? _self._prompts : prompts // ignore: cast_nullable_to_non_nullable
as List<AiPrompt>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}

}

// dart format on
