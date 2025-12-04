import 'package:app/layouts/models/layout_block_settings.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'layout_block.freezed.dart';
part 'layout_block.g.dart';

@freezed
sealed class LayoutBlock with _$LayoutBlock {
  const factory LayoutBlock({
String? id,
   required LayoutBlockTypes type,
    required int order, LayoutBlockSettings? settings

  }) = _LayoutBlock;

  factory LayoutBlock.fromJson(Map<String, Object?> json)
      => _$LayoutBlockFromJson(json);
}