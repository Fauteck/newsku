import 'package:app/home/state/local_preferences.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/settings/states/user_settings.dart';
import 'package:app/user/models/email_digest_frequency.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gap/gap.dart';

@RoutePage()
class UserSettingsTab extends StatelessWidget {
  const UserSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    final subTextTheme = textTheme.labelMedium?.copyWith(color: colors.secondary);
    return BlocProvider(
      create: (context) => UserSettingsCubit(
        UserSettingsState(
          email: identityCubit.currentUser?.email ?? '',
          digest: identityCubit.currentUser?.emailDigest ?? [],
          freshRssUsername: identityCubit.currentUser?.freshRssUsername ?? '',
        ),
      ),
      child: BlocBuilder<UserSettingsCubit, UserSettingsState>(
        builder: (context, state) {
          final cubit = context.read<UserSettingsCubit>();
          final serverConfig = config;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pu2),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(pu4),
                  if (serverConfig?.canResetPassword ?? false) ...[
                    Text(locals.emailDigestTitle, style: textTheme.titleMedium),
                    Text(locals.emailDigestExplanation),
                    Gap(pu4),
                    SegmentedButton<EmailDigestFrequency>(
                      multiSelectionEnabled: true,
                      emptySelectionAllowed: true,
                      onSelectionChanged: (values) =>
                          cubit.setDigestPreference(values.whereType<EmailDigestFrequency>().toList()),
                      segments: EmailDigestFrequency.values
                          .map(
                            (e) => ButtonSegment<EmailDigestFrequency>(
                              value: e,
                              enabled: serverConfig?.canResetPassword ?? false,
                              label: Text(locals.emailDigest(e.name)),
                              icon: const Icon(Icons.close),
                            ),
                          )
                          .toList(),
                      selected: state.digest.toSet(),
                    ),
                    Gap(pu8),
                  ],
                  Text(locals.changeEmail, style: textTheme.titleMedium),
                  Gap(pu4),
                  Text(locals.newEmail),
                  TextField(
                    key: const Key('email'),
                    controller: cubit.email,
                    decoration: InputDecoration(error: state.validEmail ? null : Text(locals.invalidEmail)),
                  ),
                  Gap(pu2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: state.loading || !state.validEmail
                          ? null
                          : () async {
                              await cubit.updateEmail();
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(locals.emailUpdated)));
                              }
                            },
                      label: Text(locals.update),
                      icon: const Icon(Icons.save),
                    ),
                  ),
                  Gap(pu8),
                  Text(locals.changePassword, style: textTheme.titleMedium),
                  Gap(pu4),
                  Text(locals.newPassword),
                  TextField(key: const Key('new-password'), controller: cubit.password, obscureText: true),
                  Gap(pu2),
                  Text(locals.confirmPassword),
                  TextField(
                    key: const Key('repeat-password'),
                    controller: cubit.repeatPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      error: (state.password != state.repeatPassword) ? Text(locals.passwordsNotMatch) : null,
                    ),
                  ),
                  Gap(pu2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      key: const Key('password-update-button'),
                      onPressed: state.loading || state.password != state.repeatPassword || state.password.isEmpty
                          ? null
                          : () async {
                              await cubit.resetPassword();
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(locals.passwordUpdated)));
                              }
                            },
                      label: Text(locals.update),
                      icon: const Icon(Icons.save),
                    ),
                  ),
                  Gap(pu8),
                  const Divider(),
                  Gap(pu4),
                  // FreshRSS section — always shown, users set their own credentials
                  Text(locals.freshRssTitle, style: textTheme.titleMedium),
                  Gap(pu2),
                  Text(locals.freshRssExplanation, style: subTextTheme),
                  Gap(pu4),
                  Text(locals.freshRssUrlLabel),
                  TextField(
                    key: const Key('freshrss-url'),
                    controller: cubit.freshRssUrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(hintText: 'https://freshrss.example.com'),
                  ),
                  Gap(pu2),
                  Text(locals.freshRssUsername),
                  TextField(
                    key: const Key('freshrss-username'),
                    controller: cubit.freshRssUsername,
                  ),
                  Gap(pu2),
                  Text(locals.freshRssApiPassword),
                  TextField(
                    key: const Key('freshrss-api-password'),
                    controller: cubit.freshRssApiPassword,
                    obscureText: true,
                    decoration: InputDecoration(hintText: locals.freshRssApiPasswordHint),
                  ),
                  Gap(pu2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      key: const Key('freshrss-save-button'),
                      onPressed: state.loading
                          ? null
                          : () async {
                              await cubit.updateFreshRssCredentials();
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(locals.freshRssSaved)));
                              }
                            },
                      label: Text(locals.update),
                      icon: const Icon(Icons.save),
                    ),
                  ),
                  Gap(pu8),
                  const Divider(),
                  Gap(pu4),
                  // Cache section
                  Text(locals.cacheSection, style: textTheme.titleMedium),
                  Text(locals.cacheExplanation, style: subTextTheme),
                  Gap(pu2),
                  Row(
                    spacing: pu2,
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          key: const Key('clear-image-cache'),
                          onPressed: () async {
                            await DefaultCacheManager().emptyCache();
                            PaintingBinding.instance.imageCache.clear();
                            PaintingBinding.instance.imageCache.clearLiveImages();
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(locals.cacheCleared)));
                            }
                          },
                          label: Text(locals.clearImageCache),
                          icon: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          key: const Key('clear-article-cache'),
                          onPressed: () async {
                            PaintingBinding.instance.imageCache.clear();
                            PaintingBinding.instance.imageCache.clearLiveImages();
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(locals.cacheCleared)));
                            }
                          },
                          label: Text(locals.clearArticleCache),
                          icon: const Icon(Icons.article_outlined),
                        ),
                      ),
                    ],
                  ),
                  Gap(pu8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
