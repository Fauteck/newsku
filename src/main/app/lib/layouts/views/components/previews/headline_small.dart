import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:flutter/material.dart';

class HeadlineSmall extends StatelessWidget {
  const HeadlineSmall({super.key});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: smallPreviewSize,
      child: Column(
        spacing: 4,
        children: [PreviewContainer(width: smallPreviewSize, height: smallPreviewSize / 3, borderRadius: .circular(5)),

        PreviewContainer(
            width: smallPreviewSize,
            height: 10,
            borderRadius: .circular(20)),
          PreviewContainer(
              width: smallPreviewSize,
              height: 2,
              borderRadius: .circular(20)),
          PreviewContainer(
              width: smallPreviewSize,
              height: 2,
              borderRadius: .circular(20)),
          PreviewContainer(
              width: smallPreviewSize,
              height: 2,
              borderRadius: .circular(20)),
        ],
      ),
    );
  }
}
