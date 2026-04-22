import 'package:app/ai/models/ai_prompt.dart';
import 'package:app/ai/states/ai_prompts.dart';
import 'package:app/home/state/local_preferences.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/settings/states/general.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class AiSettingsTab extends StatelessWidget {
  const AiSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    final subTextTheme = textTheme.labelMedium?.copyWith(color: colors.secondary);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pu2),
      child: BlocProvider(
        create: (context) => GeneralSettingsCubit(GeneralSettingsState()),
        child: BlocBuilder<GeneralSettingsCubit, GeneralSettingsState>(
          builder: (context, state) {
            final cubit = context.read<GeneralSettingsCubit>();
            return ErrorHandler<GeneralSettingsCubit, GeneralSettingsState>(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(pu4),
                    // Named prompts section
                    Text(locals.namedPrompts, style: textTheme.titleMedium),
                    Gap(pu1),
                    Text(locals.namedPromptsExplanation, style: subTextTheme),
                    Gap(pu3),
                    const _NamedPromptsList(),
                    Gap(pu8),
                    const Divider(),
                    Gap(pu8),
                    Text(locals.minimumNewsScore, style: textTheme.titleMedium),
                    Text(locals.minimumNewsScoreExplanation, style: subTextTheme),
                    Slider(
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: state.user?.minimumImportance.toString(),
                      value: (state.user?.minimumImportance ?? 0).toDouble(),
                      onChanged: (double value) => cubit.setAndSaveImportance(value),
                    ),
                    Gap(pu4),
                    // Textkürzung toggle
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
                    Gap(pu8),
                    const Divider(),
                    Gap(pu8),
                    Text(locals.aiSection, style: textTheme.titleMedium),
                    Gap(pu2),
                    Text(locals.aiSectionExplanation, style: subTextTheme),
                    Gap(pu2),
                    SwitchListTile(
                      key: const Key('enable-ai-toggle'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(locals.enableAi),
                      subtitle: Text(locals.enableAiExplanation, style: subTextTheme),
                      value: state.user?.enableAi ?? true,
                      onChanged: state.loading ? null : (value) => cubit.setEnableAi(value),
                    ),
                    Gap(pu4),
                    Text(locals.openAiUrl),
                    Gap(pu1),
                    TextField(
                      key: const Key('openai-url'),
                      controller: cubit.openAiUrlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: 'https://api.openai.com/v1',
                        helperText: locals.openAiUrlOllamaHint,
                        helperMaxLines: 2,
                      ),
                    ),
                    Gap(pu1),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        key: const Key('ollama-preset-chip'),
                        avatar: const Icon(Icons.bolt, size: 16),
                        label: Text(locals.ollamaPreset),
                        onPressed: () {
                          cubit.openAiUrlController.text = 'http://ollama.fauteck.eu/v1';
                          cubit.openAiApiKeyController.text = '';
                        },
                      ),
                    ),
                    Gap(pu2),
                    Text(locals.openAiApiKey),
                    Gap(pu1),
                    TextField(
                      key: const Key('openai-api-key'),
                      controller: cubit.openAiApiKeyController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: locals.openAiApiKeyHint,
                        helperText: locals.openAiApiKeyOllamaNote,
                        helperMaxLines: 2,
                      ),
                    ),
                    Gap(pu2),
                    Text(locals.openAiModel),
                    TextField(
                      key: const Key('openai-model'),
                      controller: cubit.openAiModelController,
                      decoration: InputDecoration(hintText: 'gpt-4o-mini'),
                    ),
                    Gap(pu2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        key: const Key('openai-save-button'),
                        onPressed: state.loading
                            ? null
                            : () async {
                                await cubit.saveOpenAiSettings();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(locals.openAiSaved)));
                                }
                              },
                        label: Text(locals.update),
                        icon: const Icon(Icons.save),
                      ),
                    ),
                    Gap(pu8),
                    const Divider(),
                    Gap(pu4),
                    _OpenAiLimitsSection(cubit: cubit),
                    Gap(pu8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OpenAiLimitsSection extends StatefulWidget {
  final GeneralSettingsCubit cubit;

  const _OpenAiLimitsSection({required this.cubit});

  @override
  State<_OpenAiLimitsSection> createState() => _OpenAiLimitsSectionState();
}

class _OpenAiLimitsSectionState extends State<_OpenAiLimitsSection> {
  late final TextEditingController _relevance;
  late final TextEditingController _shortening;

  @override
  void initState() {
    super.initState();
    final user = widget.cubit.state.user;
    _relevance = TextEditingController(
      text: user?.openAiMonthlyTokenLimitRelevance?.toString() ?? '',
    );
    _shortening = TextEditingController(
      text: user?.openAiMonthlyTokenLimitShortening?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _relevance.dispose();
    _shortening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    final subTextTheme = textTheme.labelMedium?.copyWith(color: colors.secondary);

    return BlocListener<GeneralSettingsCubit, GeneralSettingsState>(
      listenWhen: (prev, curr) =>
          prev.user?.openAiMonthlyTokenLimitRelevance != curr.user?.openAiMonthlyTokenLimitRelevance ||
          prev.user?.openAiMonthlyTokenLimitShortening != curr.user?.openAiMonthlyTokenLimitShortening,
      listener: (context, state) {
        final user = state.user;
        final r = user?.openAiMonthlyTokenLimitRelevance?.toString() ?? '';
        final s = user?.openAiMonthlyTokenLimitShortening?.toString() ?? '';
        if (_relevance.text != r) _relevance.text = r;
        if (_shortening.text != s) _shortening.text = s;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locals.openAiLimitsTitle, style: textTheme.titleMedium),
          Gap(pu1),
          Text(locals.openAiLimitsExplanation, style: subTextTheme),
          Gap(pu3),
          Text(locals.openAiLimitRelevance),
          TextField(
            key: const Key('openai-limit-relevance'),
            controller: _relevance,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: locals.openAiLimitHint),
            onSubmitted: (_) => _save(),
            onEditingComplete: _save,
          ),
          Gap(pu2),
          Text(locals.openAiLimitShortening),
          TextField(
            key: const Key('openai-limit-shortening'),
            controller: _shortening,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: locals.openAiLimitHint),
            onSubmitted: (_) => _save(),
            onEditingComplete: _save,
          ),
        ],
      ),
    );
  }

  void _save() {
    final relevance = int.tryParse(_relevance.text.trim());
    final shortening = int.tryParse(_shortening.text.trim());
    widget.cubit.setMonthlyTokenLimit(relevance: relevance, shortening: shortening);
  }
}

class _NamedPromptsList extends StatelessWidget {
  const _NamedPromptsList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    return BlocBuilder<AiPromptsCubit, AiPromptsState>(
      builder: (context, state) {
        final cubit = context.read<AiPromptsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.loading && state.prompts.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            if (!state.loading && state.prompts.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: pu2),
                child: Text(locals.noPrompts, style: TextStyle(color: colors.onSurfaceVariant)),
              ),
            ...state.prompts.map(
              (prompt) => _PromptCard(
                key: ValueKey(prompt.id),
                prompt: prompt,
                cubit: cubit,
              ),
            ),
            Gap(pu2),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(locals.newPrompt),
              onPressed: () => _showCreateDialog(context, cubit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateDialog(BuildContext context, AiPromptsCubit cubit) async {
    final locals = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locals.newPrompt),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: locals.promptName,
                  hintText: locals.promptNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              Gap(pu3),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: locals.promptContent,
                  hintText: locals.promptContentHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(locals.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(locals.ok)),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      await cubit.createPrompt(nameController.text.trim(), contentController.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(locals.promptCreated)));
      }
    }

    nameController.dispose();
    contentController.dispose();
  }
}

class _PromptCard extends StatefulWidget {
  final AiPrompt prompt;
  final AiPromptsCubit cubit;

  const _PromptCard({super.key, required this.prompt, required this.cubit});

  @override
  State<_PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<_PromptCard> {
  bool _editing = false;
  late TextEditingController _nameController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prompt.name);
    _contentController = TextEditingController(text: widget.prompt.content);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locals = AppLocalizations.of(context)!;

    if (_editing) {
      return Card(
        margin: EdgeInsets.only(bottom: pu2),
        child: Padding(
          padding: EdgeInsets.all(pu3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: locals.promptName,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              Gap(pu2),
              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: locals.promptContent,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              Gap(pu2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: pu2,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: Text(locals.cancel),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.save, size: 18),
                    label: Text(locals.save),
                    onPressed: () async {
                      await widget.cubit.updatePrompt(
                        widget.prompt.copyWith(
                          name: _nameController.text.trim(),
                          content: _contentController.text.trim(),
                        ),
                      );
                      if (mounted) {
                        setState(() => _editing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(locals.promptSaved)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.only(bottom: pu2),
      child: ListTile(
        title: Text(widget.prompt.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          widget.prompt.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => setState(() => _editing = true),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: colors.error),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final locals = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locals.deletePrompt),
        content: Text(locals.deletePromptMessage),
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
      widget.cubit.deletePrompt(widget.prompt);
    }
  }
}
