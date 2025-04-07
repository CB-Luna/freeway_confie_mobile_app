import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../utils/app_localizations_extension.dart';
import '../widgets/theme/app_theme.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('profile.languages')),
        backgroundColor: AppTheme.getBackgroundHeaderColor(context),
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.getBackgroundColor(context),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            ...languageProvider.supportedLocales.map((locale) {
              final localeKey = '${locale.languageCode}_${locale.countryCode}';
              final isSelected = languageProvider.currentLocale.languageCode ==
                      locale.languageCode &&
                  languageProvider.currentLocale.countryCode ==
                      locale.countryCode;

              return ListTile(
                title: Text(
                  languageProvider.languageNames[localeKey] ?? localeKey,
                  style: TextStyle(
                    color: AppTheme.getTitleTextColor(context),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: AppTheme.getPrimaryColor(context),
                      )
                    : null,
                onTap: () {
                  languageProvider.changeLanguage(locale);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.translateWithArgs(
                          'common.language_changed_to',
                          args: [
                            languageProvider.languageNames[localeKey] ??
                                localeKey,
                          ],
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
