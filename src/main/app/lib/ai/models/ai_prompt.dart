import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_prompt.freezed.dart';
part 'ai_prompt.g.dart';

@freezed
sealed class AiPrompt with _$AiPrompt {
  const factory AiPrompt({
    String? id,
    required String name,
    required String content,
  }) = _AiPrompt;

  factory AiPrompt.fromJson(Map<String, Object?> json) => _$AiPromptFromJson(json);
}
