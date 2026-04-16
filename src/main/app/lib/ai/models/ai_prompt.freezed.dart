// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_prompt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiPrompt {

  String? get id;

  String get name;

  String get content;

  /// Create a copy of AiPrompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AiPromptCopyWith<AiPrompt> get copyWith => _$AiPromptCopyWithImpl<AiPrompt>(this as AiPrompt, _$identity);

  /// Serializes this AiPrompt to a JSON map.
  Map<String, dynamic> toJson();


  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is AiPrompt && (identical(other.id, id) || other.id == id) && (identical(other.name, name) || other.name == name) && (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, content);

  @override
  String toString() {
    return 'AiPrompt(id: $id, name: $name, content: $content)';
  }


}

/// @nodoc
abstract mixin class $AiPromptCopyWith<$Res> {
  factory $AiPromptCopyWith(AiPrompt value, $Res Function(AiPrompt) _then) = _$AiPromptCopyWithImpl;

  @useResult
  $Res call({
    String? id, String name, String content
  });


}

/// @nodoc
class _$AiPromptCopyWithImpl<$Res>
    implements $AiPromptCopyWith<$Res> {
  _$AiPromptCopyWithImpl(this._self, this._then);

  final AiPrompt _self;
  final $Res Function(AiPrompt) _then;

  /// Create a copy of AiPrompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = null, Object? content = null,}) {
    return _then(_self.copyWith(
      id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
      as String?, name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
    as String, content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
    as String,
    ));
  }

}


/// Adds pattern-matching-related methods to [AiPrompt].
extension AiPromptPatterns on AiPrompt {
  @optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiPrompt value)? $default,{required TResult orElse(),}){
  final _that = this;
  switch (_that) {
  case _AiPrompt() when $default != null:
  return $default(_that);case _:
  return orElse();

  }
  }

  @optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiPrompt value) $default,){
  final _that = this;
  switch (_that) {
  case _AiPrompt():
  return $default(_that);}
  }

  @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiPrompt value)? $default,){
  final _that = this;
  switch (_that) {
  case _AiPrompt() when $default != null:
  return $default(_that);case _:
  return null;

  }
  }

  @optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, String name, String content)? $default,{required TResult orElse(),}) {final _that = this;
  switch (_that) {
  case _AiPrompt() when $default != null:
  return $default(_that.id,_that.name,_that.content);case _:
  return orElse();

  }
  }

  @optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, String name, String content) $default,) {final _that = this;
  switch (_that) {
  case _AiPrompt():
  return $default(_that.id,_that.name,_that.content);}
  }

  @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, String name, String content)? $default,) {final _that = this;
  switch (_that) {
  case _AiPrompt() when $default != null:
  return $default(_that.id,_that.name,_that.content);case _:
  return null;

  }
  }

}

/// @nodoc
@JsonSerializable()
class _AiPrompt implements AiPrompt {
  const _AiPrompt({this.id, required this.name, required this.content});

  factory _AiPrompt.fromJson(Map<String, dynamic> json) => _$AiPromptFromJson(json);

  @override final String? id;
  @override final String name;
  @override final String content;

  /// Create a copy of AiPrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AiPromptCopyWith<_AiPrompt> get copyWith => __$AiPromptCopyWithImpl<_AiPrompt>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AiPromptToJson(this,);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _AiPrompt && (identical(other.id, id) || other.id == id) && (identical(other.name, name) || other.name == name) && (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, content);

  @override
  String toString() {
    return 'AiPrompt(id: $id, name: $name, content: $content)';
  }


}

/// @nodoc
abstract mixin class _$AiPromptCopyWith<$Res> implements $AiPromptCopyWith<$Res> {
  factory _$AiPromptCopyWith(_AiPrompt value, $Res Function(_AiPrompt) _then) = __$AiPromptCopyWithImpl;

  @override
  @useResult
  $Res call({
    String? id, String name, String content
  });


}

/// @nodoc
class __$AiPromptCopyWithImpl<$Res>
    implements _$AiPromptCopyWith<$Res> {
  __$AiPromptCopyWithImpl(this._self, this._then);

  final _AiPrompt _self;
  final $Res Function(_AiPrompt) _then;

  /// Create a copy of AiPrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? id = freezed, Object? name = null, Object? content = null,}) {
    return _then(_AiPrompt(
      id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
      as String?, name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
    as String, content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
    as String,
    ));
  }


}

// dart format on
