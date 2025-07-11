import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageButton extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChange;

  const LanguageButton({
    Key? key,
    required this.currentLocale,
    required this.onLocaleChange,
  }) : super(key: key);

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
                title: Text('Español'),
                onTap: () {
                  onLocaleChange(Locale('es', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text('English'),
                onTap: () {
                  onLocaleChange(Locale('en', ''));
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