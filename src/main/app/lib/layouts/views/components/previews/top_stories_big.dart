import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TopStoriesBig extends StatelessWidget {
  final LayoutBlock block;

  const TopStoriesBig({super.key, required this.block});

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
