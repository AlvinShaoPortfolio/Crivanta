import 'package:flutter/material.dart';

class Userdashboard extends StatelessWidget{
  const Userdashboard({super.key});

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
  bool pressed = false;
  bool showSkills = false;

  void togglePressed() {
    setState(() {
      pressed = !pressed;
    });

    if (pressed) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && pressed) {
          setState(() {
            showSkills = true;
          });
        }
      });
    }
    else {
      setState(() {
        showSkills = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          SkillsIcon(name: "Mind", showSkills: showSkills, myColor: Colors.blue, xCoord: .8, yCoord: -0.15),
          SkillsIcon(name: "Body", showSkills: showSkills, myColor: Colors.blue, xCoord: 0.0, yCoord: -0.3),
          SkillsIcon(name: "Soul", showSkills: showSkills, myColor: Colors.blue, xCoord: -.8, yCoord: -0.15),
          SkillsIcon(name: "Emotions", showSkills: showSkills, myColor: Colors.blue, xCoord: 0.0, yCoord: 0.3),
          SkillsIcon(name: "Financial", showSkills: showSkills, myColor: Colors.blue, xCoord: .8, yCoord: 0.15),
          SkillsIcon(name: "Social", showSkills: showSkills, myColor: Colors.blue, xCoord: -.8, yCoord: 0.15),
          CharacterText(pressed: pressed),
          CharacterIcon(pressed: pressed, onPressed: togglePressed), //passing variables down so I dont need a global but idk if this is common practice over just making stateful widgets
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
      duration: Duration(milliseconds: 250),
      alignment: placement,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Text(('Your Journey Begins'), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Text(('Create your character and start your adventure'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
    double iconSize = pressed ? 100: 200;
    return Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
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
  final bool showSkills;
  final String name;
  final Color myColor;
  final double xCoord, yCoord;

  const SkillsIcon({super.key, required this.name, required this.showSkills, required this.myColor, required this.xCoord, required this.yCoord});

  @override
  Widget build(BuildContext context){
    Alignment placement = showSkills ? Alignment(xCoord, yCoord) : Alignment(0.0, 0.0);

    return AnimatedOpacity(//controlling the fading in
        opacity: showSkills ? 1.0 : 0.0,
        duration: Duration(milliseconds: 250),
        child: AnimatedAlign(//controlling the axis change
            duration: Duration(milliseconds: 250),
            alignment: placement,
            child: Stack(
                children: [
                  Container( //the actual box
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(name, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ]
            )
        )
    );
  }
}





