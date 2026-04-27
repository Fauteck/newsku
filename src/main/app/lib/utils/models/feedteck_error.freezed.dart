// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedteck_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedteckError {

 ErrorType get type; String? get uuid; String get message;@override@JsonKey(includeToJson: false, includeFromJson: false) StackTrace? get stackTrace;
/// Create a copy of FeedteckError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedteckErrorCopyWith<FeedteckError> get copyWith => _$FeedteckErrorCopyWithImpl<FeedteckError>(this as FeedteckError, _$identity);

  /// Serializes this FeedteckError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedteckError&&(identical(other.type, type) || other.type == type)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,uuid,message,stackTrace);

@override
String toString() {
  return 'FeedteckError(type: $type, uuid: $uuid, message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $FeedteckErrorCopyWith<$Res>  {
  factory $FeedteckErrorCopyWith(FeedteckError value, $Res Function(FeedteckError) _then) = _$FeedteckErrorCopyWithImpl;
@useResult
$Res call({
 ErrorType type, String? uuid, String message,@override@JsonKey(includeToJson: false, includeFromJson: false) StackTrace? stackTrace
});




}
/// @nodoc
class _$FeedteckErrorCopyWithImpl<$Res>
    implements $FeedteckErrorCopyWith<$Res> {
  _$FeedteckErrorCopyWithImpl(this._self, this._then);

  final FeedteckError _self;
  final $Res Function(FeedteckError) _then;

/// Create a copy of FeedteckError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? uuid = freezed,Object? message = null,Object? stackTrace = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ErrorType,uuid: freezed == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedteckError].
extension FeedteckErrorPatterns on FeedteckError {
/// A variant of `map` that fallback to returning `orElse`.
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedteckError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedteckError() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedteckError value)  $default,){
final _that = this;
switch (_that) {
case _FeedteckError():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedteckError value)?  $default,){
final _that = this;
switch (_that) {
case _FeedteckError() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ErrorType type,  String? uuid,  String message, @override@JsonKey(includeToJson: false, includeFromJson: false)  StackTrace? stackTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedteckError() when $default != null:
return $default(_that.type,_that.uuid,_that.message,_that.stackTrace);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ErrorType type,  String? uuid,  String message, @override@JsonKey(includeToJson: false, includeFromJson: false)  StackTrace? stackTrace)  $default,) {final _that = this;
switch (_that) {
case _FeedteckError():
return $default(_that.type,_that.uuid,_that.message,_that.stackTrace);}
}
/// A variant of `when` that fallback to returning `null`
@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ErrorType type,  String? uuid,  String message, @override@JsonKey(includeToJson: false, includeFromJson: false)  StackTrace? stackTrace)?  $default,) {final _that = this;
switch (_that) {
case _FeedteckError() when $default != null:
return $default(_that.type,_that.uuid,_that.message,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedteckError extends FeedteckError implements Error {
  const _FeedteckError({required this.type, required this.uuid, this.message = "", @override@JsonKey(includeToJson: false, includeFromJson: false) this.stackTrace}): super._();
  factory _FeedteckError.fromJson(Map<String, dynamic> json) => _$FeedteckErrorFromJson(json);

@override final  ErrorType type;
@override final  String? uuid;
@override@JsonKey() final  String message;
@override@override@JsonKey(includeToJson: false, includeFromJson: false) final  StackTrace? stackTrace;

/// Create a copy of FeedteckError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedteckErrorCopyWith<_FeedteckError> get copyWith => __$FeedteckErrorCopyWithImpl<_FeedteckError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedteckErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedteckError&&(identical(other.type, type) || other.type == type)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,uuid,message,stackTrace);

@override
String toString() {
  return 'FeedteckError(type: $type, uuid: $uuid, message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$FeedteckErrorCopyWith<$Res> implements $FeedteckErrorCopyWith<$Res> {
  factory _$FeedteckErrorCopyWith(_FeedteckError value, $Res Function(_FeedteckError) _then) = __$FeedteckErrorCopyWithImpl;
@override @useResult
$Res call({
 ErrorType type, String? uuid, String message,@override@JsonKey(includeToJson: false, includeFromJson: false) StackTrace? stackTrace
});




}
/// @nodoc
class __$FeedteckErrorCopyWithImpl<$Res>
    implements _$FeedteckErrorCopyWith<$Res> {
  __$FeedteckErrorCopyWithImpl(this._self, this._then);

  final _FeedteckError _self;
  final $Res Function(_FeedteckError) _then;

/// Create a copy of FeedteckError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? uuid = freezed,Object? message = null,Object? stackTrace = freezed,}) {
  return _then(_FeedteckError(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ErrorType,uuid: freezed == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
