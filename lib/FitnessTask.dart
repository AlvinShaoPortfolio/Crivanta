import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FitnessTask extends StatefulWidget {
  const FitnessTask({super.key});

  @override
  State<FitnessTask> createState() => _FitnessTaskState();
}

class _FitnessTaskState extends State<FitnessTask> {
  final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final List<String> tasks = [
    "10 Jumping Jacks",
    "20s Plank",
    "15 Squats",
    "10 Push-ups",
    "10 Lunges",
    "20s High Knees",
    "15 Arm Circles",
    "20s Jog in Place"
  ];

  bool isLoading = true;
  bool expGiven = false;
  String? task;

  @override
  void initState() {
    super.initState();
    loadDailyTask();
  }

  Future<void> loadDailyTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('body')
        .doc(todayId)
        .get();

    if (doc.exists) {
      setState(() {
        task = doc.data()?['task'];
        expGiven = doc.data()?['expGiven'] == true;
        isLoading = false;
      });
    } else {
      final newTask = tasks[Random().nextInt(tasks.length)];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('body')
          .doc(todayId)
          .set({'task': newTask});
      setState(() {
        task = newTask;
        isLoading = false;
      });
    }
  }

  Future<void> claimExp() async {
    if (expGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ You already claimed Body EXP for today."),
          backgroundColor: Colors.grey[700],
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || task == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('body')
        .doc(todayId)
        .set({'expGiven': true}, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('onboarding')
        .set({
      'experience': {
        'body': FieldValue.increment(150),
      }
    }, SetOptions(merge: true));

    setState(() => expGiven = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("💪 +150 Body EXP gained!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("💪 Daily Fitness Task",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Today’s Task: $task",
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: claimExp,
          child: const Text("✅ I Did It!"),
        ),
      ],
    );
  }
}
