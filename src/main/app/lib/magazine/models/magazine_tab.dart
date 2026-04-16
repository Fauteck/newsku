import 'package:freezed_annotation/freezed_annotation.dart';

part 'magazine_tab.freezed.dart';
part 'magazine_tab.g.dart';

@freezed
sealed class MagazineTab with _$MagazineTab {
  const factory MagazineTab({
    String? id,
    required String name,
    required int displayOrder,
    @Default(false) bool isPublic,
    String? aiPreference,
    int? minimumImportance,
  }) = _MagazineTab;

  factory MagazineTab.fromJson(Map<String, Object?> json) => _$MagazineTabFromJson(json);
}
