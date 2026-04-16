import 'package:app/l10n/app_localizations.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/settings/states/layout.dart';
import 'package:app/settings/views/components/draggable_layout_block.dart';
import 'package:app/settings/views/components/dragged_layout_block.dart';
import 'package:app/settings/views/components/layout_separator.dart';
import 'package:app/settings/views/components/new_block_dialog.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/states/simple_cubit.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/conditional_wrap.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:app/utils/views/components/simple_cubit_view.dart';
import 'package:auto_route/annotations.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class LayoutSettingsTab extends StatelessWidget {
  final Color? fadeColor;

  const LayoutSettingsTab({super.key, this.fadeColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locals = AppLocalizations.of(context)!;

    final device = BreakPoint.get(context);

    return Padding(
      padding: EdgeInsets.only(bottom: pu8, left: pu2, right: pu2, top: pu2),
      child: BlocProvider(
        create: (context) => LayoutCubit(LayoutState()),
        child: BlocConsumer<LayoutCubit, LayoutState>(
          listener: (context, state) => context.read<LayoutCubit>().save(),
          listenWhen: (previous, current) => current.blocks.isNotEmpty && previous.blocks != current.blocks,
          builder: (context, state) {
            final cubit = context.read<LayoutCubit>();
            return ErrorHandler<LayoutCubit, LayoutState>(
              child: Column(
                children: [
                  Expanded(
                    child: Flex(
                      direction: device == BreakPoint.mobile ? Axis.vertical : Axis.horizontal,
                      spacing: pu2,
                      children: [
                        if (device == BreakPoint.mobile)
                          SimpleCubitView<bool>(
                            initialValue: false,
                            builder: (context, expanded) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    locals.layoutExplanation,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: expanded ? 10 : 2,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => context.read<SimpleCubit<bool>>().setValue(!expanded),
                                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                                ),
                              ],
                            ),
                          ),
                        if (device != BreakPoint.mobile)
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Gap(pu2),
                                Text(locals.layoutExplanation),
                                const Divider(),
                                Text(locals.availableBlocks, style: textTheme.titleLarge),
                                Text(locals.dragAndDropInstructions),
                                Gap(pu8),
                                Expanded(
                                  child: ListView(
                                    children: [
                                      Text(locals.fixedArticleCountBlocks),
                                      Center(
                                        child: DraggableLayoutBlock(
                                          setDragging: cubit.setDragging,
                                          type: LayoutBlockTypes.bigHeadline,
                                        ),
                                      ),
                                      Center(
                                        child: DraggableLayoutBlock(
                                          setDragging: cubit.setDragging,
                                          type: LayoutBlockTypes.bigHeadlinePicture,
                                        ),
                                      ),
                                      Center(
                                        child: DraggableLayoutBlock(
                                          setDragging: cubit.setDragging,
                                          type: LayoutBlockTypes.topStories,
                                        ),
                                      ),
                                      Gap(pu8),
                                      Text(locals.dynamicArticleCountBlocks),
                                      Center(
                                        child: DraggableLayoutBlock(
                                          setDragging: cubit.setDragging,
                                          type: LayoutBlockTypes.bigGrid,
                                        ),
                                      ),
                                      Center(
                                        child: DraggableLayoutBlock(
                                          setDragging: cubit.setDragging,
                                          type: LayoutBlockTypes.bigGridPicture,
                                        ),
                                      ),
                                      Center(
                                        child: DraggableLayoutBlock(
                                          setDragging: cubit.setDragging,
                                          type: LayoutBlockTypes.smallGrid,
                                        ),
                                      ),
                                      Center(
                                        child: DraggableLayoutBlock(
                                          setDragging: cubit.setDragging,
                                          type: LayoutBlockTypes.searchResult,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const VerticalDivider(),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Gap(pu2),
                              Row(
                                children: [
                                  Expanded(child: Text(locals.currentLayout, style: textTheme.titleLarge)),
                                  if (device == BreakPoint.mobile)
                                    TextButton(
                                      onPressed: () async {
                                        final newBlock = await NewBlockDialog.show(context);
                                        if (newBlock != null) {
                                          cubit.acceptDrag(
                                            state.blocks.length - 1,
                                            DragTargetDetails(data: newBlock, offset: Offset.zero),
                                          );
                                          cubit.scrollController.animateTo(
                                            cubit.scrollController.position.maxScrollExtent +
                                                cubit.scrollController.position.viewportDimension,
                                            duration: const Duration(seconds: 1),
                                            curve: Curves.easeInOutQuart,
                                          );
                                        }
                                      },
                                      child: Text(locals.addBlock),
                                    ),
                                ],
                              ),
                              Expanded(
                                child: ReorderableListView.builder(
                                  scrollController: cubit.scrollController,
                                  proxyDecorator: (child, index, animation) =>
                                      Center(child: DraggedLayoutBlock(type: state.blocks[index].type)),
                                  itemCount: state.blocks.length,
                                  onReorder: (int oldIndex, int newIndex) => cubit.onReorder(oldIndex, newIndex),
                                  buildDefaultDragHandles: false,
                                  itemBuilder: (context, index) {
                                    var block = state.blocks[index];
                                    var isLast = index == state.blocks.length - 1;

                                    return Padding(
                                      key: ValueKey(block),
                                      padding: EdgeInsets.only(bottom: pu2),
                                      child: ConditionalWrap(
                                        wrapIf: index == 0,
                                        wrapper: (child) => Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            LayoutSeparator(index: -1, dragging: state.dragging),
                                            child,
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Common section title field for all blocks
                                            _BlockTitleField(
                                              block: block,
                                              onUpdated: (newBlock) => cubit.updateBlock(block, newBlock),
                                            ),
                                            Gap(pu2),
                                            Row(
                                              spacing: pu4,
                                              children: [
                                                ReorderableDragStartListener(
                                                  index: index,
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors.move,
                                                    child: const Icon(Icons.drag_handle, size: 40),
                                                  ),
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
                                                                colors: [
                                                                  (fadeColor ?? colors.surface).withValues(alpha: 0),
                                                                  (fadeColor ?? colors.surface),
                                                                ],
                                                                stops: const [0, 0.90],
                                                                begin: Alignment.topCenter,
                                                                end: Alignment.bottomCenter,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: block.type.getBigPreview(
                                                      context,
                                                      block: block,
                                                      onUpdated: (newBlock) => cubit.updateBlock(block, newBlock),
                                                      last: isLast,
                                                      categories: state.categories,
                                                    ),
                                                  ),
                                                ),
                                                if (state.blocks.length > 1)
                                                  IconButton(
                                                    onPressed: () => cubit.removeBlock(block),
                                                    icon: const Icon(Icons.delete),
                                                    color: colors.error,
                                                  ),
                                              ],
                                            ),
                                            if (isLast && !block.type.fixedSize) ...[
                                              Gap(pu2),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: pu3, vertical: pu2),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: colors.tertiaryContainer.withValues(alpha: 0.6),
                                                ),
                                                child: Row(
                                                  spacing: pu2,
                                                  children: [
                                                    Icon(Icons.auto_awesome, size: 16, color: colors.onTertiaryContainer),
                                                    Expanded(
                                                      child: Text(
                                                        locals.lastBlockHint,
                                                        style: textTheme.bodySmall?.copyWith(
                                                          color: colors.onTertiaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            Gap(pu4),
                                            const Divider(),
                                            LayoutSeparator(index: index, dragging: state.dragging),
                                            if (state.dragging) const Divider(),
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
                  if (!state.valid)
                    Text(locals.layoutMustFinishWithDynamicBlock, style: TextStyle(color: colors.error)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A stateful title text field for a layout block section.
/// Handles its own controller lifecycle and debounced updates.
class _BlockTitleField extends StatefulWidget {
  final LayoutBlock block;
  final Function(LayoutBlock block) onUpdated;

  const _BlockTitleField({required this.block, required this.onUpdated});

  @override
  State<_BlockTitleField> createState() => _BlockTitleFieldState();
}

class _BlockTitleFieldState extends State<_BlockTitleField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.block.settings ?? widget.block.type.defaultSettings).title ?? '',
    );
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    EasyDebounce.debounce('block-title-${widget.block.id}', const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final settings = widget.block.settings ?? widget.block.type.defaultSettings;
      widget.onUpdated(widget.block.copyWith(settings: settings.copyWith(title: _controller.value.text)));
    });
  }

  @override
  void dispose() {
    EasyDebounce.cancel('block-title-${widget.block.id}');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    return TextFormField(
      key: ValueKey('title-${widget.block.id}'),
      controller: _controller,
      decoration: InputDecoration(
        labelText: locals.blockSectionTitle,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
