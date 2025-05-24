import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    const appTitle = "Crivanta";
    return const MaterialApp(
      title: appTitle,
      home: WelcomeScreen(title: appTitle),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body:WelcomeAnimation(),
    );
  }
}

class WelcomeAnimation extends StatefulWidget {
  const WelcomeAnimation({super.key});

  @override
  State<WelcomeAnimation> createState() => _WelcomeAnimationState();
}

class _WelcomeAnimationState extends State<WelcomeAnimation>{
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _visible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: AnimatedOpacity(
                opacity: _visible? 1.0 : 0.0,
                duration: const Duration(seconds: 2),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const[
                      Text(("Crivanta"), style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),),
                      Text(("Discover your dream self"), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)
                    ]
                )
            )
        )
    );
  }
}