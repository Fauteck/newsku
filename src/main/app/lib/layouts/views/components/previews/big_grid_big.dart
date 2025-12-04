import 'dart:math';

import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:flutter/material.dart';

class BigGridBig extends StatelessWidget {
  final bool last;
  final LayoutBlock block;
  final Function(LayoutBlock block) onUpdated;

  const BigGridBig({super.key, required this.block, required this.onUpdated, required this.last});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 16 / 13,
          children: List.generate(last ? 4 : (block.settings ?? block.type.defaultSettings).items ?? 0, (index) => _GridItem()),
        ),
        if (!last)
          Row(
            mainAxisAlignment: .center,
            children: [
              IconButton(
                onPressed: () {
                  var settings = block.settings ?? block.type.defaultSettings;
                  onUpdated(block.copyWith(settings: settings.copyWith(items: max(2, (settings.items ?? 0) - 1))));
                },
                icon: Icon(Icons.remove),
              ),
              Text('${(block.settings ?? block.type.defaultSettings).items ?? 0} items'),
              IconButton(
                onPressed: () {
                  var settings = block.settings ?? block.type.defaultSettings;
                  onUpdated(block.copyWith(settings: settings.copyWith(items: (settings.items ?? 0) + 1)));
                },
                icon: Icon(Icons.remove),
              ),
            ],
          ),
      ],
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        PreviewContainer(height: 100, borderRadius: .circular(5)),
        PreviewContainer(height: 20, borderRadius: .circular(5)),
        PreviewContainer(height: 10, borderRadius: .circular(5)),
        PreviewContainer(height: 10, borderRadius: .circular(5)),
      ],
    );
  }
}
