import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:flutter/material.dart';

class HeadlinePictureSmall extends StatelessWidget {
  const HeadlinePictureSmall({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: smallPreviewSize,
      child: PreviewContainer(
        height: 80,
        borderRadius: .circular(5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: .end,
            spacing: 4,
            children: [
              PreviewContainer(height: 10, borderRadius: .circular(10), color: colors.surface),
              PreviewContainer(height: 10, borderRadius: .circular(10), color: colors.surface),
            ],
          ),
        ),
      ),
    );
  }
}
