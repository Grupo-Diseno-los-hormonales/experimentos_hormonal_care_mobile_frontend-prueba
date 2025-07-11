import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/widget/language_provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/widgets/language_button.dart';

class LanguageSwitcherApp extends StatefulWidget {
  const LanguageSwitcherApp({Key? key}) : super(key: key);

  @override
  _LanguageSwitcherAppState createState() => _LanguageSwitcherAppState();
}

class _LanguageSwitcherAppState extends State<LanguageSwitcherApp> {
  Locale _locale = const Locale('es', ''); // Default language is Spanish

  void _changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LanguageProvider(
      locale: _locale,
      onLanguageChanged: _changeLanguage,
      child: MaterialApp(
        locale: _locale,
        title: 'Medical Care App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xFFA78AAB),
          dialogBackgroundColor: Color(0xFFAEBBC3),
          scaffoldBackgroundColor: Color(0xFFF5F5F5),
        ),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('es', ''),
        ],
        home: LanguageFloatingWrapper(
          child: SignIn(),
          locale: _locale,
          onLanguageChange: _changeLanguage,
        ),
      ),
    );
  }
}

class LanguageFloatingWrapper extends StatelessWidget {
  final Widget child;
  final Locale locale;
  final Function(Locale) onLanguageChange;

  const LanguageFloatingWrapper({
    Key? key,
    required this.child,
    required this.locale,
    required this.onLanguageChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // En lugar de crear un Scaffold nuevo, vamos a envolver el child
    // y usar un Stack para superponer el botón flotante
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 16,
          right: 16,
          child: LanguageButton(
            currentLocale: locale,
            onLocaleChange: onLanguageChange,
          ),
        ),
      ],
    );
  }
}