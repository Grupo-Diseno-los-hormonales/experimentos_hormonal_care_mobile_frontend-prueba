import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/shared/presentation/pages/home_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Care App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6A828D),
        dialogBackgroundColor: Color(0xFFAEBBC3), // Color verde claro
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: SignIn(), // Cambiar la pantalla inicial a SignIn
      //home: HomeScreen(),
    );
  }
}