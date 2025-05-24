import 'package:flutter/material.dart';

class ProfileCreationScreen extends StatelessWidget{
  const ProfileCreationScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: CharacterContainer()
    );
  }
}

class CharacterContainer extends StatefulWidget{
  const CharacterContainer({super.key});

  @override
  State<CharacterContainer> createState() => _CharacterContainer();
}

class _CharacterContainer extends State<CharacterContainer>{
  bool _pressed = false;

  void togglePressed() {
    setState(() {
      _pressed = !_pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CharacterText(pressed: _pressed),
        CharacterIcon(pressed: _pressed, onPressed: togglePressed), //pass the press variable down so I dont need a global
      ]
    );
  }
}

class CharacterText extends StatelessWidget{
  final bool pressed;

  const CharacterText({super.key, required this.pressed});

  @override
  Widget build(BuildContext context){
    Alignment placement = pressed ? Alignment(0.0, -0.9) : Alignment(0.0, -0.35);

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      alignment: placement,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Text(('Your Journey Begins'),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Text(('Create your character and start your adventure'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CharacterIcon extends StatelessWidget{// stateless because managed by the container
  final bool pressed;
  final VoidCallback onPressed;

  const CharacterIcon({super.key, required this.pressed, required this.onPressed});

  @override
  Widget build(BuildContext context){
    double iconSize = pressed ? 120: 200;
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: iconSize,
        height: iconSize,
        child: MaterialButton(
          onPressed: onPressed,
          color: Colors.blue,
          shape: CircleBorder(),
        ),
      )
    );
  }
}

