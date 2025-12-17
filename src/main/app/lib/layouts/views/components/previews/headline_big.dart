import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';

class HeadlineBig extends StatelessWidget {
  final LayoutBlock block;
  final Function(LayoutBlock block) onUpdated;

  const HeadlineBig({super.key, required this.block, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: pu2,
      children: [
        PreviewContainer(height: 150, borderRadius: .circular(5)),
        PreviewContainer(height: 30, borderRadius: .circular(20)),
        PreviewContainer(height: 10, borderRadius: .circular(20)),
        PreviewContainer(height: 10, borderRadius: .circular(20)),
        PreviewContainer(height: 10, borderRadius: .circular(20)),
      ],
    );
  }
}
