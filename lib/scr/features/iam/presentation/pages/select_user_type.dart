import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_up_doctor.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_up_patient.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class SelectUserType extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your User Type'),
        backgroundColor: Color(0xFF6A828D),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select your user type:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await JwtStorage.saveRole('ROLE_DOCTOR');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpDoctor()),
                  );
                },
                child: Text('Doctor'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await JwtStorage.saveRole('ROLE_PATIENT');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPatient()),
                  );
                },
                child: Text('Patient'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}