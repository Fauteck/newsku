// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'magazine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MagazineSettingsState {

 List<MagazineTab> get tabs; MagazineTab? get selectedTab; List<LayoutBlock> get tabLayout; bool get loading; dynamic get error; StackTrace? get stackTrace;
/// Create a copy of MagazineSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MagazineSettingsStateCopyWith<MagazineSettingsState> get copyWith => _$MagazineSettingsStateCopyWithImpl<MagazineSettingsState>(this as MagazineSettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MagazineSettingsState&&const DeepCollectionEquality().equals(other.tabs, tabs)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&const DeepCollectionEquality().equals(other.tabLayout, tabLayout)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tabs),selectedTab,const DeepCollectionEquality().hash(tabLayout),loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'MagazineSettingsState(tabs: $tabs, selectedTab: $selectedTab, tabLayout: $tabLayout, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $MagazineSettingsStateCopyWith<$Res>  {
  factory $MagazineSettingsStateCopyWith(MagazineSettingsState value, $Res Function(MagazineSettingsState) _then) = _$MagazineSettingsStateCopyWithImpl;
@useResult
$Res call({
 List<MagazineTab> tabs, MagazineTab? selectedTab, List<LayoutBlock> tabLayout, bool loading, dynamic error, StackTrace? stackTrace
});


$MagazineTabCopyWith<$Res>? get selectedTab;

}
/// @nodoc
class _$MagazineSettingsStateCopyWithImpl<$Res>
    implements $MagazineSettingsStateCopyWith<$Res> {
  _$MagazineSettingsStateCopyWithImpl(this._self, this._then);

  final MagazineSettingsState _self;
  final $Res Function(MagazineSettingsState) _then;

/// Create a copy of MagazineSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tabs = null,Object? selectedTab = freezed,Object? tabLayout = null,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_self.copyWith(
tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<MagazineTab>,selectedTab: freezed == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as MagazineTab?,tabLayout: null == tabLayout ? _self.tabLayout : tabLayout // ignore: cast_nullable_to_non_nullable
as List<LayoutBlock>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}
/// Create a copy of MagazineSettingsState
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


/// Adds pattern-matching-related methods to [MagazineSettingsState].
extension MagazineSettingsStatePatterns on MagazineSettingsState {
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MagazineSettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MagazineSettingsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MagazineSettingsState value)  $default,){
final _that = this;
switch (_that) {
case _MagazineSettingsState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MagazineSettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _MagazineSettingsState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MagazineTab> tabs,  MagazineTab? selectedTab,  List<LayoutBlock> tabLayout,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MagazineSettingsState() when $default != null:
return $default(_that.tabs,_that.selectedTab,_that.tabLayout,_that.loading,_that.error,_that.stackTrace);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MagazineTab> tabs,  MagazineTab? selectedTab,  List<LayoutBlock> tabLayout,  bool loading,  dynamic error,  StackTrace? stackTrace)  $default,) {final _that = this;
switch (_that) {
case _MagazineSettingsState():
return $default(_that.tabs,_that.selectedTab,_that.tabLayout,_that.loading,_that.error,_that.stackTrace);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MagazineTab> tabs,  MagazineTab? selectedTab,  List<LayoutBlock> tabLayout,  bool loading,  dynamic error,  StackTrace? stackTrace)?  $default,) {final _that = this;
switch (_that) {
case _MagazineSettingsState() when $default != null:
return $default(_that.tabs,_that.selectedTab,_that.tabLayout,_that.loading,_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _MagazineSettingsState implements MagazineSettingsState, WithError {
  const _MagazineSettingsState({final  List<MagazineTab> tabs = const [], this.selectedTab, final  List<LayoutBlock> tabLayout = const [], this.loading = false, this.error, this.stackTrace}): _tabs = tabs,_tabLayout = tabLayout;


 final  List<MagazineTab> _tabs;
@override@JsonKey() List<MagazineTab> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

@override final  MagazineTab? selectedTab;
 final  List<LayoutBlock> _tabLayout;
@override@JsonKey() List<LayoutBlock> get tabLayout {
  if (_tabLayout is EqualUnmodifiableListView) return _tabLayout;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabLayout);
}

@override@JsonKey() final  bool loading;
@override final  dynamic error;
@override final  StackTrace? stackTrace;

/// Create a copy of MagazineSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MagazineSettingsStateCopyWith<_MagazineSettingsState> get copyWith => __$MagazineSettingsStateCopyWithImpl<_MagazineSettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MagazineSettingsState&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&const DeepCollectionEquality().equals(other._tabLayout, _tabLayout)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tabs),selectedTab,const DeepCollectionEquality().hash(_tabLayout),loading,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'MagazineSettingsState(tabs: $tabs, selectedTab: $selectedTab, tabLayout: $tabLayout, loading: $loading, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$MagazineSettingsStateCopyWith<$Res> implements $MagazineSettingsStateCopyWith<$Res> {
  factory _$MagazineSettingsStateCopyWith(_MagazineSettingsState value, $Res Function(_MagazineSettingsState) _then) = __$MagazineSettingsStateCopyWithImpl;
@override @useResult
$Res call({
 List<MagazineTab> tabs, MagazineTab? selectedTab, List<LayoutBlock> tabLayout, bool loading, dynamic error, StackTrace? stackTrace
});


@override $MagazineTabCopyWith<$Res>? get selectedTab;

}
/// @nodoc
class __$MagazineSettingsStateCopyWithImpl<$Res>
    implements _$MagazineSettingsStateCopyWith<$Res> {
  __$MagazineSettingsStateCopyWithImpl(this._self, this._then);

  final _MagazineSettingsState _self;
  final $Res Function(_MagazineSettingsState) _then;

/// Create a copy of MagazineSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tabs = null,Object? selectedTab = freezed,Object? tabLayout = null,Object? loading = null,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(_MagazineSettingsState(
tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<MagazineTab>,selectedTab: freezed == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as MagazineTab?,tabLayout: null == tabLayout ? _self._tabLayout : tabLayout // ignore: cast_nullable_to_non_nullable
as List<LayoutBlock>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}

/// Create a copy of MagazineSettingsState
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
