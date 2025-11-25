// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedItem {

 String? get id; String? get guid; String? get title; String? get description; String? get content; String? get reasoning; String? get imageUrl; int get importance; int get timeCreated; Feed? get feed;
/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedItemCopyWith<FeedItem> get copyWith => _$FeedItemCopyWithImpl<FeedItem>(this as FeedItem, _$identity);

  /// Serializes this FeedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.guid, guid) || other.guid == guid)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.importance, importance) || other.importance == importance)&&(identical(other.timeCreated, timeCreated) || other.timeCreated == timeCreated)&&(identical(other.feed, feed) || other.feed == feed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guid,title,description,content,reasoning,imageUrl,importance,timeCreated,feed);

@override
String toString() {
  return 'FeedItem(id: $id, guid: $guid, title: $title, description: $description, content: $content, reasoning: $reasoning, imageUrl: $imageUrl, importance: $importance, timeCreated: $timeCreated, feed: $feed)';
}


}

/// @nodoc
abstract mixin class $FeedItemCopyWith<$Res>  {
  factory $FeedItemCopyWith(FeedItem value, $Res Function(FeedItem) _then) = _$FeedItemCopyWithImpl;
@useResult
$Res call({
 String? id, String? guid, String? title, String? description, String? content, String? reasoning, String? imageUrl, int importance, int timeCreated, Feed? feed
});


$FeedCopyWith<$Res>? get feed;

}
/// @nodoc
class _$FeedItemCopyWithImpl<$Res>
    implements $FeedItemCopyWith<$Res> {
  _$FeedItemCopyWithImpl(this._self, this._then);

  final FeedItem _self;
  final $Res Function(FeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? guid = freezed,Object? title = freezed,Object? description = freezed,Object? content = freezed,Object? reasoning = freezed,Object? imageUrl = freezed,Object? importance = null,Object? timeCreated = null,Object? feed = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,guid: freezed == guid ? _self.guid : guid // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,reasoning: freezed == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,importance: null == importance ? _self.importance : importance // ignore: cast_nullable_to_non_nullable
as int,timeCreated: null == timeCreated ? _self.timeCreated : timeCreated // ignore: cast_nullable_to_non_nullable
as int,feed: freezed == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as Feed?,
  ));
}
/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeedCopyWith<$Res>? get feed {
    if (_self.feed == null) {
    return null;
  }

  return $FeedCopyWith<$Res>(_self.feed!, (value) {
    return _then(_self.copyWith(feed: value));
  });
}
}


/// Adds pattern-matching-related methods to [FeedItem].
extension FeedItemPatterns on FeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedItem value)  $default,){
final _that = this;
switch (_that) {
case _FeedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedItem value)?  $default,){
final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? guid,  String? title,  String? description,  String? content,  String? reasoning,  String? imageUrl,  int importance,  int timeCreated,  Feed? feed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
return $default(_that.id,_that.guid,_that.title,_that.description,_that.content,_that.reasoning,_that.imageUrl,_that.importance,_that.timeCreated,_that.feed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? guid,  String? title,  String? description,  String? content,  String? reasoning,  String? imageUrl,  int importance,  int timeCreated,  Feed? feed)  $default,) {final _that = this;
switch (_that) {
case _FeedItem():
return $default(_that.id,_that.guid,_that.title,_that.description,_that.content,_that.reasoning,_that.imageUrl,_that.importance,_that.timeCreated,_that.feed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? guid,  String? title,  String? description,  String? content,  String? reasoning,  String? imageUrl,  int importance,  int timeCreated,  Feed? feed)?  $default,) {final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
return $default(_that.id,_that.guid,_that.title,_that.description,_that.content,_that.reasoning,_that.imageUrl,_that.importance,_that.timeCreated,_that.feed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedItem implements FeedItem {
  const _FeedItem({this.id, this.guid, this.title, this.description, this.content, this.reasoning, this.imageUrl, this.importance = 0, this.timeCreated = 0, this.feed});
  factory _FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);

@override final  String? id;
@override final  String? guid;
@override final  String? title;
@override final  String? description;
@override final  String? content;
@override final  String? reasoning;
@override final  String? imageUrl;
@override@JsonKey() final  int importance;
@override@JsonKey() final  int timeCreated;
@override final  Feed? feed;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemCopyWith<_FeedItem> get copyWith => __$FeedItemCopyWithImpl<_FeedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.guid, guid) || other.guid == guid)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.importance, importance) || other.importance == importance)&&(identical(other.timeCreated, timeCreated) || other.timeCreated == timeCreated)&&(identical(other.feed, feed) || other.feed == feed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guid,title,description,content,reasoning,imageUrl,importance,timeCreated,feed);

@override
String toString() {
  return 'FeedItem(id: $id, guid: $guid, title: $title, description: $description, content: $content, reasoning: $reasoning, imageUrl: $imageUrl, importance: $importance, timeCreated: $timeCreated, feed: $feed)';
}


}

/// @nodoc
abstract mixin class _$FeedItemCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemCopyWith(_FeedItem value, $Res Function(_FeedItem) _then) = __$FeedItemCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? guid, String? title, String? description, String? content, String? reasoning, String? imageUrl, int importance, int timeCreated, Feed? feed
});


@override $FeedCopyWith<$Res>? get feed;

}
/// @nodoc
class __$FeedItemCopyWithImpl<$Res>
    implements _$FeedItemCopyWith<$Res> {
  __$FeedItemCopyWithImpl(this._self, this._then);

  final _FeedItem _self;
  final $Res Function(_FeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? guid = freezed,Object? title = freezed,Object? description = freezed,Object? content = freezed,Object? reasoning = freezed,Object? imageUrl = freezed,Object? importance = null,Object? timeCreated = null,Object? feed = freezed,}) {
  return _then(_FeedItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,guid: freezed == guid ? _self.guid : guid // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,reasoning: freezed == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,importance: null == importance ? _self.importance : importance // ignore: cast_nullable_to_non_nullable
as int,timeCreated: null == timeCreated ? _self.timeCreated : timeCreated // ignore: cast_nullable_to_non_nullable
as int,feed: freezed == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as Feed?,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeedCopyWith<$Res>? get feed {
    if (_self.feed == null) {
    return null;
  }

  return $FeedCopyWith<$Res>(_self.feed!, (value) {
    return _then(_self.copyWith(feed: value));
  });
}
}

// dart format on
