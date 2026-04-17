import 'package:app/user/models/email_digest_frequency.dart';
import 'package:app/user/models/read_item_handling.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

part 'user.g.dart';

@freezed
sealed class User with _$User {
  const factory User({
    String? id,
    String? username,
    String? password,
    String? email,
    String? feedItemPreference,
    String? oidcSub,
    @Default(0) int minimumImportance,
    @Default(false) bool firstTimeSetupDone,
    @Default(ReadItemHandling.none) ReadItemHandling readItemHandling,
    @Default([]) List<EmailDigestFrequency> emailDigest,
    String? gReaderUsername,
    String? gReaderApiPassword,
    String? gReaderUrl,
    String? openAiApiKey,
    String? openAiModel,
    String? openAiUrl,
    bool? enableTextShortening,
    int? openAiMonthlyTokenLimitRelevance,
    int? openAiMonthlyTokenLimitShortening,
    String? aiPromptId,
    @Default(true) bool enableAi,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
