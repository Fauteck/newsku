import 'package:app/l10n/app_localizations.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/settings/states/layout.dart';
import 'package:app/settings/views/components/draggable_layout_block.dart';
import 'package:app/settings/views/components/dragged_layout_block.dart';
import 'package:app/utils/views/components/conditional_wrap.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'layout_separator.dart';

@RoutePage()
class LayoutSettingsTab extends StatelessWidget {
  final Color? fadeColor;

  const LayoutSettingsTab({super.key, this.fadeColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locals = AppLocalizations.of(context)!;

    return Padding(
      padding: .only(bottom: 32),
      child: BlocProvider(
        create: (context) => LayoutCubit(LayoutState()),
        child: BlocBuilder<LayoutCubit, LayoutState>(
          builder: (context, state) {
            final cubit = context.read<LayoutCubit>();
            return ErrorHandler<LayoutCubit, LayoutState>(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Gap(8),
                              Text(locals.layoutExplanation),
                              Divider(),
                              Text(locals.availableBlocks, style: textTheme.titleLarge),
                              Text(locals.dragAndDropInstructions),
                              Gap(32),
                              Expanded(
                                child: ListView(
                                  children: [
                                    Text(locals.fixedArticleCountBlocks),
                                    Center(
                                      child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigHeadline),
                                    ),
                                    Center(
                                      child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.topStories),
                                    ),
                                    Gap(32),
                                    Text(locals.dynamicArticleCountBlocks),
                                    Center(
                                      child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigGrid),
                                    ),
                                    Center(
                                      child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.smallGrid),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: .stretch,
                            children: [
                              Gap(8),
                              Text(locals.currentLayout, style: textTheme.titleLarge),
                              Expanded(
                                child: ReorderableListView.builder(
                                  proxyDecorator: (child, index, animation) => Center(child: DraggedLayoutBlock(type: state.blocks[index].type)),
                                  itemCount: state.blocks.length,
                                  onReorder: (int oldIndex, int newIndex) => cubit.onReorder(oldIndex, newIndex),

                                  buildDefaultDragHandles: false,
                                  itemBuilder: (context, index) {
                                    var block = state.blocks[index];

                                    var isLast = index == state.blocks.length - 1;
                                    return Padding(
                                      key: ValueKey(block),
                                      padding: .only(bottom: 8),
                                      child: ConditionalWrap(
                                        wrapIf: index == 0,
                                        wrapper: (child) => Column(
                                          crossAxisAlignment: .stretch,
                                          children: [
                                            LayoutSeparator(index: -1, dragging: state.dragging),
                                            child,
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: .stretch,
                                          children: [
                                            Row(
                                              spacing: 16,
                                              children: [
                                                ReorderableDragStartListener(
                                                  index: index,
                                                  child: MouseRegion(cursor: SystemMouseCursors.move, child: Icon(Icons.drag_handle, size: 40)),
                                                ),
                                                Expanded(
                                                  child: ConditionalWrap(
                                                    wrapIf: isLast && !block.type.fixedSize,
                                                    wrapper: (child) => Stack(
                                                      children: [
                                                        child,
                                                        Positioned(
                                                          left: 0,
                                                          right: 0,
                                                          bottom: 0,
                                                          child: Container(
                                                            height: 150,
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [(fadeColor ?? colors.surface).withValues(alpha: 0), (fadeColor ?? colors.surface)],
                                                                stops: [0, 0.90],
                                                                begin: .topCenter,
                                                                end: .bottomCenter,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: block.type.getBigPreview(context, block: block, onUpdated: (newBlock) => cubit.updateBlock(block, newBlock), last: isLast),
                                                  ),
                                                ),
                                                if (state.blocks.length > 1) IconButton(onPressed: () => cubit.removeBlock(block), icon: Icon(Icons.delete), color: colors.error),
                                              ],
                                            ),
                                            LayoutSeparator(index: index, dragging: state.dragging),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (!state.valid) Text(locals.layoutMustFinishWithDynamicBlock, style: TextStyle(color: colors.error)),
                      Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: state.valid
                            ? () async {
                                await cubit.save();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(locals.layoutSaved)));
                                }
                              }
                            : null,
                        label: Text(locals.update),
                        icon: Icon(Icons.save),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
