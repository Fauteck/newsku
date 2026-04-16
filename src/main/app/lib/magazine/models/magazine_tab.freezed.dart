// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'magazine_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MagazineTab {

  String? get id;

  String get name;

  int get displayOrder;

  bool get isPublic;

  String? get aiPreference;

  String? get aiPromptId;

  int? get minimumImportance;

  /// Create a copy of MagazineTab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MagazineTabCopyWith<MagazineTab> get copyWith => _$MagazineTabCopyWithImpl<MagazineTab>(this as MagazineTab, _$identity);

  /// Serializes this MagazineTab to a JSON map.
  Map<String, dynamic> toJson();


  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is MagazineTab && (identical(other.id, id) || other.id == id) && (identical(other.name, name) || other.name == name) && (identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder) && (identical(other.isPublic, isPublic) || other.isPublic == isPublic) && (identical(other.aiPreference, aiPreference) || other.aiPreference == aiPreference) && (identical(other.aiPromptId, aiPromptId) || other.aiPromptId == aiPromptId) && (identical(other.minimumImportance, minimumImportance) || other.minimumImportance == minimumImportance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, displayOrder, isPublic, aiPreference, aiPromptId, minimumImportance);

  @override
  String toString() {
    return 'MagazineTab(id: $id, name: $name, displayOrder: $displayOrder, isPublic: $isPublic, aiPreference: $aiPreference, aiPromptId: $aiPromptId, minimumImportance: $minimumImportance)';
  }


}

/// @nodoc
abstract mixin class $MagazineTabCopyWith<$Res> {
  factory $MagazineTabCopyWith(MagazineTab value, $Res Function(MagazineTab) _then) = _$MagazineTabCopyWithImpl;

  @useResult
  $Res call({
    String? id, String name, int displayOrder, bool isPublic, String? aiPreference, String? aiPromptId, int? minimumImportance
  });


}

/// @nodoc
class _$MagazineTabCopyWithImpl<$Res>
    implements $MagazineTabCopyWith<$Res> {
  _$MagazineTabCopyWithImpl(this._self, this._then);

  final MagazineTab _self;
  final $Res Function(MagazineTab) _then;

  /// Create a copy of MagazineTab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = null, Object? displayOrder = null, Object? isPublic = null, Object? aiPreference = freezed, Object? aiPromptId = freezed, Object? minimumImportance = freezed,}) {
    return _then(_self.copyWith(
      id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
      as String?, name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
    as String, displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
    as int, isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
    as bool, aiPreference: freezed == aiPreference ? _self.aiPreference : aiPreference // ignore: cast_nullable_to_non_nullable
    as String?, aiPromptId: freezed == aiPromptId ? _self.aiPromptId : aiPromptId // ignore: cast_nullable_to_non_nullable
    as String?, minimumImportance: freezed == minimumImportance ? _self.minimumImportance : minimumImportance // ignore: cast_nullable_to_non_nullable
    as int?,
    ));
  }

}


/// Adds pattern-matching-related methods to [MagazineTab].
extension MagazineTabPatterns on MagazineTab {
  @optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MagazineTab value)? $default,{required TResult orElse(),}){
  final _that = this;
  switch (_that) {
  case _MagazineTab() when $default != null:
  return $default(_that);case _:
  return orElse();

  }
  }

  @optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MagazineTab value) $default,){
  final _that = this;
  switch (_that) {
  case _MagazineTab():
  return $default(_that);}
  }

  @optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MagazineTab value)? $default,){
  final _that = this;
  switch (_that) {
  case _MagazineTab() when $default != null:
  return $default(_that);case _:
  return null;

  }
  }

  @optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, String name, int displayOrder, bool isPublic, String? aiPreference, String? aiPromptId, int? minimumImportance)? $default,{required TResult orElse(),}) {final _that = this;
  switch (_that) {
  case _MagazineTab() when $default != null:
  return $default(_that.id,_that.name,_that.displayOrder,_that.isPublic,_that.aiPreference,_that.aiPromptId,_that.minimumImportance);case _:
  return orElse();

  }
  }

  @optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, String name, int displayOrder, bool isPublic, String? aiPreference, String? aiPromptId, int? minimumImportance) $default,) {final _that = this;
  switch (_that) {
  case _MagazineTab():
  return $default(_that.id,_that.name,_that.displayOrder,_that.isPublic,_that.aiPreference,_that.aiPromptId,_that.minimumImportance);}
  }

  @optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, String name, int displayOrder, bool isPublic, String? aiPreference, String? aiPromptId, int? minimumImportance)? $default,) {final _that = this;
  switch (_that) {
  case _MagazineTab() when $default != null:
  return $default(_that.id,_that.name,_that.displayOrder,_that.isPublic,_that.aiPreference,_that.aiPromptId,_that.minimumImportance);case _:
  return null;

  }
  }

}

/// @nodoc
@JsonSerializable()
class _MagazineTab implements MagazineTab {
  const _MagazineTab({this.id, required this.name, required this.displayOrder, this.isPublic = false, this.aiPreference, this.aiPromptId, this.minimumImportance});

  factory _MagazineTab.fromJson(Map<String, dynamic> json) => _$MagazineTabFromJson(json);

  @override final String? id;
  @override final String name;
  @override final int displayOrder;
  @override @JsonKey() final bool isPublic;
  @override final String? aiPreference;
  @override final String? aiPromptId;
  @override final int? minimumImportance;

  /// Create a copy of MagazineTab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MagazineTabCopyWith<_MagazineTab> get copyWith => __$MagazineTabCopyWithImpl<_MagazineTab>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MagazineTabToJson(this,);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _MagazineTab && (identical(other.id, id) || other.id == id) && (identical(other.name, name) || other.name == name) && (identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder) && (identical(other.isPublic, isPublic) || other.isPublic == isPublic) && (identical(other.aiPreference, aiPreference) || other.aiPreference == aiPreference) && (identical(other.aiPromptId, aiPromptId) || other.aiPromptId == aiPromptId) && (identical(other.minimumImportance, minimumImportance) || other.minimumImportance == minimumImportance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, displayOrder, isPublic, aiPreference, aiPromptId, minimumImportance);

  @override
  String toString() {
    return 'MagazineTab(id: $id, name: $name, displayOrder: $displayOrder, isPublic: $isPublic, aiPreference: $aiPreference, aiPromptId: $aiPromptId, minimumImportance: $minimumImportance)';
  }


}

/// @nodoc
abstract mixin class _$MagazineTabCopyWith<$Res> implements $MagazineTabCopyWith<$Res> {
  factory _$MagazineTabCopyWith(_MagazineTab value, $Res Function(_MagazineTab) _then) = __$MagazineTabCopyWithImpl;

  @override
  @useResult
  $Res call({
    String? id, String name, int displayOrder, bool isPublic, String? aiPreference, String? aiPromptId, int? minimumImportance
  });


}

/// @nodoc
class __$MagazineTabCopyWithImpl<$Res>
    implements _$MagazineTabCopyWith<$Res> {
  __$MagazineTabCopyWithImpl(this._self, this._then);

  final _MagazineTab _self;
  final $Res Function(_MagazineTab) _then;

  /// Create a copy of MagazineTab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? id = freezed, Object? name = null, Object? displayOrder = null, Object? isPublic = null, Object? aiPreference = freezed, Object? aiPromptId = freezed, Object? minimumImportance = freezed,}) {
    return _then(_MagazineTab(
      id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
      as String?, name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
    as String, displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
    as int, isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
    as bool, aiPreference: freezed == aiPreference ? _self.aiPreference : aiPreference // ignore: cast_nullable_to_non_nullable
    as String?, aiPromptId: freezed == aiPromptId ? _self.aiPromptId : aiPromptId // ignore: cast_nullable_to_non_nullable
    as String?, minimumImportance: freezed == minimumImportance ? _self.minimumImportance : minimumImportance // ignore: cast_nullable_to_non_nullable
    as int?,
    ));
  }


}

// dart format on
