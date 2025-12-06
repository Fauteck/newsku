import 'dart:io';
import 'dart:ui';

import 'package:app/home/state/local_preferences.dart';
import 'package:app/main.dart';
import 'package:app/settings/states/general.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:motor/motor.dart';

@RoutePage()
class GeneralSettingsTab extends StatelessWidget {
  const GeneralSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

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
                    Text('This will filter out from your feed any news that has been scored lower than the selected value', style: textTheme.labelMedium),
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
                    Gap(8),
                    SwitchListTile(
                      contentPadding: .zero,
                      title: Text('Dim read item in the feed'),
                      subtitle: Text('While you scroll through the feed, items will be set as read. You can make the feed item dim for the next time you visit your feed'),
                      value: state.user?.dimReadItems ?? false,
                      onChanged: state.loading ? null : (value) => cubit.dimReadItems(value),
                    ),
                    Gap(32),
                    Divider(),
                    Gap(32),
                    Text('App Color'),
                    Gap(8),
                    SwitchListTile(
                      contentPadding: .zero,
                      title: Text('Black background'),
                      subtitle: Text('Use black background for the darktheme'),
                      value: context.select((LocalPreferencesCubit p) => p.state.blackBackground),
                      onChanged: (value) => getIt.get<LocalPreferencesCubit>().setBlackBackground(value),
                    ),
                    Gap(8),
                    if (!kIsWeb && Platform.isAndroid) ...[
                      SwitchListTile(
                        contentPadding: .zero,
                        title: Text('Dynamic color'),
                        subtitle: Text('Use device accent color'),
                        value: context.select((LocalPreferencesCubit p) => p.state.dynamicColor),
                        onChanged: (value) => getIt.get<LocalPreferencesCubit>().setDynamicColor(value),
                      ),
                      Gap(8),
                    ],
                    if (!context.select((LocalPreferencesCubit p) => p.state.dynamicColor))
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [Colors.deepOrange, Colors.deepPurple, Colors.amber, Colors.green, Colors.pink, Colors.blue, Colors.grey, Colors.red, Colors.teal].map((c) {
                          return InkWell(
                            onTap: () => getIt.get<LocalPreferencesCubit>().setColor(c),
                            child: SingleMotionBuilder(
                              from: 0,
                              value: context.select((LocalPreferencesCubit p) => p.state.themeColor).toARGB32() == c.toARGB32() ? 1 : 0,
                              motion: MaterialSpringMotion.expressiveSpatialSlow(),
                              builder: (context, value, child) => Transform.scale(
                                scale: lerpDouble(1, 1.3, value),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(width: 2, color: Color.lerp(colors.surface, colors.tertiary, value)!),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
