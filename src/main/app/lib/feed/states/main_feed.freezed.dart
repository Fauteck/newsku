// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_feed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MainFeedState {

 Paginated<FeedItem> get items; bool get loading;
/// Create a copy of MainFeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MainFeedStateCopyWith<MainFeedState> get copyWith => _$MainFeedStateCopyWithImpl<MainFeedState>(this as MainFeedState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MainFeedState&&(identical(other.items, items) || other.items == items)&&(identical(other.loading, loading) || other.loading == loading));
}


@override
int get hashCode => Object.hash(runtimeType,items,loading);

@override
String toString() {
  return 'MainFeedState(items: $items, loading: $loading)';
}


}

/// @nodoc
abstract mixin class $MainFeedStateCopyWith<$Res>  {
  factory $MainFeedStateCopyWith(MainFeedState value, $Res Function(MainFeedState) _then) = _$MainFeedStateCopyWithImpl;
@useResult
$Res call({
 Paginated<FeedItem> items, bool loading
});


$PaginatedCopyWith<FeedItem, $Res> get items;

}
/// @nodoc
class _$MainFeedStateCopyWithImpl<$Res>
    implements $MainFeedStateCopyWith<$Res> {
  _$MainFeedStateCopyWithImpl(this._self, this._then);

  final MainFeedState _self;
  final $Res Function(MainFeedState) _then;

/// Create a copy of MainFeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? loading = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as Paginated<FeedItem>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MainFeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedCopyWith<FeedItem, $Res> get items {
  
  return $PaginatedCopyWith<FeedItem, $Res>(_self.items, (value) {
    return _then(_self.copyWith(items: value));
  });
}
}


/// Adds pattern-matching-related methods to [MainFeedState].
extension MainFeedStatePatterns on MainFeedState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MainFeedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MainFeedState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MainFeedState value)  $default,){
final _that = this;
switch (_that) {
case _MainFeedState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MainFeedState value)?  $default,){
final _that = this;
switch (_that) {
case _MainFeedState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Paginated<FeedItem> items,  bool loading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MainFeedState() when $default != null:
return $default(_that.items,_that.loading);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Paginated<FeedItem> items,  bool loading)  $default,) {final _that = this;
switch (_that) {
case _MainFeedState():
return $default(_that.items,_that.loading);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Paginated<FeedItem> items,  bool loading)?  $default,) {final _that = this;
switch (_that) {
case _MainFeedState() when $default != null:
return $default(_that.items,_that.loading);case _:
  return null;

}
}

}

/// @nodoc


class _MainFeedState implements MainFeedState {
  const _MainFeedState({this.items = const Paginated<FeedItem>(), this.loading = true});
  

@override@JsonKey() final  Paginated<FeedItem> items;
@override@JsonKey() final  bool loading;

/// Create a copy of MainFeedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MainFeedStateCopyWith<_MainFeedState> get copyWith => __$MainFeedStateCopyWithImpl<_MainFeedState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MainFeedState&&(identical(other.items, items) || other.items == items)&&(identical(other.loading, loading) || other.loading == loading));
}


@override
int get hashCode => Object.hash(runtimeType,items,loading);

@override
String toString() {
  return 'MainFeedState(items: $items, loading: $loading)';
}


}

/// @nodoc
abstract mixin class _$MainFeedStateCopyWith<$Res> implements $MainFeedStateCopyWith<$Res> {
  factory _$MainFeedStateCopyWith(_MainFeedState value, $Res Function(_MainFeedState) _then) = __$MainFeedStateCopyWithImpl;
@override @useResult
$Res call({
 Paginated<FeedItem> items, bool loading
});


@override $PaginatedCopyWith<FeedItem, $Res> get items;

}
/// @nodoc
class __$MainFeedStateCopyWithImpl<$Res>
    implements _$MainFeedStateCopyWith<$Res> {
  __$MainFeedStateCopyWithImpl(this._self, this._then);

  final _MainFeedState _self;
  final $Res Function(_MainFeedState) _then;

/// Create a copy of MainFeedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? loading = null,}) {
  return _then(_MainFeedState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as Paginated<FeedItem>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MainFeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedCopyWith<FeedItem, $Res> get items {
  
  return $PaginatedCopyWith<FeedItem, $Res>(_self.items, (value) {
    return _then(_self.copyWith(items: value));
  });
}
}

// dart format on
