import 'package:crivanta/SkillTab.dart';
import 'package:flutter/material.dart';
import 'package:crivanta/HeaderFileForFunctions.dart';

import 'package:firebase_auth/firebase_auth.dart';

class UserDashboard extends StatelessWidget{
  const UserDashboard({super.key});

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

  Map<String, Color> skillColors = {};
  bool isLoading = true;

  void togglePressed() async{
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

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      //await increaseExperience(user.uid, "body", 100);
      await loadColors();
    }
  }

  @override
  void initState() {
    super.initState();
    loadColors();
  }

  Future<void> loadColors() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    if (userId == null) return;

    Map<String, Color> newColors = {};
    final List<String> fields = [
      'mind', 'body', 'soul', 'emotional', 'financial', 'social'
    ];

    for (final field in fields) {
      newColors[field] = await getColor(userId, field);
    }

    setState(() {
      skillColors = newColors;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || skillColors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
        children: [
          SkillsIcon(name: "Mind", showSkills: showSkills, myColor: skillColors["mind"]!, xCoord: .8, yCoord: -0.15),
          SkillsIcon(name: "Body", showSkills: showSkills, myColor: skillColors["body"]!, xCoord: 0.0, yCoord: -0.3),
          SkillsIcon(name: "Soul", showSkills: showSkills, myColor: skillColors["soul"]!, xCoord: -.8, yCoord: -0.15),
          SkillsIcon(name: "Emotions", showSkills: showSkills, myColor: skillColors["emotional"]!, xCoord: 0.0, yCoord: 0.3),
          SkillsIcon(name: "Finance", showSkills: showSkills, myColor: skillColors["financial"]!, xCoord: .8, yCoord: 0.15),
          SkillsIcon(name: "Social", showSkills: showSkills, myColor: skillColors["social"]!, xCoord: -.8, yCoord: 0.15),
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
          Text(('Ready to improve today?'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

class SkillsIcon extends StatefulWidget{
  final bool showSkills;
  final String name;
  final Color myColor;
  final double xCoord, yCoord;

  const SkillsIcon({super.key, required this.name, required this.showSkills, required this.myColor, required this.xCoord, required this.yCoord});

  @override
  State<SkillsIcon> createState() => _SkillsIconState();
}

class _SkillsIconState extends State<SkillsIcon> {
  @override
  Widget build(BuildContext context){
    Alignment placement = widget.showSkills ? Alignment(widget.xCoord, widget.yCoord) : Alignment(0.0, 0.0);

    return AnimatedOpacity(//controlling the fading in
      opacity: widget.showSkills ? 1.0 : 0.0,
      duration: Duration(milliseconds: 250),
      child: AnimatedAlign(//controlling the axis change
        duration: Duration(milliseconds: 250),
        alignment: placement,
        child: Stack(
          children: [
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SkillTab(skillName: widget.name, skillColor: widget.myColor)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.myColor,
                fixedSize: const Size(110, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Center(
                child: Text(widget.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        )
      )
    );
  }
}




