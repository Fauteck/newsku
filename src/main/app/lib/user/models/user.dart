import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class User with _$User {
  const factory User({String? id, String? username, String? password, String? email, String? feedItemPreference, String? oidcSub, @Default(0) int minimumImportance, @Default(false) bool dimReadItems}) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
