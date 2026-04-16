import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';

class HeadlinePictureBig extends StatelessWidget {
  final LayoutBlock block;

  const HeadlinePictureBig({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        PreviewContainer(
          height: 150,
          borderRadius: .circular(5),
          child: Padding(
            padding: EdgeInsets.all(pu2),
            child: Column(
              mainAxisAlignment: .end,
              spacing: pu,
              children: [
                PreviewContainer(height: 15, borderRadius: .circular(10), color: colors.surface),
                PreviewContainer(height: 15, borderRadius: .circular(10), color: colors.surface),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
