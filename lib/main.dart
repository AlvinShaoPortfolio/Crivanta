import 'package:flutter/material.dart';
import 'package:crivanta/profileCreation.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});


  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});


  @override
  State<WelcomeScreen> createState() => _WelcomeScreen();
}


class _WelcomeScreen extends State<WelcomeScreen>{
  bool showWelcome = true;
  bool showLogin = false;


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showWelcome = false;
      });
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        showLogin = true;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children:[
              AnimatedOpacity(
                  opacity: showWelcome? 1.0 : 0.0,
                  duration: const Duration(seconds: 2),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const[
                            Text(("Crivanta"), style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),),
                            Text(("Discover your dream self"), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)
                          ]
                      )
                  )
              ),
              AnimatedOpacity(
                  opacity: showLogin? 1.0 : 0,
                  duration: const Duration(seconds: 1),
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //implement login later
                        children: [
                          Text(('Sign in'), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                          TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Username',),),
                          TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Password',),),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfileCreationScreen()),
                              );
                            },
                            child: Text('Log in'),
                          )
                        ],
                      )
                  )
              )
            ]
        )
    );
  }
}


