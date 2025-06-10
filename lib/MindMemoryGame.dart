import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MindMemoryGame extends StatefulWidget {
  const MindMemoryGame({super.key});

  @override
  State<MindMemoryGame> createState() => _MindMemoryGameState();
}

class _MindMemoryGameState extends State<MindMemoryGame> {
  final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final List<String> emojiPool = ["\uD83C\uDF4E", "\uD83C\uDF4C", "\uD83C\uDF47", "\uD83C\uDF53", "\uD83C\uDF4D", "\uD83C\uDF49", "\uD83E\uDD5D", "\uD83E\uDD51"];
  List<Map<String, dynamic>> cards = [];
  List<int> revealed = [];
  bool isBusy = false;
  bool completed = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initGame();
    checkCompletion();
  }

  void initGame() {
    final List<String> allEmojis = [...emojiPool, ...emojiPool];
    allEmojis.shuffle(Random());
    cards = List.generate(allEmojis.length, (i) => {
      "emoji": allEmojis[i],
      "revealed": false,
      "matched": false,
    });
  }

  Future<void> checkCompletion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('memory')
        .doc(todayId)
        .get();

    if (doc.exists) {
      setState(() {
        completed = true;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ You\'ve already completed today\'s memory game!'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> handleMatchCompletion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('memory')
        .doc(todayId)
        .set({'expGiven': true}, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('onboarding')
        .set({'experience': {
      'mind': FieldValue.increment(150),
    }
    }, SetOptions(merge: true));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('\uD83E\uDDE0 +150 Mind EXP gained!'),
          backgroundColor: Colors.indigo,
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      completed = true;
    });
  }

  void handleTap(int index) {
    if (isBusy || cards[index]["revealed"] || cards[index]["matched"] || completed) return;

    setState(() {
      cards[index]["revealed"] = true;
      revealed.add(index);
    });

    if (revealed.length == 2) {
      isBusy = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        final a = revealed[0], b = revealed[1];
        if (cards[a]["emoji"] == cards[b]["emoji"]) {
          cards[a]["matched"] = true;
          cards[b]["matched"] = true;
        } else {
          cards[a]["revealed"] = false;
          cards[b]["revealed"] = false;
        }
        revealed.clear();
        isBusy = false;

        if (cards.every((card) => card["matched"])) {
          handleMatchCompletion();
        }

        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("\uD83E\uDDE0 Memory Match", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text("Match all pairs to gain EXP!"),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return GestureDetector(
              onTap: () => handleTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: card["matched"] || card["revealed"]
                      ? Colors.indigo[100]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  card["revealed"] || card["matched"] ? card["emoji"] : "❓",
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}