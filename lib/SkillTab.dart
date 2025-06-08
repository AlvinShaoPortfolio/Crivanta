import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'SkillProgressCard.dart';
import 'SkillQuizzes.dart';

class SkillTab extends StatefulWidget{
  final String skillName;
  final Color skillColor;

  const SkillTab({super.key, required this.skillName, required this.skillColor});

  @override
  State<SkillTab> createState() => _SkillTabState();
}

class _SkillTabState extends State<SkillTab> {
  int totalExp = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSkillData();
  }

  Future<void> fetchSkillData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('onboarding')
        .get();

    if (doc.exists) {
      final experienceData = doc.data()?['experience'] ?? {};
      final exp = experienceData[widget.skillName.toLowerCase()] ?? 0;

      setState(() {
        totalExp = exp;
        isLoading = false;
      });
    }
    else {
      print('onboarding doc not found');
      setState(() {
        totalExp = 0;
        isLoading = false;
      });
    }
  }

  int calculateLevel(int exp) {
    if (exp < 500) return 1;
    if (exp < 1000) return 2;
    if (exp < 2000) return 3;
    if (exp < 5000) return 4;
    if (exp < 10000) return 5;
    return 6;
  }

  int expToNextLevel(int exp) {
    int level = calculateLevel(exp);
    if(level == 1) return 1000 - exp;
    if(level == 2) return 2000 - exp;
    if(level == 3) return 5000 - exp;
    if(level == 4) return 10000 - exp;
    return 0;
  }

  int currentExpInLevel(int exp) {
    int level = calculateLevel(exp);
    if(level == 1) return 500-exp;
    if(level == 2) return 1000 - exp;
    if(level == 3) return 2000 - exp;
    if(level == 4) return 5000 - exp;
    if(level == 4) return 10000 - exp;
    return 0;
  }

  @override
  Widget build(BuildContext context){
    int level = calculateLevel(totalExp);
    int nextLevelExp = expToNextLevel(totalExp);
    int currentLevelExp = currentExpInLevel(totalExp);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skillName),
        backgroundColor: widget.skillColor,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SkillProgressCard(
              skillName: widget.skillName,
              level: level,
              currentExp: currentLevelExp,
              expToNext: nextLevelExp - ((level - 1) * 500),
              barColor: widget.skillColor,
            ),
            const SizedBox(height: 20),
            Expanded(child: getSkillSpecificContent(widget.skillName.toLowerCase())),
          ],
        ),
      ),
    );
  }
}
