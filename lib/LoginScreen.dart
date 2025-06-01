import 'package:flutter/material.dart';
import 'SignupScreen.dart';
import 'UserDashboard.dart';
import 'HeaderFileForFunctions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'FirebaseAuthentication.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen>{
  final authService = FirebaseAuthentication();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CrivantaLogo(),
              const Text('Welcome to Crivanta', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const Text('Sign in to continue', style: TextStyle(fontSize: 15)),
              SizedBox(height: 20),
              InputField(myIcon: Icons.email_outlined, horizontalInset: 32, verticalInset: 16, text: "Email", myColor: Colors.black12, obscureText: false, controller: emailController),
              SizedBox(height: 10),
              InputField(myIcon: Icons.lock_open_rounded, horizontalInset: 32, verticalInset: 16, text: "Password", myColor: Colors.black12, obscureText: true, controller: passwordController),

              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        UserCredential credential = await authService.signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        User? user = credential.user;

                        if (user != null && !user.emailVerified) {
                          setState(() {
                            error = 'Please verify your email before logging in.';
                          });
                          return;
                        }

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Userdashboard()),
                        );
                      } on FirebaseAuthException catch(e){
                        setState((){
                          switch (e.code) {
                            case 'user-not-found':
                              error = 'No user found with this email.';
                              break;
                            case 'wrong-password':
                              error = 'Incorrect password.';
                              break;
                            case 'invalid-email':
                              error = 'Invalid email address.';
                              break;
                            default:
                              error = 'Login failed: ${e.message}';
                          }
                        });
                      }
                    },
                    child: const Text('Sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              TextButton( //redirection to the sign up page button
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign up', style: TextStyle(color: Color(0xFF42A5F5))),
              )
            ],
          ),
        ),
      ),
    );
  }
}