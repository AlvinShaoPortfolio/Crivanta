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
  String? selectedEmotion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayEmotion();
  }

  Future<void> loadTodayEmotion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('emotional')
        .doc(todayId)
        .get();

    if (doc.exists) {
      setState(() {
        selectedEmotion = doc.data()?['emotional'];
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> logEmotion(String emoji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('emotional')
        .doc(todayId);

    final doc = await docRef.get();
    final bool isFirstLogToday = !doc.exists;

    await docRef.set({
      'emotional': emoji,
    }, SetOptions(merge: true));

    if (isFirstLogToday) {
      final profileRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('onboarding');

      await profileRef.set({
        'experience': {
          'emotional': FieldValue.increment(150),
        }
      }, SetOptions(merge: true));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFirstLogToday ? '✨ You gained +100 Emotion EXP for logging today!' : '✅ You already claimed Emotion EXP for today.'),
          backgroundColor: isFirstLogToday ? Colors.pinkAccent : Colors.grey[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      selectedEmotion = emoji;
    });
  }

  @override
  Widget build(BuildContext context) {
    final emojis = ["😊", "😐", "😢", "😡", "😨"];

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("❤️ Emotion Tracker", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("How are you feeling today?"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: emojis.map((emoji) {
            final isSelected = emoji == selectedEmotion;
            return ElevatedButton(
              onPressed: () => logEmotion(emoji),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.pink.shade100 : null,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
