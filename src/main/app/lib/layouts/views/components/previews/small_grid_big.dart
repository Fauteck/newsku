import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';

class SmallGridBig extends StatelessWidget {
  final bool last;
  final LayoutBlock block;

  const SmallGridBig({super.key, required this.block, required this.last});

  @override
  Widget build(BuildContext context) {
    final device = BreakPoint.get(context);
    final itemCount = last ? 6 : (block.settings ?? block.type.defaultSettings).items ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 0,
      childAspectRatio: 16 / (device == .mobile ? 8 : 5),
      children: List.generate(itemCount, (index) => _GridItem()),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .center,
      spacing: pu2,
      children: [
        Expanded(
          child: Column(
            spacing: pu,
            mainAxisAlignment: .center,
            children: [
              PreviewContainer(height: 8, borderRadius: .circular(5)),
              PreviewContainer(height: 8, borderRadius: .circular(5)),
              PreviewContainer(height: 4, borderRadius: .circular(5)),
              PreviewContainer(height: 4, borderRadius: .circular(5)),
            ],
          ),
        ),
        PreviewContainer(height: 40, width: 24, borderRadius: .circular(2)),
      ],
    );
  }
}
