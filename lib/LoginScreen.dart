import 'package:flutter/material.dart';
import 'SignupScreen.dart';
import 'profileCreation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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

            const Text('Welcome to Crivanta', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const Text('Sign in to continue', style: TextStyle(fontSize: 15)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50)
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF0F0F0),
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'Email',
                  focusColor: Colors.blueGrey,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF0F0F0),
                  prefixIcon: Icon(Icons.lock_open_rounded),
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                  focusColor: Colors.blueGrey,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
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

            TextButton(
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
    );
  }
}
