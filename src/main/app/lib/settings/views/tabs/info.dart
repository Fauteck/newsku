import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _githubReadmeUrl = 'https://github.com/Fauteck/newsku#readme';

@RoutePage()
class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    return SelectionArea(
      child: FutureBuilder(
        future: Future.wait([
          PackageInfo.fromPlatform(),
          LicenseRegistry.licenses.toList(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final packageInfo = snapshot.data![0] as PackageInfo;
          final licenseEntries = snapshot.data![1] as List<LicenseEntry>;

          final byPackage = <String, List<String>>{};
          for (final entry in licenseEntries) {
            final text = entry.paragraphs.map((p) => p.text).join('\n\n');
            for (final package in entry.packages) {
              (byPackage[package] ??= []).add(text);
            }
          }
          final packageNames = byPackage.keys.toList()..sort();

          return ListView.separated(
            padding: EdgeInsets.all(pu8),
            itemCount: packageNames.length + 1,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: pu6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'v${packageInfo.version}+${packageInfo.buildNumber}',
                        style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      Gap(pu4),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => launchUrl(Uri.parse(_githubReadmeUrl), mode: LaunchMode.externalApplication),
                        label: const Text('README auf GitHub'),
                      ),
                      Gap(pu8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(locals.licenses, style: textTheme.titleMedium),
                      ),
                    ],
                  ),
                );
              }

              final package = packageNames[index - 1];
              final texts = byPackage[package]!;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: pu2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package, style: textTheme.titleSmall?.copyWith(color: colors.primary)),
                    Gap(pu2),
                    ...texts.map((text) => Text(
                          text,
                          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
