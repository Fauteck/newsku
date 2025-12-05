import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/views/components/previews/preview_container.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TopStoriesBig extends StatefulWidget {
  final LayoutBlock block;
  final Function(LayoutBlock block) onUpdated;

  const TopStoriesBig({super.key, required this.block, required this.onUpdated});

  @override
  State<TopStoriesBig> createState() => _TopStoriesBigState();
}

class _TopStoriesBigState extends State<TopStoriesBig> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: (widget.block.settings ?? widget.block.type.defaultSettings).title ?? '');
    controller.addListener(() {
      EasyDebounce.debounce('name-change', Duration(seconds: 1), () {
        var settings = widget.block.settings ?? widget.block.type.defaultSettings;
        widget.onUpdated(widget.block.copyWith(settings: settings.copyWith(title: controller.value.text)));
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: .start,
          spacing: 12,
          children: [
            Expanded(child: Column(spacing: 12, children: [_LeftArticle(), _LeftArticle(), _LeftArticle()])),
            Expanded(
              child: Column(
                spacing: 8,
                children: [
                  PreviewContainer(height: 100, borderRadius: .circular(5)),
                  PreviewContainer(height: 20, borderRadius: .circular(20)),
                  PreviewContainer(height: 10, borderRadius: .circular(20)),
                  PreviewContainer(height: 10, borderRadius: .circular(20)),
                ],
              ),
            ),
          ],
        ),
        Gap(16),
        TextFormField(
          key: ValueKey(widget.block.id),
          controller: controller,
          decoration: InputDecoration(label: Text('Title')),
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
      spacing: 8,
      children: [
        PreviewContainer(width: 50, height: 50, borderRadius: .circular(50)),
        Expanded(
          child: Column(
            spacing: 8,
            children: [
              PreviewContainer(height: 15, borderRadius: .circular(15)),
              PreviewContainer(height: 15, borderRadius: .circular(15)),
            ],
          ),
        ),
      ],
    );
  }
}
