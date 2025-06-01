import 'package:flutter/material.dart';
import 'profileCreation.dart';
import 'HeaderFileForFunctions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'FirebaseAuthentication.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreen();
}


class _SignupScreen extends State<SignupScreen>{
  final authService = FirebaseAuthentication();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/crivantaLogo.png',
                width: 100,
                height: 100,
              ),
              const Text('Sign up', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              InputField(myIcon: Icons.email_outlined, horizontalInset: 32, verticalInset: 16, text: "Email", myColor: Colors.black12, obscureText: false, controller: emailController),
              const SizedBox(height: 16),
              InputField(myIcon: Icons.lock_open_rounded, horizontalInset: 32, verticalInset: 16,text: "Password", myColor: Colors.black12, obscureText: true, controller: passwordController),
              const SizedBox(height: 16),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 8),
                  child: Text(
                    error,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: () async {
                  try {
                    await authService.signUp(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileCreationScreen()),
                    );
                  }
                  on FirebaseAuthException catch (e) {
                    setState(() {
                      error = e.message ?? 'Signup failed';
                    });
                  }
                },
                child: const Text('Sign up'),
              ),
            ],
          ),
        )
      ),
    );
  }
}
