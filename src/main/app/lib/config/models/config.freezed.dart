// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Config {

 bool get demoMode; String get backendVersion; bool get allowSignup; bool get canResetPassword; OidcConfig? get oidcConfig; String get announcement; String? get freshRssUrl;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);

  /// Serializes this Config to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&(identical(other.demoMode, demoMode) || other.demoMode == demoMode)&&(identical(other.backendVersion, backendVersion) || other.backendVersion == backendVersion)&&(identical(other.allowSignup, allowSignup) || other.allowSignup == allowSignup)&&(identical(other.canResetPassword, canResetPassword) || other.canResetPassword == canResetPassword)&&(identical(other.oidcConfig, oidcConfig) || other.oidcConfig == oidcConfig)&&(identical(other.announcement, announcement) || other.announcement == announcement)&&(identical(other.freshRssUrl, freshRssUrl) || other.freshRssUrl == freshRssUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,demoMode,backendVersion,allowSignup,canResetPassword,oidcConfig,announcement,freshRssUrl);

@override
String toString() {
  return 'Config(demoMode: $demoMode, backendVersion: $backendVersion, allowSignup: $allowSignup, canResetPassword: $canResetPassword, oidcConfig: $oidcConfig, announcement: $announcement, freshRssUrl: $freshRssUrl)';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
 bool demoMode, String backendVersion, bool allowSignup, bool canResetPassword, OidcConfig? oidcConfig, String announcement, String? freshRssUrl
});


$OidcConfigCopyWith<$Res>? get oidcConfig;

}
/// @nodoc
class _$ConfigCopyWithImpl<$Res>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._self, this._then);

  final Config _self;
  final $Res Function(Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? demoMode = null,Object? backendVersion = null,Object? allowSignup = null,Object? canResetPassword = null,Object? oidcConfig = freezed,Object? announcement = null,Object? freshRssUrl = freezed,}) {
  return _then(_self.copyWith(
demoMode: null == demoMode ? _self.demoMode : demoMode // ignore: cast_nullable_to_non_nullable
as bool,backendVersion: null == backendVersion ? _self.backendVersion : backendVersion // ignore: cast_nullable_to_non_nullable
as String,allowSignup: null == allowSignup ? _self.allowSignup : allowSignup // ignore: cast_nullable_to_non_nullable
as bool,canResetPassword: null == canResetPassword ? _self.canResetPassword : canResetPassword // ignore: cast_nullable_to_non_nullable
as bool,oidcConfig: freezed == oidcConfig ? _self.oidcConfig : oidcConfig // ignore: cast_nullable_to_non_nullable
as OidcConfig?,announcement: null == announcement ? _self.announcement : announcement // ignore: cast_nullable_to_non_nullable
as String,freshRssUrl: freezed == freshRssUrl ? _self.freshRssUrl : freshRssUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OidcConfigCopyWith<$Res>? get oidcConfig {
    if (_self.oidcConfig == null) {
    return null;
  }

  return $OidcConfigCopyWith<$Res>(_self.oidcConfig!, (value) {
    return _then(_self.copyWith(oidcConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [Config].
extension ConfigPatterns on Config {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Config value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Config value)  $default,){
final _that = this;
switch (_that) {
case _Config():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Config value)?  $default,){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool demoMode,  String backendVersion,  bool allowSignup,  bool canResetPassword,  OidcConfig? oidcConfig,  String announcement,  String? freshRssUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.demoMode,_that.backendVersion,_that.allowSignup,_that.canResetPassword,_that.oidcConfig,_that.announcement,_that.freshRssUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool demoMode,  String backendVersion,  bool allowSignup,  bool canResetPassword,  OidcConfig? oidcConfig,  String announcement,  String? freshRssUrl)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.demoMode,_that.backendVersion,_that.allowSignup,_that.canResetPassword,_that.oidcConfig,_that.announcement,_that.freshRssUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool demoMode,  String backendVersion,  bool allowSignup,  bool canResetPassword,  OidcConfig? oidcConfig,  String announcement,  String? freshRssUrl)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.demoMode,_that.backendVersion,_that.allowSignup,_that.canResetPassword,_that.oidcConfig,_that.announcement,_that.freshRssUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Config implements Config {
  const _Config({this.demoMode = false, required this.backendVersion, required this.allowSignup, this.canResetPassword = false, this.oidcConfig, this.announcement = "", this.freshRssUrl});
  factory _Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

@override@JsonKey() final  bool demoMode;
@override final  String backendVersion;
@override final  bool allowSignup;
@override@JsonKey() final  bool canResetPassword;
@override final  OidcConfig? oidcConfig;
@override@JsonKey() final  String announcement;
@override final  String? freshRssUrl;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigCopyWith<_Config> get copyWith => __$ConfigCopyWithImpl<_Config>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&(identical(other.demoMode, demoMode) || other.demoMode == demoMode)&&(identical(other.backendVersion, backendVersion) || other.backendVersion == backendVersion)&&(identical(other.allowSignup, allowSignup) || other.allowSignup == allowSignup)&&(identical(other.canResetPassword, canResetPassword) || other.canResetPassword == canResetPassword)&&(identical(other.oidcConfig, oidcConfig) || other.oidcConfig == oidcConfig)&&(identical(other.announcement, announcement) || other.announcement == announcement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,demoMode,backendVersion,allowSignup,canResetPassword,oidcConfig,announcement,freshRssUrl);

@override
String toString() {
  return 'Config(demoMode: $demoMode, backendVersion: $backendVersion, allowSignup: $allowSignup, canResetPassword: $canResetPassword, oidcConfig: $oidcConfig, announcement: $announcement, freshRssUrl: $freshRssUrl)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
 bool demoMode, String backendVersion, bool allowSignup, bool canResetPassword, OidcConfig? oidcConfig, String announcement, String? freshRssUrl
});


@override $OidcConfigCopyWith<$Res>? get oidcConfig;

}
/// @nodoc
class __$ConfigCopyWithImpl<$Res>
    implements _$ConfigCopyWith<$Res> {
  __$ConfigCopyWithImpl(this._self, this._then);

  final _Config _self;
  final $Res Function(_Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? demoMode = null,Object? backendVersion = null,Object? allowSignup = null,Object? canResetPassword = null,Object? oidcConfig = freezed,Object? announcement = null,Object? freshRssUrl = freezed,}) {
  return _then(_Config(
demoMode: null == demoMode ? _self.demoMode : demoMode // ignore: cast_nullable_to_non_nullable
as bool,backendVersion: null == backendVersion ? _self.backendVersion : backendVersion // ignore: cast_nullable_to_non_nullable
as String,allowSignup: null == allowSignup ? _self.allowSignup : allowSignup // ignore: cast_nullable_to_non_nullable
as bool,canResetPassword: null == canResetPassword ? _self.canResetPassword : canResetPassword // ignore: cast_nullable_to_non_nullable
as bool,oidcConfig: freezed == oidcConfig ? _self.oidcConfig : oidcConfig // ignore: cast_nullable_to_non_nullable
as OidcConfig?,announcement: null == announcement ? _self.announcement : announcement // ignore: cast_nullable_to_non_nullable
as String,freshRssUrl: freezed == freshRssUrl ? _self.freshRssUrl : freshRssUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OidcConfigCopyWith<$Res>? get oidcConfig {
    if (_self.oidcConfig == null) {
    return null;
  }

  return $OidcConfigCopyWith<$Res>(_self.oidcConfig!, (value) {
    return _then(_self.copyWith(oidcConfig: value));
  });
}
}

// dart format on
