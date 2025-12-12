import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:flutter/material.dart';

class SearchResultSmall extends StatelessWidget {
  const SearchResultSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: smallPreviewSize,
      child: Row(
        spacing: 8,
        children: [
          PreviewContainer(width: 50, height: 50, borderRadius: .circular(10)),
          Expanded(
            child: Column(
              spacing: 4,
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
