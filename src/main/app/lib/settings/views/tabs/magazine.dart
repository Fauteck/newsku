import 'package:app/l10n/app_localizations.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/magazine/models/magazine_tab.dart';
import 'package:app/settings/states/magazine.dart';
import 'package:app/settings/views/components/new_block_dialog.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class MagazineSettingsTab extends StatelessWidget {
  const MagazineSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MagazineSettingsCubit(const MagazineSettingsState()),
      child: const _MagazineSettingsBody(),
    );
  }
}

class _MagazineSettingsBody extends StatelessWidget {
  const _MagazineSettingsBody();

  @override
  Widget build(BuildContext context) {
    final isMobile = BreakPoint.get(context) == BreakPoint.mobile;

    return BlocBuilder<MagazineSettingsCubit, MagazineSettingsState>(
      builder: (context, state) {
        final cubit = context.read<MagazineSettingsCubit>();
        return ErrorHandler<MagazineSettingsCubit, MagazineSettingsState>(
          child: Padding(
            padding: EdgeInsets.all(pu2),
            child: isMobile
                ? _buildMobileLayout(context, cubit, state)
                : _buildDesktopLayout(context, cubit, state),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    MagazineSettingsCubit cubit,
    MagazineSettingsState state,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Magazin-Tabs', style: textTheme.titleMedium),
              Gap(pu2),
              Expanded(child: _TabList(cubit: cubit, state: state)),
              Gap(pu2),
              _AddTabButton(cubit: cubit),
            ],
          ),
        ),
        const VerticalDivider(),
        Gap(pu2),
        Expanded(
          child: state.selectedTab == null
              ? _EmptySelection()
              : _TabDetails(key: ValueKey(state.selectedTab!.id), tab: state.selectedTab!, cubit: cubit, state: state),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    MagazineSettingsCubit cubit,
    MagazineSettingsState state,
  ) {
    final textTheme = Theme.of(context).textTheme;
    if (state.selectedTab != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => cubit.clearSelection(),
              ),
              Expanded(child: Text(state.selectedTab!.name, style: textTheme.titleMedium)),
            ],
          ),
          const Divider(),
          Expanded(
            child: _TabDetails(key: ValueKey(state.selectedTab!.id), tab: state.selectedTab!, cubit: cubit, state: state),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Magazin-Tabs', style: textTheme.titleMedium),
        Gap(pu2),
        Expanded(child: _TabList(cubit: cubit, state: state)),
        Gap(pu2),
        _AddTabButton(cubit: cubit),
      ],
    );
  }
}

class _TabList extends StatelessWidget {
  final MagazineSettingsCubit cubit;
  final MagazineSettingsState state;

  const _TabList({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (state.loading && state.tabs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.tabs.isEmpty) {
      return Center(
        child: Text(
          'Noch keine Tabs vorhanden',
          style: TextStyle(color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: state.tabs.length,
      itemBuilder: (context, index) {
        final tab = state.tabs[index];
        final isSelected = state.selectedTab?.id == tab.id;
        return ListTile(
          selected: isSelected,
          selectedTileColor: colors.primaryContainer.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(tab.isPublic ? Icons.public : Icons.lock_outline, size: 18),
          title: Text(tab.name),
          onTap: () => cubit.selectTab(tab),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: colors.error, size: 18),
            onPressed: () => _confirmDelete(context, cubit, tab),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, MagazineSettingsCubit cubit, MagazineTab tab) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tab löschen?'),
        content: const Text('Dieser Tab und sein Layout werden dauerhaft gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.deleteTab(tab);
    }
  }
}

class _AddTabButton extends StatelessWidget {
  final MagazineSettingsCubit cubit;

  const _AddTabButton({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Neuer Tab'),
      onPressed: () => _showCreateDialog(context),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuer Tab'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tab-Name',
            hintText: 'z.B. Politik, Technologie...',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      cubit.createTab(name);
    }
    controller.dispose();
  }
}

class _EmptySelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tab_outlined, size: 48, color: colors.onSurfaceVariant),
          const Gap(16),
          Text(
            'Tab auswählen oder erstellen',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TabDetails extends StatefulWidget {
  final MagazineTab tab;
  final MagazineSettingsCubit cubit;
  final MagazineSettingsState state;

  const _TabDetails({super.key, required this.tab, required this.cubit, required this.state});

  @override
  State<_TabDetails> createState() => _TabDetailsState();
}

class _TabDetailsState extends State<_TabDetails> {
  late final TextEditingController _nameController;
  late final TextEditingController _aiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tab.name);
    _aiController = TextEditingController(text: widget.tab.aiPreference ?? '');

    _nameController.addListener(() {
      widget.cubit.updateSelectedTabField(name: _nameController.text);
    });
    _aiController.addListener(() {
      final text = _aiController.text;
      widget.cubit.updateSelectedTabField(
        aiPreference: text.isEmpty ? null : text,
        clearAiPreference: text.isEmpty,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final subText = textTheme.labelMedium?.copyWith(color: colors.secondary);
    final tab = widget.state.selectedTab ?? widget.tab;
    final cubit = widget.cubit;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap(pu2),
          Text('Tab-Einstellungen', style: textTheme.titleMedium),
          Gap(pu3),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          Gap(pu3),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Öffentlich zugänglich'),
            subtitle: Text(
              'Dieser Tab ist ohne Anmeldung über einen direkten Link abrufbar',
              style: subText,
            ),
            value: tab.isPublic,
            onChanged: (value) => cubit.updateSelectedTabField(isPublic: value),
          ),
          if (tab.isPublic && tab.id != null) ...[
            Gap(pu2),
            _ShareLinkRow(tabId: tab.id!),
          ],
          Gap(pu2),
          const Divider(),
          Gap(pu2),
          Text('KI-Einstellungen', style: textTheme.titleMedium),
          Gap(pu1),
          Text('Überschreibt die globalen KI-Einstellungen für diesen Tab', style: subText),
          Gap(pu3),
          TextField(
            controller: _aiController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Artikel-Präferenzen',
              hintText: 'Leer lassen für globale Einstellung',
              helper: Text('Anweisung für das KI-Modell bei der Bewertung von Artikeln', style: subText),
              border: const OutlineInputBorder(),
            ),
          ),
          Gap(pu3),
          Text('Minimaler Nachrichten-Score', style: textTheme.bodyMedium),
          Text('Leer = globale Einstellung verwenden', style: subText),
          Gap(pu1),
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
          Gap(pu2),
          const Divider(),
          Gap(pu2),
          Row(
            children: [
              Expanded(child: Text('Layout', style: textTheme.titleMedium)),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Block hinzufügen'),
                onPressed: () => _addBlock(context, cubit, widget.state),
              ),
            ],
          ),
          Gap(pu2),
          if (widget.state.loading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (widget.state.tabLayout.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: pu4),
              child: Center(
                child: Text('Kein Layout konfiguriert', style: subText),
              ),
            )
          else
            _LayoutBlockList(
              blocks: widget.state.tabLayout,
              cubit: cubit,
            ),
          Gap(pu8),
        ],
      ),
    );
  }

  Future<void> _addBlock(BuildContext context, MagazineSettingsCubit cubit, MagazineSettingsState state) async {
    final type = await NewBlockDialog.show(context);
    if (type == null) return;
    final currentBlocks = List<LayoutBlock>.from(state.tabLayout);
    final newBlock = LayoutBlock(type: type, order: currentBlocks.length, settings: type.defaultSettings);
    currentBlocks.add(newBlock);
    cubit.saveTabLayout(currentBlocks);
  }
}

class _ShareLinkRow extends StatelessWidget {
  final String tabId;

  const _ShareLinkRow({required this.tabId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final url = '${serverUrl ?? ''}/public/magazine/$tabId';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: pu3, vertical: pu2),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 16, color: colors.primary),
          Gap(pu2),
          Expanded(
            child: Text(
              url,
              style: textTheme.bodySmall?.copyWith(color: colors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Link kopieren',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link kopiert'), duration: Duration(seconds: 2)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LayoutBlockList extends StatelessWidget {
  final List<LayoutBlock> blocks;
  final MagazineSettingsCubit cubit;

  const _LayoutBlockList({required this.blocks, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 300,
      child: ReorderableListView.builder(
        itemCount: blocks.length,
        onReorder: (oldIndex, newIndex) {
          final updated = List<LayoutBlock>.from(blocks);
          if (oldIndex < newIndex) newIndex -= 1;
          final item = updated.removeAt(oldIndex);
          updated.insert(newIndex, item);
          for (int i = 0; i < updated.length; i++) {
            updated[i] = updated[i].copyWith(order: i);
          }
          cubit.saveTabLayout(updated);
        },
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          final block = blocks[index];
          return Card(
            key: ValueKey(block),
            margin: EdgeInsets.only(bottom: pu1),
            child: ListTile(
              leading: ReorderableDragStartListener(
                index: index,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: Icon(Icons.drag_handle),
                ),
              ),
              title: Text(block.type.getLabel(AppLocalizations.of(context)!), style: textTheme.bodyMedium),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: colors.error),
                onPressed: () {
                  final updated = List<LayoutBlock>.from(blocks)..removeAt(index);
                  for (int i = 0; i < updated.length; i++) {
                    updated[i] = updated[i].copyWith(order: i);
                  }
                  cubit.saveTabLayout(updated);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
