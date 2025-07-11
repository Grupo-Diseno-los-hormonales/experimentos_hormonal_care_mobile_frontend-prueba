import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'language_button.dart'; // Import the LanguageButton widget
class LanguageSwitcherApp extends StatefulWidget {
  final Widget child;

  const LanguageSwitcherApp({Key? key, required this.child}) : super(key: key);

  @override
  _LanguageSwitcherAppState createState() => _LanguageSwitcherAppState();
}

class _LanguageSwitcherAppState extends State<LanguageSwitcherApp> {
  Locale _locale = const Locale('en', ''); // Default language is English

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hormonal Care', // Puedes obtener el título de las localizaciones si lo agregas
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
      locale: _locale, // Use the selected locale

      home: Stack(
        children: [
          widget.child, // Your entire application content
          Positioned(
            // Puedes ajustar la posición aquí
            bottom: 16.0,
            right: 16.0,
            child: LanguageButton(
              currentLocale: _locale, // Pass the current locale
              onLocaleChange: _changeLanguage, // Pass the change language function
            ),
          ),
        ],
      ),
    );
  }
}