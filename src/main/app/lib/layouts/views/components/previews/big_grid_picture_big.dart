import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';

class BigGridPictureBig extends StatelessWidget {
  final bool last;
  final LayoutBlock block;

  const BigGridPictureBig({super.key, required this.last, required this.block});

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
      childAspectRatio: 16 / (device == .mobile ? 17 : 15),
      children: List.generate(itemCount, (index) => _GridItem()),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem();

  @override
  Widget build(BuildContext context) {
    final device = BreakPoint.get(context);
    final colors = Theme.of(context).colorScheme;

    return PreviewContainer(
      borderRadius: .circular(10),
      child: Padding(
        padding: EdgeInsets.all(pu2),
        child: Column(
          mainAxisAlignment: .end,
          spacing: pu,
          children: [
            PreviewContainer(color: colors.surface, height: device == .mobile ? 8 : 12, borderRadius: .circular(5)),
            PreviewContainer(color: colors.surface, height: device == .mobile ? 5 : 7, borderRadius: .circular(5)),
            PreviewContainer(color: colors.surface, height: device == .mobile ? 5 : 7, borderRadius: .circular(5)),
          ],
        ),
      ),
    );
  }
}
