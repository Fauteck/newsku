import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';

class BigGridBig extends StatelessWidget {
  final bool last;
  final LayoutBlock block;

  const BigGridBig({super.key, required this.block, required this.last});

  @override
  Widget build(BuildContext context) {
    final device = BreakPoint.get(context);
    final itemCount = last ? 6 : (block.settings ?? block.type.defaultSettings).items ?? 6;

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 16 / (device == .mobile ? 17 : 16),
      children: List.generate(itemCount, (index) => _GridItem()),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem();

  @override
  Widget build(BuildContext context) {
    final device = BreakPoint.get(context);

    return Column(
      spacing: pu,
      children: [
        PreviewContainer(height: device == .mobile ? 30 : 50, borderRadius: .circular(5)),
        PreviewContainer(height: device == .mobile ? 8 : 12, borderRadius: .circular(5)),
        PreviewContainer(height: device == .mobile ? 5 : 7, borderRadius: .circular(5)),
        PreviewContainer(height: device == .mobile ? 5 : 7, borderRadius: .circular(5)),
      ],
    );
  }
}
