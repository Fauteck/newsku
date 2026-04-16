import 'package:app/feed/models/feed_category.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/layout_category_selector.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TopStoriesBig extends StatelessWidget {
  final LayoutBlock block;
  final Function(LayoutBlock block) onUpdated;
  final List<FeedCategory> categories;

  const TopStoriesBig({super.key, required this.block, required this.onUpdated, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(pu4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: pu3,
          children: [
            Expanded(
              child: Column(spacing: pu3, children: [_LeftArticle(), _LeftArticle(), _LeftArticle()]),
            ),
            Expanded(
              child: Column(
                spacing: pu2,
                children: [
                  PreviewContainer(height: 100, borderRadius: BorderRadius.circular(5)),
                  PreviewContainer(height: 20, borderRadius: BorderRadius.circular(20)),
                  PreviewContainer(height: 10, borderRadius: BorderRadius.circular(20)),
                  PreviewContainer(height: 10, borderRadius: BorderRadius.circular(20)),
                ],
              ),
            ),
          ],
        ),
        LayoutCategorySelector(block: block, onUpdated: onUpdated, categories: categories),
      ],
    );
  }
}

class _LeftArticle extends StatelessWidget {
  const _LeftArticle();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: pu2,
      children: [
        PreviewContainer(width: 50, height: 50, borderRadius: BorderRadius.circular(50)),
        Expanded(
          child: Column(
            spacing: pu2,
            children: [
              PreviewContainer(height: 15, borderRadius: BorderRadius.circular(15)),
              PreviewContainer(height: 15, borderRadius: BorderRadius.circular(15)),
            ],
          ),
        ),
      ],
    );
  }
}
