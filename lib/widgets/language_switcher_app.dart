import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Provider global para el idioma
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', '');
  
  Locale get locale => _locale;
  
  void changeLanguage(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

// Instancia global del provider
final LanguageProvider languageProvider = LanguageProvider();

class LanguageSwitcherApp extends StatefulWidget {
  final Widget child;

  const LanguageSwitcherApp({Key? key, required this.child}) : super(key: key);

  @override
  _LanguageSwitcherAppState createState() => _LanguageSwitcherAppState();
}

class _LanguageSwitcherAppState extends State<LanguageSwitcherApp> {
  @override
  void initState() {
    super.initState();
    languageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppLocalizations.of(context)?.hormonalCareTitle ?? 'Hormonal Care',
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
      locale: languageProvider.locale,
      home: widget.child,
    );
  }
}