// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String? get id; String? get username; String? get password; String? get email; String? get feedItemPreference; String? get oidcSub; int get minimumImportance; bool get firstTimeSetupDone; ReadItemHandling get readItemHandling; List<EmailDigestFrequency> get emailDigest; String? get gReaderUsername; String? get gReaderApiPassword; String? get gReaderUrl; String? get openAiApiKey; String? get openAiModel; String? get openAiUrl; String? get aiPromptId;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.email, email) || other.email == email)&&(identical(other.feedItemPreference, feedItemPreference) || other.feedItemPreference == feedItemPreference)&&(identical(other.oidcSub, oidcSub) || other.oidcSub == oidcSub)&&(identical(other.minimumImportance, minimumImportance) || other.minimumImportance == minimumImportance)&&(identical(other.firstTimeSetupDone, firstTimeSetupDone) || other.firstTimeSetupDone == firstTimeSetupDone)&&(identical(other.readItemHandling, readItemHandling) || other.readItemHandling == readItemHandling)&&const DeepCollectionEquality().equals(other.emailDigest, emailDigest)&&(identical(other.gReaderUsername, gReaderUsername) || other.gReaderUsername == gReaderUsername)&&(identical(other.gReaderApiPassword, gReaderApiPassword) || other.gReaderApiPassword == gReaderApiPassword)&&(identical(other.gReaderUrl, gReaderUrl) || other.gReaderUrl == gReaderUrl)&&(identical(other.openAiApiKey, openAiApiKey) || other.openAiApiKey == openAiApiKey)&&(identical(other.openAiModel, openAiModel) || other.openAiModel == openAiModel)&&(identical(other.openAiUrl, openAiUrl) || other.openAiUrl == openAiUrl)&&(identical(other.aiPromptId, aiPromptId) || other.aiPromptId == aiPromptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,password,email,feedItemPreference,oidcSub,minimumImportance,firstTimeSetupDone,readItemHandling,const DeepCollectionEquality().hash(emailDigest),gReaderUsername,gReaderApiPassword,gReaderUrl,openAiApiKey,openAiModel,openAiUrl,aiPromptId);

@override
String toString() {
  return 'User(id: $id, username: $username, password: $password, email: $email, feedItemPreference: $feedItemPreference, oidcSub: $oidcSub, minimumImportance: $minimumImportance, firstTimeSetupDone: $firstTimeSetupDone, readItemHandling: $readItemHandling, emailDigest: $emailDigest, gReaderUsername: $gReaderUsername, gReaderApiPassword: $gReaderApiPassword, gReaderUrl: $gReaderUrl, openAiApiKey: $openAiApiKey, openAiModel: $openAiModel, openAiUrl: $openAiUrl, aiPromptId: $aiPromptId)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String? id, String? username, String? password, String? email, String? feedItemPreference, String? oidcSub, int minimumImportance, bool firstTimeSetupDone, ReadItemHandling readItemHandling, List<EmailDigestFrequency> emailDigest, String? gReaderUsername, String? gReaderApiPassword, String? gReaderUrl, String? openAiApiKey, String? openAiModel, String? openAiUrl, String? aiPromptId
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? username = freezed,Object? password = freezed,Object? email = freezed,Object? feedItemPreference = freezed,Object? oidcSub = freezed,Object? minimumImportance = null,Object? firstTimeSetupDone = null,Object? readItemHandling = null,Object? emailDigest = null,Object? gReaderUsername = freezed,Object? gReaderApiPassword = freezed,Object? gReaderUrl = freezed,Object? openAiApiKey = freezed,Object? openAiModel = freezed,Object? openAiUrl = freezed,Object? aiPromptId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,feedItemPreference: freezed == feedItemPreference ? _self.feedItemPreference : feedItemPreference // ignore: cast_nullable_to_non_nullable
as String?,oidcSub: freezed == oidcSub ? _self.oidcSub : oidcSub // ignore: cast_nullable_to_non_nullable
as String?,minimumImportance: null == minimumImportance ? _self.minimumImportance : minimumImportance // ignore: cast_nullable_to_non_nullable
as int,firstTimeSetupDone: null == firstTimeSetupDone ? _self.firstTimeSetupDone : firstTimeSetupDone // ignore: cast_nullable_to_non_nullable
as bool,readItemHandling: null == readItemHandling ? _self.readItemHandling : readItemHandling // ignore: cast_nullable_to_non_nullable
as ReadItemHandling,emailDigest: null == emailDigest ? _self.emailDigest : emailDigest // ignore: cast_nullable_to_non_nullable
as List<EmailDigestFrequency>,gReaderUsername: freezed == gReaderUsername ? _self.gReaderUsername : gReaderUsername // ignore: cast_nullable_to_non_nullable
as String?,gReaderApiPassword: freezed == gReaderApiPassword ? _self.gReaderApiPassword : gReaderApiPassword // ignore: cast_nullable_to_non_nullable
as String?,gReaderUrl: freezed == gReaderUrl ? _self.gReaderUrl : gReaderUrl // ignore: cast_nullable_to_non_nullable
as String?,openAiApiKey: freezed == openAiApiKey ? _self.openAiApiKey : openAiApiKey // ignore: cast_nullable_to_non_nullable
as String?,openAiModel: freezed == openAiModel ? _self.openAiModel : openAiModel // ignore: cast_nullable_to_non_nullable
as String?,openAiUrl: freezed == openAiUrl ? _self.openAiUrl : openAiUrl // ignore: cast_nullable_to_non_nullable
as String?,aiPromptId: freezed == aiPromptId ? _self.aiPromptId : aiPromptId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? username,  String? password,  String? email,  String? feedItemPreference,  String? oidcSub,  int minimumImportance,  bool firstTimeSetupDone,  ReadItemHandling readItemHandling,  List<EmailDigestFrequency> emailDigest,  String? gReaderUsername,  String? gReaderApiPassword,  String? gReaderUrl,  String? openAiApiKey,  String? openAiModel,  String? openAiUrl,  String? aiPromptId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.password,_that.email,_that.feedItemPreference,_that.oidcSub,_that.minimumImportance,_that.firstTimeSetupDone,_that.readItemHandling,_that.emailDigest,_that.gReaderUsername,_that.gReaderApiPassword,_that.gReaderUrl,_that.openAiApiKey,_that.openAiModel,_that.openAiUrl,_that.aiPromptId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? username,  String? password,  String? email,  String? feedItemPreference,  String? oidcSub,  int minimumImportance,  bool firstTimeSetupDone,  ReadItemHandling readItemHandling,  List<EmailDigestFrequency> emailDigest,  String? gReaderUsername,  String? gReaderApiPassword,  String? gReaderUrl,  String? openAiApiKey,  String? openAiModel,  String? openAiUrl,  String? aiPromptId)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.username,_that.password,_that.email,_that.feedItemPreference,_that.oidcSub,_that.minimumImportance,_that.firstTimeSetupDone,_that.readItemHandling,_that.emailDigest,_that.gReaderUsername,_that.gReaderApiPassword,_that.gReaderUrl,_that.openAiApiKey,_that.openAiModel,_that.openAiUrl,_that.aiPromptId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? username,  String? password,  String? email,  String? feedItemPreference,  String? oidcSub,  int minimumImportance,  bool firstTimeSetupDone,  ReadItemHandling readItemHandling,  List<EmailDigestFrequency> emailDigest,  String? gReaderUsername,  String? gReaderApiPassword,  String? gReaderUrl,  String? openAiApiKey,  String? openAiModel,  String? openAiUrl,  String? aiPromptId)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.password,_that.email,_that.feedItemPreference,_that.oidcSub,_that.minimumImportance,_that.firstTimeSetupDone,_that.readItemHandling,_that.emailDigest,_that.gReaderUsername,_that.gReaderApiPassword,_that.gReaderUrl,_that.openAiApiKey,_that.openAiModel,_that.openAiUrl,_that.aiPromptId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({this.id, this.username, this.password, this.email, this.feedItemPreference, this.oidcSub, this.minimumImportance = 0, this.firstTimeSetupDone = false, this.readItemHandling = ReadItemHandling.none, final  List<EmailDigestFrequency> emailDigest = const [], this.gReaderUsername, this.gReaderApiPassword, this.gReaderUrl, this.openAiApiKey, this.openAiModel, this.openAiUrl, this.aiPromptId}): _emailDigest = emailDigest;
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String? id;
@override final  String? username;
@override final  String? password;
@override final  String? email;
@override final  String? feedItemPreference;
@override final  String? oidcSub;
@override@JsonKey() final  int minimumImportance;
@override@JsonKey() final  bool firstTimeSetupDone;
@override@JsonKey() final  ReadItemHandling readItemHandling;
 final  List<EmailDigestFrequency> _emailDigest;
@override@JsonKey() List<EmailDigestFrequency> get emailDigest {
  if (_emailDigest is EqualUnmodifiableListView) return _emailDigest;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emailDigest);
}

@override final  String? gReaderUsername;
@override final  String? gReaderApiPassword;
@override final  String? gReaderUrl;
@override final  String? openAiApiKey;
@override final  String? openAiModel;
@override final  String? openAiUrl;
@override final  String? aiPromptId;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.email, email) || other.email == email)&&(identical(other.feedItemPreference, feedItemPreference) || other.feedItemPreference == feedItemPreference)&&(identical(other.oidcSub, oidcSub) || other.oidcSub == oidcSub)&&(identical(other.minimumImportance, minimumImportance) || other.minimumImportance == minimumImportance)&&(identical(other.firstTimeSetupDone, firstTimeSetupDone) || other.firstTimeSetupDone == firstTimeSetupDone)&&(identical(other.readItemHandling, readItemHandling) || other.readItemHandling == readItemHandling)&&const DeepCollectionEquality().equals(other._emailDigest, _emailDigest)&&(identical(other.aiPromptId, aiPromptId) || other.aiPromptId == aiPromptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,password,email,feedItemPreference,oidcSub,minimumImportance,firstTimeSetupDone,readItemHandling,const DeepCollectionEquality().hash(_emailDigest),aiPromptId);

@override
String toString() {
  return 'User(id: $id, username: $username, password: $password, email: $email, feedItemPreference: $feedItemPreference, oidcSub: $oidcSub, minimumImportance: $minimumImportance, firstTimeSetupDone: $firstTimeSetupDone, readItemHandling: $readItemHandling, emailDigest: $emailDigest, gReaderUsername: $gReaderUsername, gReaderApiPassword: $gReaderApiPassword, gReaderUrl: $gReaderUrl, openAiApiKey: $openAiApiKey, openAiModel: $openAiModel, openAiUrl: $openAiUrl, aiPromptId: $aiPromptId)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? username, String? password, String? email, String? feedItemPreference, String? oidcSub, int minimumImportance, bool firstTimeSetupDone, ReadItemHandling readItemHandling, List<EmailDigestFrequency> emailDigest, String? gReaderUsername, String? gReaderApiPassword, String? gReaderUrl, String? openAiApiKey, String? openAiModel, String? openAiUrl, String? aiPromptId
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? username = freezed,Object? password = freezed,Object? email = freezed,Object? feedItemPreference = freezed,Object? oidcSub = freezed,Object? minimumImportance = null,Object? firstTimeSetupDone = null,Object? readItemHandling = null,Object? emailDigest = null,Object? gReaderUsername = freezed,Object? gReaderApiPassword = freezed,Object? gReaderUrl = freezed,Object? openAiApiKey = freezed,Object? openAiModel = freezed,Object? openAiUrl = freezed,Object? aiPromptId = freezed,}) {
  return _then(_User(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,feedItemPreference: freezed == feedItemPreference ? _self.feedItemPreference : feedItemPreference // ignore: cast_nullable_to_non_nullable
as String?,oidcSub: freezed == oidcSub ? _self.oidcSub : oidcSub // ignore: cast_nullable_to_non_nullable
as String?,minimumImportance: null == minimumImportance ? _self.minimumImportance : minimumImportance // ignore: cast_nullable_to_non_nullable
as int,firstTimeSetupDone: null == firstTimeSetupDone ? _self.firstTimeSetupDone : firstTimeSetupDone // ignore: cast_nullable_to_non_nullable
as bool,readItemHandling: null == readItemHandling ? _self.readItemHandling : readItemHandling // ignore: cast_nullable_to_non_nullable
as ReadItemHandling,emailDigest: null == emailDigest ? _self._emailDigest : emailDigest // ignore: cast_nullable_to_non_nullable
as List<EmailDigestFrequency>,gReaderUsername: freezed == gReaderUsername ? _self.gReaderUsername : gReaderUsername // ignore: cast_nullable_to_non_nullable
as String?,gReaderApiPassword: freezed == gReaderApiPassword ? _self.gReaderApiPassword : gReaderApiPassword // ignore: cast_nullable_to_non_nullable
as String?,gReaderUrl: freezed == gReaderUrl ? _self.gReaderUrl : gReaderUrl // ignore: cast_nullable_to_non_nullable
as String?,openAiApiKey: freezed == openAiApiKey ? _self.openAiApiKey : openAiApiKey // ignore: cast_nullable_to_non_nullable
as String?,openAiModel: freezed == openAiModel ? _self.openAiModel : openAiModel // ignore: cast_nullable_to_non_nullable
as String?,openAiUrl: freezed == openAiUrl ? _self.openAiUrl : openAiUrl // ignore: cast_nullable_to_non_nullable
as String?,aiPromptId: freezed == aiPromptId ? _self.aiPromptId : aiPromptId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
