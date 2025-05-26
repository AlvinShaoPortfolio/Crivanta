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
        SkillsIcon(name: "Mental Clarity", pressed: _pressed, myColor: Colors.blue, xCoord: 0.0, yCoord: 0.5)
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

class SkillsIcon extends StatelessWidget{
  final bool pressed;
  final String name;
  final Color myColor;
  final double xCoord, yCoord;

  const SkillsIcon({super.key, required this.name, required this.pressed, required this.myColor, required this.xCoord, required this.yCoord});

  @override
  Widget build(BuildContext context){
    if(!pressed){
      return const SizedBox.shrink();
    }

    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(name, style: const TextStyle(color: Colors.white)),
        ),
      )
    );
  }
}
