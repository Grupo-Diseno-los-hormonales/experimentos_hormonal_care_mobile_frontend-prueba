import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importa el paquete para la localización
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/app.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Reactivar Firebase cuando esté configurado correctamente
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  // TODO: Reactivar App Check cuando Firebase esté configurado
  // FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug, // Use debug token
  // );

  // TODO: Reactivar autenticación cuando Firebase esté configurado
  // FirebaseAuth auth = FirebaseAuth.instance;
  // User? user = auth.currentUser;
  // if (user == null) {
  //   await auth.signInAnonymously();
  // }

  // Inicializa la configuración de la localización
  await initializeDateFormatting('es_ES', null);

  // Ejecuta la aplicación
  runApp(MyApp());
}