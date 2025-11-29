import 'package:app/settings/states/general.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class GeneralSettingsTab extends StatelessWidget {
  const GeneralSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: .symmetric(horizontal: 8),
      child: BlocProvider(
        create: (context) => GeneralSettingsCubit(GeneralSettingsState()),
        child: BlocBuilder<GeneralSettingsCubit, GeneralSettingsState>(
          builder: (context, state) {
            final cubit = context.read<GeneralSettingsCubit>();
            return ErrorHandler<GeneralSettingsCubit, GeneralSettingsState>(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Gap(16),
                    Text('Article preferences'),
                    TextField(
                      controller: cubit.preferenceController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        helper: Text(
                          'This is guidance for the AI model. Telling it what kind of article you prefer to prioritize for the scoring  of each article. The change only applies to future articles.',
                        ),
                      ),
                    ),
                    Gap(8),
                    Align(
                      alignment: .centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: state.loading
                            ? null
                            : () async {
                                await cubit.setAiPreferences();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preference updated')));
                                }
                              },
                        label: Text('Update'),
                        icon: Icon(Icons.save),
                      ),
                    ),
                    Gap(32),
                    Divider(),
                    Gap(32),
                    Text('Minimum news score'),
                    Text('This will filter out from your feed any news that has been scored lower than the selected value', style: textTheme.labelMedium,),
                    Slider(
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: state.minimumImportance.toString(),
                      value: state.minimumImportance.toDouble(),
                      onChanged: (double value) => cubit.setImportance(value),
                    ),
                    Gap(8),
                    Align(
                      alignment: .centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: state.loading
                            ? null
                            : () async {
                                await cubit.saveImportance();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preference updated')));
                                }
                              },
                        label: Text('Update'),
                        icon: Icon(Icons.save),
                      ),
                    ),
                    Gap(32),
                    Divider(),
                    Gap(32),
                    Text('Change password'),
                    TextField(controller: cubit.password, obscureText: true),
                    Gap(8),
                    Text('Confirm password'),
                    TextField(
                      controller: cubit.repeatPassword,
                      obscureText: true,
                      decoration: InputDecoration(error: (state.password != state.repeatPassword) ? Text('Password do not match') : null),
                    ),
                    Gap(8),
                    Align(
                      alignment: .centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: state.loading || state.password != state.repeatPassword || state.password.isEmpty
                            ? null
                            : () async {
                                await cubit.resetPassword();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated')));
                                }
                              },
                        label: Text('Update'),
                        icon: Icon(Icons.save),
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
  }
}
