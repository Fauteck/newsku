import 'dart:io';
import 'dart:ui';

import 'package:app/ai/models/ai_prompt.dart';
import 'package:app/ai/states/ai_prompts.dart';
import 'package:app/home/state/local_preferences.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/models/layout_block_settings.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/layouts/views/components/layout_category_selector.dart';
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
                    child: SingleChildScrollView(
                      controller: cubit.scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locals.layoutExplanation),
                          const Divider(),
                          Gap(pu2),
                          if (device == BreakPoint.mobile)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(locals.readItemHandling),
                                Text(locals.readItemHandlingExplanation, style: subTextTheme),
                                Gap(pu1),
                                DropdownMenu<ReadItemHandling>(
                                  key: const Key('read-item-handling'),
                                  expandedInsets: EdgeInsets.zero,
                                  initialSelection: generalState.user?.readItemHandling ?? ReadItemHandling.none,
                                  onSelected: generalCubit.setReadItemPreference,
                                  dropdownMenuEntries: ReadItemHandling.values
                                      .map((h) => DropdownMenuEntry(value: h, label: h.getLabel(context)))
                                      .toList(),
                                ),
                              ],
                            )
                          else
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
                          if (device == BreakPoint.mobile)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(locals.theme),
                                Gap(pu1),
                                DropdownMenu<ThemeMode>(
                                  expandedInsets: EdgeInsets.zero,
                                  initialSelection: context.select((LocalPreferencesCubit p) => p.state.theme),
                                  onSelected: (value) =>
                                      getIt.get<LocalPreferencesCubit>().setBrightness(value ?? ThemeMode.system),
                                  dropdownMenuEntries: ThemeMode.values
                                      .map((h) => DropdownMenuEntry(value: h, label: locals.appTheme(h.name)))
                                      .toList(),
                                ),
                              ],
                            )
                          else
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
                          _MagazineTabsSection(cubit: cubit, state: state),
                          Gap(pu2),
                          const Divider(),
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
                          Gap(pu2),
                          if (device != BreakPoint.mobile)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: pu2,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: _AvailableBlocksPanel(cubit: cubit),
                                ),
                                Container(width: 1, color: colors.outlineVariant),
                                Flexible(
                                  flex: 2,
                                  child: _LayoutBlocksList(
                                    cubit: cubit,
                                    state: state,
                                    fadeColor: fadeColor,
                                  ),
                                ),
                              ],
                            )
                          else
                            _LayoutBlocksList(
                              cubit: cubit,
                              state: state,
                              fadeColor: fadeColor,
                            ),
                          if (!state.valid && state.selectedTab == null)
                            Padding(
                              padding: EdgeInsets.only(top: pu2),
                              child: Text(
                                locals.layoutMustFinishWithDynamicBlock,
                                style: TextStyle(color: colors.error),
                              ),
                            ),
                        ],
                      ),
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

class _AvailableBlocksPanel extends StatelessWidget {
  final LayoutCubit cubit;

  const _AvailableBlocksPanel({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locals = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(pu2),
        Text(locals.availableBlocks, style: textTheme.titleLarge),
        Text(locals.dragAndDropInstructions),
        Gap(pu8),
        Text(locals.fixedArticleCountBlocks),
        Center(child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigHeadline)),
        Center(child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigHeadlinePicture)),
        Center(child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.topStories)),
        Gap(pu8),
        Text(locals.dynamicArticleCountBlocks),
        Center(child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigGrid)),
        Center(child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.bigGridPicture)),
        Center(child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.smallGrid)),
        Center(child: DraggableLayoutBlock(setDragging: cubit.setDragging, type: LayoutBlockTypes.searchResult)),
      ],
    );
  }
}

class _LayoutBlocksList extends StatelessWidget {
  final LayoutCubit cubit;
  final LayoutState state;
  final Color? fadeColor;

  const _LayoutBlocksList({required this.cubit, required this.state, this.fadeColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locals = AppLocalizations.of(context)!;

    if (state.loading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      proxyDecorator: (child, index, animation) =>
          Center(child: DraggedLayoutBlock(type: state.blocks[index].type)),
      itemCount: state.blocks.length,
      onReorder: cubit.onReorder,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final block = state.blocks[index];
        final isLast = index == state.blocks.length - 1;
        final settings = block.settings ?? block.type.defaultSettings;

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
                        child: block.type.getBigPreview(context, block: block, last: isLast),
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
                Gap(pu2),
                _BlockTitleField(
                  block: block,
                  onUpdated: (newBlock) => cubit.updateBlock(block, newBlock),
                ),
                if (!block.type.fixedSize) ...[
                  Gap(pu2),
                  if (isLast)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        settings.lastBlockShowAll
                            ? locals.lastBlockShowAllArticles
                            : locals.lastBlockLimitArticles,
                      ),
                      value: settings.lastBlockShowAll,
                      onChanged: (v) => cubit.updateBlock(
                        block,
                        block.copyWith(settings: settings.copyWith(lastBlockShowAll: v ?? true)),
                      ),
                    ),
                  if (!isLast || !settings.lastBlockShowAll)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: pu2,
                      children: [
                        IconButton.outlined(
                          onPressed: () {
                            final count =
                                settings.items ?? block.type.defaultSettings.items ?? 3;
                            if (count > 1) {
                              cubit.updateBlock(
                                block,
                                block.copyWith(settings: settings.copyWith(items: count - 1)),
                              );
                            }
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '${settings.items ?? block.type.defaultSettings.items ?? 3}',
                          style: textTheme.titleMedium,
                        ),
                        IconButton.outlined(
                          onPressed: () {
                            final count =
                                settings.items ?? block.type.defaultSettings.items ?? 3;
                            cubit.updateBlock(
                              block,
                              block.copyWith(settings: settings.copyWith(items: count + 1)),
                            );
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                ],
                if (state.categories.isNotEmpty)
                  LayoutCategorySelector(
                    block: block,
                    categories: state.categories,
                    onUpdated: (newBlock) => cubit.updateBlock(block, newBlock),
                  ),
                Gap(pu2),
                Text(locals.blockAiPromptLabel, style: textTheme.bodyMedium),
                Gap(pu1),
                BlocBuilder<AiPromptsCubit, AiPromptsState>(
                  builder: (context, promptsState) => DropdownMenu<String?>(
                    key: ValueKey('block-prompt-${block.id}-${settings.aiPromptId}'),
                    initialSelection: settings.aiPromptId,
                    onSelected: (value) {
                      final newSettings = value != null
                          ? settings.copyWith(aiPromptId: value)
                          : LayoutBlockSettings(
                              title: settings.title,
                              items: settings.items,
                              categoryId: settings.categoryId,
                              aiPromptId: null,
                              lastBlockShowAll: settings.lastBlockShowAll,
                            );
                      cubit.updateBlock(block, block.copyWith(settings: newSettings));
                    },
                    dropdownMenuEntries: [
                      DropdownMenuEntry<String?>(value: null, label: locals.globalPrompt),
                      ...promptsState.prompts
                          .map((p) => DropdownMenuEntry<String?>(value: p.id, label: p.name)),
                    ],
                  ),
                ),
                Gap(pu4),
                const Divider(),
                LayoutSeparator(index: index, dragging: state.dragging),
                if (state.dragging) const Divider(),
              ],
            ),
          ),
        );
      },
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
        Gap(pu3),
        if (state.selectedTab != null)
          _SelectedTabSettings(
            key: ValueKey(state.selectedTab!.id),
            tab: state.selectedTab!,
            cubit: cubit,
          )
        else
          const _StandardTabSettings(),
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

class _StandardTabSettings extends StatelessWidget {
  const _StandardTabSettings();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final subText = textTheme.labelMedium?.copyWith(color: colors.secondary);
    final locals = AppLocalizations.of(context)!;

    return BlocBuilder<GeneralSettingsCubit, GeneralSettingsState>(
      builder: (context, state) {
        final cubit = context.read<GeneralSettingsCubit>();
        final user = state.user;
        if (user == null) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: EdgeInsets.all(pu3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locals.standardLayoutSettings, style: textTheme.titleSmall),
                Gap(pu2),
                Text(locals.aiPromptLabel, style: textTheme.bodyMedium),
                Gap(pu1),
                BlocBuilder<AiPromptsCubit, AiPromptsState>(
                  builder: (context, promptsState) => DropdownMenu<String?>(
                    key: ValueKey('standard-prompt-${user.aiPromptId}'),
                    initialSelection: user.aiPromptId,
                    onSelected: cubit.updateAiPromptId,
                    dropdownMenuEntries: [
                      DropdownMenuEntry<String?>(value: null, label: locals.globalPrompt),
                      ...promptsState.prompts
                          .map((p) => DropdownMenuEntry<String?>(value: p.id, label: p.name)),
                    ],
                  ),
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
                        label: user.minimumImportance > 0
                            ? user.minimumImportance.toString()
                            : 'Default',
                        value: user.minimumImportance.toDouble(),
                        onChanged: cubit.setAndSaveImportance,
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        user.minimumImportance > 0
                            ? user.minimumImportance.toString()
                            : 'Default',
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
        hintText: locals.blockSectionTitleHint,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
