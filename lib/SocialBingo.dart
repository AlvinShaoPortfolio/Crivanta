import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SocialBingo extends StatefulWidget {
  const SocialBingo({super.key});

  @override
  State<SocialBingo> createState() => _SocialBingoState();
}

class _SocialBingoState extends State<SocialBingo> {
  final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final List<String> allPrompts = [
    "Say hi to someone new",
    "Message an old friend",
    "Join a group chat",
    "Compliment someone",
    "Laugh with a friend",
    "Send a meme",
    "Make small talk",
    "Ask someone how they're doing",
    "Share a song",
    "Plan a hangout",
    "Text a family member",
    "Say thank you",
    "React to a post",
    "Join a voice chat",
    "Share good news",
    "Encourage someone",
    "Participate in class",
    "Talk to a stranger",
    "Check in on a friend",
    "Reply to a message",
    "Introduce two friends",
    "Smile at someone",
    "Help someone online",
    "Reconnect with someone",
    "Be kind in comments"
  ];

  List<String> dailyPrompts = [];
  Set<int> completed = {};
  bool expGiven = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBoard();
  }

  Future<void> loadBoard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('social')
        .doc(todayId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      List<String> loadedPrompts = List<String>.from(data['prompts'] ?? []);

      if (loadedPrompts.length < 25) {
        loadedPrompts.addAll(
            allPrompts.where((p) => !loadedPrompts.contains(p)).take(25 - loadedPrompts.length)
        );
      } else if (loadedPrompts.length > 25) {
        loadedPrompts = loadedPrompts.sublist(0, 25);
      }

      setState(() {
        dailyPrompts = loadedPrompts;
        completed = Set<int>.from(data['completed'] ?? []);
        expGiven = data['expGiven'] == true;
        isLoading = false;
      });
    } else {
      dailyPrompts = List<String>.from(allPrompts)..shuffle();
      dailyPrompts = dailyPrompts.take(25).toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('social')
          .doc(todayId)
          .set({'prompts': dailyPrompts, 'completed': []});

      setState(() => isLoading = false);
    }
  }

  Future<void> togglePrompt(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (completed.contains(index)) {
      if (context.mounted && expGiven) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ You already claimed Social EXP for today.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
      return;
    }

    completed.add(index);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('social')
        .doc(todayId)
        .update({'completed': completed.toList()});

    if (!expGiven && hasBingo()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('onboarding')
          .set({
        'experience': {'social': FieldValue.increment(150)},
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('social')
          .doc(todayId)
          .set({'expGiven': true}, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Bingo complete! +150 Social EXP earned!'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      }

      setState(() => expGiven = true);
    }

    setState(() {});
  }

  bool hasBingo() {
    for (int i = 0; i < 5; i++) {
      if (List.generate(5, (j) => i * 5 + j).every(completed.contains)) return true;
      if (List.generate(5, (j) => j * 5 + i).every(completed.contains)) return true;
    }
    if (List.generate(5, (i) => i * 6).every(completed.contains)) return true;
    if (List.generate(5, (i) => (i + 1) * 4).every(completed.contains)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🫂 Social Bingo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Tap each task you've completed today!"),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 25,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final isDone = completed.contains(index);
            return GestureDetector(
              onTap: () => togglePrompt(index),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDone ? Colors.lightBlue.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Center(
                  child: Text(
                    dailyPrompts.length > index ? dailyPrompts[index] : "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDone ? Colors.blue.shade900 : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}