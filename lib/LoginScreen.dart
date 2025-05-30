import 'package:flutter/material.dart';
import 'SignupScreen.dart';
import 'profileCreation.dart';
import 'HeaderFileForFunctions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              //InputField(myIcon: Icons.email_outlined, horizontalInset: 32, verticalInset: 16, text: "Email", myColor: Colors.black12, obscureText: false),
              SizedBox(height: 10),
              //InputField(myIcon: Icons.lock_open_rounded, horizontalInset: 32, verticalInset: 16, text: "Password", myColor: Colors.black12, obscureText: true),
              Padding( //sign in button
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileCreationScreen()),
                      );
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