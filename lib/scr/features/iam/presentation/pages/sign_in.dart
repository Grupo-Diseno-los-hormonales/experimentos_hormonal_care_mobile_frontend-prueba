import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/select_user_type.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/pages/admin_tools.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/puzzle_captcha_dialog.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _captchaVerified = false;
  bool _obscureText = true;
  final _authService = AuthService();

    void _verifyCaptcha() async {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PuzzleCaptchaDialog(),
      );
      if (result == true) {
        setState(() {
          _captchaVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    '¡CAPTCHA verificado!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        setState(() {
          _captchaVerified = false;
        });
      }
    }


  void _submit() async {
    if (_formKey.currentState!.validate() && _captchaVerified) {
      final username = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Verifica si es el administrador
      if (username == 'admin' && password == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminToolsScreen()),
        );
        return;
      }

      // Lógica para usuarios normales
      try {
        final token = await _authService.signIn(username, password);
        if (token != null) {
          final role = await _authService.getRole();
          if (role == 'ROLE_PATIENT') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreenPatient()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid credentials')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (!_captchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify the CAPTCHA')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDE6),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/newlogohormonalcare.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to HormonalCare',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA788AB),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Enter your username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Enter your password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _verifyCaptcha,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8F7193),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'Verify CAPTCHA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8F7193),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'Enter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectUserType(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Don't have an account? Register",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}