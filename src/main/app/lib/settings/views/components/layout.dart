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
  const LayoutSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: .only(bottom: 32),
      child: BlocProvider(
        create: (context) => LayoutCubit(LayoutState()),
        child: BlocBuilder<LayoutCubit, LayoutState>(
          builder: (context, state) {
            final cubit = context.read<LayoutCubit>();
            return ErrorHandler<LayoutCubit, LayoutState>(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Gap(8),
                  Text(
                    'In this screen you can adjust how your RSS feed articles are being displayed by arranging the different types of blocks the way you want it. Your feed items will be inserted from most important to least important following the blocks top to bottom.\n\nNote that the Fixed article blocks on mobile will be displayed in a similar way as the big grid items.',
                  ),
                  Divider(),
                  Text('Available blocks', style: textTheme.titleLarge),
                  Text('Drag and drop the blocks onto your layout to personalize your home page'),
                  Gap(16),
                  Row(
                    spacing: 64,
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          spacing: 4,
                          children: [
                            Text('Fixed article count blocks'),
                            Row(
                              spacing: 32,
                              children: [
                                DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigHeadline),
                                DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.topStories),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          spacing: 4,
                          children: [
                            Text('Dynamic article count blocks'),
                            Row(
                              spacing: 32,
                              children: [
                                DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigGrid),
                                DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.smallGrid),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Text('Current Layout', style: textTheme.titleLarge),
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
                          padding: .symmetric(vertical: 32),
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
                                                  gradient: LinearGradient(colors: [colors.surface.withValues(alpha: 0), colors.surface], stops: [0, 0.80], begin: .topCenter, end: .bottomCenter),
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
                  Row(
                    children: [
                      if (!state.valid) Text('Your layout must finish with a dynamic block', style: TextStyle(color: colors.error)),
                      Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: state.valid
                            ? () async {
                                await cubit.save();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Layout saved')));
                                }
                              }
                            : null,
                        label: Text('Update'),
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
