import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'language_switcher_app.dart'; // Import the global provider

class LanguageButton extends StatelessWidget {
  const LanguageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showLanguageDialog(context),
      backgroundColor: Color(0xFFA78AAB),
      child: Icon(
        Icons.language,
        color: Colors.white,
        size: 28,
      ),
      tooltip: AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.selectLanguage ?? 'Seleccionar idioma / Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text('🇪🇸', style: TextStyle(fontSize: 24)),
                title: Text(AppLocalizations.of(context)?.spanishLanguageName ?? 'Español'),
                onTap: () {
                  languageProvider.changeLanguage(Locale('es', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text(AppLocalizations.of(context)?.englishLanguageName ?? 'English'),
                onTap: () {
                  languageProvider.changeLanguage(Locale('en', ''));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}