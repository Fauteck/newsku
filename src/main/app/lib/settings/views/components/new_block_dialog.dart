import 'package:app/l10n/app_localizations.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class NewBlockDialog extends StatelessWidget {
  const NewBlockDialog({super.key});

  static Future<LayoutBlockTypes?> show(BuildContext context) {
    return showDialog(context: context, builder: (context) => NewBlockDialog());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final locals = AppLocalizations.of(context)!;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: .min,
          spacing: 8,
          children: [
            Center(
              child: Text(locals.selectBlock, style: textTheme.titleLarge, textAlign: .center),
            ),
            Gap(12),
            Expanded(
              child: ListView(
                children: [
                  Center(child: Text(locals.fixedArticleCountBlocks)),
                  _BlockPreview(type: LayoutBlockTypes.bigHeadline),
                  _BlockPreview(type: LayoutBlockTypes.bigHeadlinePicture),
                  _BlockPreview(type: LayoutBlockTypes.topStories),
                  Gap(32),
                  Center(child: Text(locals.dynamicArticleCountBlocks)),
                  _BlockPreview(type: LayoutBlockTypes.bigGrid),
                  _BlockPreview(type: LayoutBlockTypes.bigGridPicture),
                  _BlockPreview(type: LayoutBlockTypes.smallGrid),
                  _BlockPreview(type: LayoutBlockTypes.searchResult),
                ],
              ),
            ),
            Align(
              alignment: .centerRight,
              child: TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(locals.cancel)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockPreview extends StatelessWidget {
  final LayoutBlockTypes type;

  const _BlockPreview({required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => Navigator.of(context).pop(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Text(type.getLabel(locals), style: TextStyle(color: colors.primary)),
            type.smallPreview,
          ],
        ),
      ),
    );
  }
}
