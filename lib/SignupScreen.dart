import 'dart:ui';
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
  bool isLoading = false;

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
              const SizedBox(height: 16), //email textblurb
              InputField(myIcon: Icons.email_outlined, horizontalInset: 32, verticalInset: 16, text: "Email", myColor: Colors.black12, obscureText: false, controller: emailController),
              const SizedBox(height: 16), //password text blurb
              InputField(myIcon: Icons.lock_open_rounded, horizontalInset: 32, verticalInset: 16,text: "Password", myColor: Colors.black12, obscureText: true, controller: passwordController),
              const SizedBox(height: 16),
              DisplayError(error: error), //error message if required

              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true);
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  checkEmail(email); //checks to see if the email follows correct format

                  try {
                    await authService.signUp(email, password); //creates a firebase user and waits for it to fufill

                    User? user = FirebaseAuth.instance.currentUser; //sets user to the instance of the current user

                    if (user != null && !user.emailVerified) { //if user has not verified then keep them on the verification dialog
                      await user.sendEmailVerification();
                      _showVerificationDialog(user);
                    }

                    setState(() {
                      error = 'Verification email sent. Please verify before proceeding.';
                    });
                  }
                  on FirebaseAuthException catch (e) { // if signup failed show error msg
                    setState(() {
                      error = e.message ?? 'Signup failed';
                      isLoading = false;
                    });
                  }
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('Sign up'), // loading circle on the sign up
              ),
            ],
          ),
        )
      ),
    );
  }

  void _showVerificationDialog(User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Your Email'),
          content: const Text('A verification email has been sent. Please verify and click Continue.'),
          actions: [
            TextButton(
              onPressed: () async {
                await user.reload();
                user = authService.currentUser!;
                if (user.emailVerified) {
                  Navigator.pop(context); // close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileCreation()),
                  );
                } else {
                  setState(() {
                    error = "Email not verified yet.";
                    isLoading = false;
                  });
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void checkEmail(String email){
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        error = 'Please enter a valid email address.';
      });
      return;
    }
  }
}


