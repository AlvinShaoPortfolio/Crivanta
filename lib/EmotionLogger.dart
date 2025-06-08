import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmotionLogger extends StatefulWidget {
  const EmotionLogger({super.key});

  @override
  State<EmotionLogger> createState() => _EmotionLoggerState();
}

class _EmotionLoggerState extends State<EmotionLogger> {
  final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? selectedEmoji;
  bool expGiven = false;

  @override
  void initState() {
    super.initState();
    checkIfLoggedToday();
  }

  Future<void> checkIfLoggedToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('emotions')
        .doc(todayId)
        .get();

    if (doc.exists) {
      setState(() {
        selectedEmoji = doc.data()?['emotion'];
        expGiven = doc.data()?['expGiven'] == true;
      });
    }
  }

  Future<void> logEmotion(String emoji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('emotions')
        .doc(todayId);

    final doc = await docRef.get();
    bool alreadyGivenExp = doc.exists && doc.data()?['expGiven'] == true;

    await docRef.set({
      'emotion': emoji,
      if (!alreadyGivenExp) 'expGiven': true,
    }, SetOptions(merge: true));

    if (!alreadyGivenExp) {
      final onboardingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('onboarding');

      await onboardingRef.set({
        'experience.soul': FieldValue.increment(100),
      }, SetOptions(merge: true));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alreadyGivenExp
                ? '✅ You\'ve already claimed Soul EXP for today.' : '✨ You gained +100 Soul EXP for logging your emotion!',
          ),
          backgroundColor: alreadyGivenExp ? Colors.grey[700] : Colors.deepPurple,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      selectedEmoji = emoji;
      expGiven = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final emojis = ["😊", "😐", "😢", "😡", "😨"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("❤️ Emotion Tracker", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text("How are you feeling today?"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: emojis.map((emoji) {
            final isSelected = emoji == selectedEmoji;
            return ElevatedButton(
              onPressed: () => logEmotion(emoji),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.purple.shade100 : null,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            );
          }).toList(),
        ),
        if (selectedEmoji != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text("You logged: $selectedEmoji", style: const TextStyle(fontSize: 16)),
          ),
      ],
    );
  }
}
