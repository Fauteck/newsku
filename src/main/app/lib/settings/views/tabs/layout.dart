import 'dart:io';
import 'dart:ui';

import 'package:app/ai/models/ai_prompt.dart';
import 'package:app/ai/states/ai_prompts.dart';
import 'package:app/home/state/local_preferences.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/magazine/models/magazine_tab.dart';
import 'package:app/main.dart';
import 'package:app/settings/states/general.dart';
import 'package:app/settings/states/layout.dart';
import 'package:app/settings/views/components/draggable_layout_block.dart';
import 'package:app/settings/views/components/dragged_layout_block.dart';
import 'package:app/settings/views/components/layout_separator.dart';
import 'package:app/settings/views/components/new_block_dialog.dart';
import 'package:app/user/models/read_item_handling.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/conditional_wrap.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:motor/motor.dart';

@RoutePage()
class LayoutSettingsTab extends StatelessWidget {
  final Color? fadeColor;

  const LayoutSettingsTab({super.key, this.fadeColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locals = AppLocalizations.of(context)!;
    final subTextTheme = textTheme.labelMedium?.copyWith(color: colors.secondary);

    final device = BreakPoint.get(context);

    return BlocProvider(
      create: (context) => GeneralSettingsCubit(GeneralSettingsState()),
      child: BlocBuilder<GeneralSettingsCubit, GeneralSettingsState>(
        builder: (context, generalState) {
          final generalCubit = context.read<GeneralSettingsCubit>();
          return Padding(
            padding: EdgeInsets.only(bottom: pu8, left: pu2, right: pu2, top: pu2),
            child: BlocProvider(
              create: (context) => LayoutCubit(LayoutState()),
              child: BlocConsumer<LayoutCubit, LayoutState>(
                listener: (context, state) => context.read<LayoutCubit>().save(),
                listenWhen: (previous, current) =>
                    current.blocks.isNotEmpty &&
                    previous.blocks != current.blocks &&
                    previous.selectedTab == current.selectedTab,
                builder: (context, state) {
                  final cubit = context.read<LayoutCubit>();
                  return ErrorHandler<LayoutCubit, LayoutState>(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Single-column info section
                        Text(locals.layoutExplanation),
                        const Divider(),
                        Gap(pu2),
                        // Single-column display settings (from Darstellung tab)
                        Row(
                          spacing: pu2,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(locals.readItemHandling),
                                  Text(locals.readItemHandlingExplanation, style: subTextTheme),
                                ],
                              ),
                            ),
                            DropdownMenu<ReadItemHandling>(
                              key: const Key('read-item-handling'),
                              initialSelection: generalState.user?.readItemHandling ?? ReadItemHandling.none,
                              onSelected: generalCubit.setReadItemPreference,
                              dropdownMenuEntries: ReadItemHandling.values
                                  .map((h) => DropdownMenuEntry(value: h, label: h.getLabel(context)))
                                  .toList(),
                            ),
                          ],
                        ),
                        Gap(pu2),
                        BlocBuilder<LocalPreferencesCubit, LocalPreferencesState>(
                          bloc: getIt.get<LocalPreferencesCubit>(),
                          builder: (context, prefsState) => SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(locals.truncateText),
                            subtitle: Text(locals.truncateTextExplanation, style: subTextTheme),
                            value: prefsState.truncateText,
                            onChanged: (value) => getIt.get<LocalPreferencesCubit>().setTruncateText(value),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(locals.blackBackground),
                          subtitle: Text(locals.blackBackgroundExplanation, style: subTextTheme),
                          value: context.select((LocalPreferencesCubit p) => p.state.blackBackground),
                          onChanged: (value) => getIt.get<LocalPreferencesCubit>().setBlackBackground(value),
                        ),
                        Text(locals.appColor),
                        Gap(pu2),
                        if (!kIsWeb && Platform.isAndroid) ...[
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(locals.dynamicColor),
                            subtitle: Text(locals.blackBackgroundExplanation, style: subTextTheme),
                            value: context.select((LocalPreferencesCubit p) => p.state.dynamicColor),
                            onChanged: (value) => getIt.get<LocalPreferencesCubit>().setDynamicColor(value),
                          ),
                          Gap(pu2),
                        ],
                        Row(
                          spacing: pu2,
                          children: [
                            Expanded(child: Text(locals.theme)),
                            DropdownMenu<ThemeMode>(
                              initialSelection: context.select((LocalPreferencesCubit p) => p.state.theme),
                              onSelected: (value) =>
                                  getIt.get<LocalPreferencesCubit>().setBrightness(value ?? ThemeMode.system),
                              dropdownMenuEntries: ThemeMode.values
                                  .map((h) => DropdownMenuEntry(value: h, label: locals.appTheme(h.name)))
                                  .toList(),
                            ),
                          ],
                        ),
                        if (!context.select((LocalPreferencesCubit p) => p.state.dynamicColor))
                          Wrap(
                            spacing: pu4,
                            runSpacing: pu4,
                            children: [
                              Colors.deepOrange,
                              Colors.deepPurple,
                              Colors.amber,
                              Colors.green,
                              Colors.pink,
                              Colors.blue,
                              Colors.grey,
                              Colors.red,
                              Colors.teal,
                            ].map((c) {
                              return InkWell(
                                onTap: () => getIt.get<LocalPreferencesCubit>().setColor(c),
                                child: SingleMotionBuilder(
                                  from: 0,
                                  value: context
                                              .select((LocalPreferencesCubit p) => p.state.themeColor)
                                              .toARGB32() ==
                                          c.toARGB32()
                                      ? 1
                                      : 0,
                                  motion: MaterialSpringMotion.expressiveSpatialSlow(),
                                  builder: (context, value, child) => Transform.scale(
                                    scale: lerpDouble(1, 1.3, value),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 2,
                                          color: Color.lerp(colors.surface, colors.tertiary, value)!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        Gap(pu4),
                        const Divider(),
                        Gap(pu2),
                        // Magazine tabs section
                        _MagazineTabsSection(cubit: cubit, state: state),
                        Gap(pu2),
                        const Divider(),
                        Gap(pu2),
                        // Two-column blocks section
                        Expanded(
                          child: Flex(
                            direction: device == BreakPoint.mobile ? Axis.vertical : Axis.horizontal,
                            spacing: pu2,
                            children: [
                              if (device != BreakPoint.mobile)
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Gap(pu2),
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
                              if (device != BreakPoint.mobile) const VerticalDivider(),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Gap(pu2),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            state.selectedTab != null
                                                ? locals.layoutForTab(state.selectedTab!.name)
                                                : locals.currentLayout,
                                            style: textTheme.titleLarge,
                                          ),
                                        ),
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
                                    if (state.loading)
                                      const Expanded(child: Center(child: CircularProgressIndicator()))
                                    else
                                      Expanded(
                                        child: ReorderableListView.builder(
                                          scrollController: cubit.scrollController,
                                          proxyDecorator: (child, index, animation) =>
                                              Center(child: DraggedLayoutBlock(type: state.blocks[index].type)),
                                          itemCount: state.blocks.length,
                                          onReorder: (int oldIndex, int newIndex) =>
                                              cubit.onReorder(oldIndex, newIndex),
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
                                                                          (fadeColor ?? colors.surface)
                                                                              .withValues(alpha: 0),
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
                                                              onUpdated: (newBlock) =>
                                                                  cubit.updateBlock(block, newBlock),
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
                                                        padding:
                                                            EdgeInsets.symmetric(horizontal: pu3, vertical: pu2),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(6),
                                                          color: colors.tertiaryContainer.withValues(alpha: 0.6),
                                                        ),
                                                        child: Row(
                                                          spacing: pu2,
                                                          children: [
                                                            Icon(Icons.auto_awesome,
                                                                size: 16, color: colors.onTertiaryContainer),
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
                        if (!state.valid && state.selectedTab == null)
                          Text(locals.layoutMustFinishWithDynamicBlock, style: TextStyle(color: colors.error)),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MagazineTabsSection extends StatelessWidget {
  final LayoutCubit cubit;
  final LayoutState state;

  const _MagazineTabsSection({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    final subTextTheme = textTheme.labelMedium?.copyWith(color: colors.secondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locals.magazineTabs, style: textTheme.titleMedium),
                  Text(locals.magazineTabsExplanation, style: subTextTheme),
                ],
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(locals.newTab),
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
        Gap(pu2),
        Wrap(
          spacing: pu2,
          runSpacing: pu1,
          children: [
            FilterChip(
              label: Text(locals.standardLayout),
              selected: state.selectedTab == null,
              onSelected: (_) => cubit.selectTab(null),
            ),
            ...state.magazineTabs.map((tab) => FilterChip(
                  label: Text(tab.name),
                  selected: state.selectedTab?.id == tab.id,
                  onSelected: (_) => cubit.selectTab(tab),
                  deleteIcon: Icon(Icons.close, size: 16, color: colors.error),
                  onDeleted: () => _confirmDelete(context, tab),
                )),
          ],
        ),
        if (state.selectedTab != null) ...[
          Gap(pu3),
          _SelectedTabSettings(
            key: ValueKey(state.selectedTab!.id),
            tab: state.selectedTab!,
            cubit: cubit,
          ),
        ],
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final locals = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locals.newTab),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: locals.tabName,
            hintText: locals.tabNameHint,
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(locals.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(locals.ok),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      cubit.createMagazineTab(name);
    }
    controller.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, MagazineTab tab) async {
    final locals = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locals.deleteTab),
        content: Text(locals.deleteTabMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(locals.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            child: Text(locals.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.deleteMagazineTab(tab);
    }
  }
}

class _SelectedTabSettings extends StatefulWidget {
  final MagazineTab tab;
  final LayoutCubit cubit;

  const _SelectedTabSettings({super.key, required this.tab, required this.cubit});

  @override
  State<_SelectedTabSettings> createState() => _SelectedTabSettingsState();
}

class _SelectedTabSettingsState extends State<_SelectedTabSettings> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tab.name);
    _nameController.addListener(() {
      widget.cubit.updateSelectedTabField(name: _nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final subText = textTheme.labelMedium?.copyWith(color: colors.secondary);
    final locals = AppLocalizations.of(context)!;

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final tab = state.selectedTab ?? widget.tab;
        final cubit = widget.cubit;

        return Card(
          child: Padding(
            padding: EdgeInsets.all(pu3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: locals.tabName,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                Gap(pu2),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(locals.tabPublic),
                  subtitle: Text(locals.tabPublicExplanation, style: subText),
                  value: tab.isPublic,
                  onChanged: (value) => cubit.updateSelectedTabField(isPublic: value),
                ),
                Gap(pu1),
                Text(locals.aiPromptLabel, style: textTheme.bodyMedium),
                Gap(pu1),
                BlocBuilder<AiPromptsCubit, AiPromptsState>(
                  builder: (context, promptsState) {
                    final prompts = promptsState.prompts;
                    return DropdownMenu<String?>(
                      key: ValueKey('prompt-${tab.id}-${tab.aiPromptId}'),
                      initialSelection: tab.aiPromptId,
                      onSelected: (value) {
                        if (value == null) {
                          cubit.updateSelectedTabField(clearAiPromptId: true);
                        } else {
                          cubit.updateSelectedTabField(aiPromptId: value);
                        }
                      },
                      dropdownMenuEntries: [
                        DropdownMenuEntry<String?>(value: null, label: locals.globalPrompt),
                        ...prompts.map((p) => DropdownMenuEntry<String?>(value: p.id, label: p.name)),
                      ],
                    );
                  },
                ),
                Gap(pu2),
                Text(locals.tabMinScore, style: textTheme.bodyMedium),
                Text(locals.tabMinScoreExplanation, style: subText),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: tab.minimumImportance?.toString() ?? 'Global',
                        value: (tab.minimumImportance ?? 0).toDouble(),
                        onChanged: (value) {
                          final rounded = value.round();
                          cubit.updateSelectedTabField(
                            minimumImportance: rounded == 0 ? null : rounded,
                            clearMinimumImportance: rounded == 0,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        tab.minimumImportance?.toString() ?? 'Global',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
