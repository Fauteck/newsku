import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:flutter/material.dart';

class SmallGridSmall extends StatelessWidget {
  const SmallGridSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: smallPreviewSize,
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 0,
        childAspectRatio: 16/9,
        children: [
          _GridItem(),
          _GridItem(),
          _GridItem(),
          _GridItem()
        ],
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .center,
      spacing: 8,
      children: [
        Expanded(
          child: Column(
            spacing: 4,
            mainAxisAlignment: .center,
            children: [
              PreviewContainer(height: 5, borderRadius: .circular(5)),
              PreviewContainer(height: 5, borderRadius: .circular(5)),
              PreviewContainer(height: 2, borderRadius: .circular(5)),
              PreviewContainer(height: 2, borderRadius: .circular(5)),
            ],
          ),
        ),
        PreviewContainer(
          height: 30,
          width: 12, borderRadius: .circular(2),)
      ],
    );
  }
}

