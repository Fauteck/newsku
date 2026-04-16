import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';

class SearchResultBig extends StatelessWidget {
  final LayoutBlock block;
  final bool last;

  const SearchResultBig({super.key, required this.block, required this.last});

  @override
  Widget build(BuildContext context) {
    final itemCount = last ? 3 : (block.settings ?? block.type.defaultSettings).items ?? 0;

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(itemCount, (index) => _GridItem()),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(bottom: pu2),
      child: Row(
        spacing: pu2,
        children: [
          PreviewContainer(width: 50, height: 50, borderRadius: .circular(10)),
          Expanded(
            child: Column(
              spacing: pu,
              children: [
                PreviewContainer(height: 10, borderRadius: .circular(10)),
                PreviewContainer(height: 5, borderRadius: .circular(5)),
                PreviewContainer(height: 5, borderRadius: .circular(5)),
                PreviewContainer(height: 5, borderRadius: .circular(5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
