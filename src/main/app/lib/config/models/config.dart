import 'package:app/config/models/oidc_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

@freezed
sealed class Config with _$Config {
  const factory Config({
    @Default(false) bool demoMode,
    required String backendVersion,
    required bool allowSignup,
    OidcConfig? oidcConfig,
    @Default("") String announcement,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);
}
