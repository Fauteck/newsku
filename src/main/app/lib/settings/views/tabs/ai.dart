import 'package:app/home/state/local_preferences.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/settings/states/general.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
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
                    Text(locals.articlePreference, style: textTheme.titleMedium),
                    Gap(pu2),
                    TextField(
                      key: const Key('article-preferences'),
                      controller: cubit.preferenceController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        helper: Text(locals.articlePreferencesExplanation, style: subTextTheme),
                      ),
                    ),
                    Gap(pu2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: state.loading
                            ? null
                            : () async {
                                await cubit.setAiPreferences();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(locals.preferenceUpdated)));
                                }
                              },
                        label: Text(locals.update),
                        icon: const Icon(Icons.save),
                      ),
                    ),
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
                    Gap(pu4),
                    Text(locals.openAiApiKey),
                    TextField(
                      key: const Key('openai-api-key'),
                      controller: cubit.openAiApiKeyController,
                      obscureText: true,
                      decoration: InputDecoration(hintText: locals.openAiApiKeyHint),
                    ),
                    Gap(pu2),
                    Text(locals.openAiModel),
                    TextField(
                      key: const Key('openai-model'),
                      controller: cubit.openAiModelController,
                      decoration: InputDecoration(hintText: 'gpt-4o-mini'),
                    ),
                    Gap(pu2),
                    Text(locals.openAiUrl),
                    TextField(
                      key: const Key('openai-url'),
                      controller: cubit.openAiUrlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(hintText: 'https://api.openai.com/v1'),
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
