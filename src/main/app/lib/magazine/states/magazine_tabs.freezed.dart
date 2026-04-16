// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'magazine_tabs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MagazineTabsState {

 List<MagazineTab> get tabs; MagazineTab? get selectedTab; bool get loading; dynamic get error; StackTrace? get stackTrace;
/// Create a copy of MagazineTabsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MagazineTabsStateCopyWith<MagazineTabsState> get copyWith => _$MagazineTabsStateCopyWithImpl<MagazineTabsState>(this as MagazineTabsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MagazineTabsState&&const DeepCollectionEquality().equals(other.tabs, tabs)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tabs),selectedTab,loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'MagazineTabsState(tabs: $tabs, selectedTab: $selectedTab, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $MagazineTabsStateCopyWith<$Res>  {
  factory $MagazineTabsStateCopyWith(MagazineTabsState value, $Res Function(MagazineTabsState) _then) = _$MagazineTabsStateCopyWithImpl;
@useResult
$Res call({
 List<MagazineTab> tabs, MagazineTab? selectedTab, bool loading, dynamic error, StackTrace? stackTrace
});


$MagazineTabCopyWith<$Res>? get selectedTab;

}
/// @nodoc
class _$MagazineTabsStateCopyWithImpl<$Res>
    implements $MagazineTabsStateCopyWith<$Res> {
  _$MagazineTabsStateCopyWithImpl(this._self, this._then);

  final MagazineTabsState _self;
  final $Res Function(MagazineTabsState) _then;

/// Create a copy of MagazineTabsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tabs = null,Object? selectedTab = freezed,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_self.copyWith(
tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<MagazineTab>,selectedTab: freezed == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as MagazineTab?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}
/// Create a copy of MagazineTabsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MagazineTabCopyWith<$Res>? get selectedTab {
    if (_self.selectedTab == null) {
    return null;
  }

  return $MagazineTabCopyWith<$Res>(_self.selectedTab!, (value) {
    return _then(_self.copyWith(selectedTab: value));
  });
}
}


/// Adds pattern-matching-related methods to [MagazineTabsState].
extension MagazineTabsStatePatterns on MagazineTabsState {
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MagazineTabsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MagazineTabsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MagazineTabsState value)  $default,){
final _that = this;
switch (_that) {
case _MagazineTabsState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MagazineTabsState value)?  $default,){
final _that = this;
switch (_that) {
case _MagazineTabsState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MagazineTab> tabs,  MagazineTab? selectedTab,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MagazineTabsState() when $default != null:
return $default(_that.tabs,_that.selectedTab,_that.loading,_that.error,_that.stackTrace);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MagazineTab> tabs,  MagazineTab? selectedTab,  bool loading,  dynamic error,  StackTrace? stackTrace)  $default,) {final _that = this;
switch (_that) {
case _MagazineTabsState():
return $default(_that.tabs,_that.selectedTab,_that.loading,_that.error,_that.stackTrace);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MagazineTab> tabs,  MagazineTab? selectedTab,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,) {final _that = this;
switch (_that) {
case _MagazineTabsState() when $default != null:
return $default(_that.tabs,_that.selectedTab,_that.loading,_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _MagazineTabsState implements MagazineTabsState, WithError {
  const _MagazineTabsState({final  List<MagazineTab> tabs = const [], this.selectedTab, this.loading = false, this.error, this.stackTrace}): _tabs = tabs;


 final  List<MagazineTab> _tabs;
@override@JsonKey() List<MagazineTab> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

@override final  MagazineTab? selectedTab;
@override@JsonKey() final  bool loading;
@override final  dynamic error;
@override final  StackTrace? stackTrace;

/// Create a copy of MagazineTabsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MagazineTabsStateCopyWith<_MagazineTabsState> get copyWith => __$MagazineTabsStateCopyWithImpl<_MagazineTabsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MagazineTabsState&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tabs),selectedTab,loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'MagazineTabsState(tabs: $tabs, selectedTab: $selectedTab, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$MagazineTabsStateCopyWith<$Res> implements $MagazineTabsStateCopyWith<$Res> {
  factory _$MagazineTabsStateCopyWith(_MagazineTabsState value, $Res Function(_MagazineTabsState) _then) = __$MagazineTabsStateCopyWithImpl;
@override @useResult
$Res call({
 List<MagazineTab> tabs, MagazineTab? selectedTab, bool loading, dynamic error, StackTrace? stackTrace
});


@override $MagazineTabCopyWith<$Res>? get selectedTab;

}
/// @nodoc
class __$MagazineTabsStateCopyWithImpl<$Res>
    implements _$MagazineTabsStateCopyWith<$Res> {
  __$MagazineTabsStateCopyWithImpl(this._self, this._then);

  final _MagazineTabsState _self;
  final $Res Function(_MagazineTabsState) _then;

/// Create a copy of MagazineTabsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tabs = null,Object? selectedTab = freezed,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_MagazineTabsState(
tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<MagazineTab>,selectedTab: freezed == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as MagazineTab?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}

/// Create a copy of MagazineTabsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MagazineTabCopyWith<$Res>? get selectedTab {
    if (_self.selectedTab == null) {
    return null;
  }

  return $MagazineTabCopyWith<$Res>(_self.selectedTab!, (value) {
    return _then(_self.copyWith(selectedTab: value));
  });
}
}

// dart format on
