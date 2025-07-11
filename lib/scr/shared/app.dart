import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importar el archivo generado

class MyApp extends StatelessWidget {
  final Locale? locale;
  final Function(Locale)? onLanguageChanged;

  const MyApp({Key? key, this.locale, this.onLanguageChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Care App',
      debugShowCheckedModeBanner: false,
      locale: locale, // Usar el locale pasado al widget
      theme: ThemeData(
        primaryColor: Color(0xFFA78AAB),
        dialogBackgroundColor: Color(0xFFAEBBC3), // Color verde claro
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: SignIn(), // Cambiar la pantalla inicial a SignIn
      localizationsDelegates: [
        AppLocalizations.delegate, // Tu delegado de localización
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('es', ''), // Spanish
      ],
      //home: HomeScreen(),
      //home: HomeScreenPatient(), // Cambiar la pantalla inicial a HomeScreen de PACIENTE
    );
  }
}