import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showText;
  final bool isIconButton;

  const LanguageSwitcher({
    super.key,
    this.showText = true,
    this.isIconButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final l10n = AppLocalizations.of(context);

    if (isIconButton) {
      return IconButton(
        icon: Icon(
          Icons.language,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () => _showLanguageDialog(context, languageService, l10n),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _showLanguageDialog(context, languageService, l10n),
      icon: const Icon(Icons.language),
      label: showText 
        ? Text(languageService.isEnglish ? 'English' : 'Ελληνικά')
        : const SizedBox.shrink(),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageService languageService, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.settings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸'),
                title: const Text('English'),
                trailing: languageService.isEnglish 
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
                onTap: () {
                  languageService.changeLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Text('🇬🇷'),
                title: const Text('Ελληνικά'),
                trailing: languageService.isGreek 
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
                onTap: () {
                  languageService.changeLanguage('el');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}