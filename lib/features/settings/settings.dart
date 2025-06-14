import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/ThemeNotifier.dart';
import '../../core/base/base_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    await context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.isDarkTheme;
    final currentLocale = context.locale;

    return BasePage(
      title: 'settings'.tr(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('dark_theme'.tr()),
              value: isDarkTheme,
              onChanged: (bool value) {
                themeNotifier.toggleTheme(value);
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (Locale? locale) {
                if (locale != null) {
                  _changeLanguage(context, locale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('tr'),
                  child: Text('Türkçe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
