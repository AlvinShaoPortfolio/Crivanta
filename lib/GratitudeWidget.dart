import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GratitudeWidget extends StatefulWidget {
  const GratitudeWidget({super.key});

  @override
  State<GratitudeWidget> createState() => _GratitudeWidgetState();
}

class _GratitudeWidgetState extends State<GratitudeWidget> {
  final TextEditingController _controller = TextEditingController();
  final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<String> todayEntries = [];
  Map<String, List<String>> pastGratitudes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGratitudes();
  }

  Future<void> loadGratitudes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('gratitudes');

    final snap = await ref.orderBy(FieldPath.documentId, descending: true).get();

    final Map<String, List<String>> loaded = {};
    for (final doc in snap.docs) {
      final entries = List<String>.from(doc.data()['entries'] ?? []);
      loaded[doc.id] = entries;
    }

    setState(() {
      todayEntries = loaded[todayId] ?? [];
      pastGratitudes = Map.fromEntries(
        loaded.entries.where((e) => e.key != todayId),
      );
      isLoading = false;
    });
  }

  Future<void> submitGratitude(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('gratitudes')
        .doc(todayId);

    final bool firstEntry = todayEntries.isEmpty;

    await docRef.set({
      'entries': FieldValue.arrayUnion([text]),
    }, SetOptions(merge: true));

    if (firstEntry) {
      final profileRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('onboarding');

      await profileRef.set({
        'experience.soul': FieldValue.increment(200),
      }, SetOptions(merge: true));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firstEntry
              ? '✨ You gained +200 Soul EXP for your daily gratitude!'
              : '✅ You\'ve already claimed Soul EXP for today.'),
          backgroundColor: firstEntry ? Colors.deepPurple : Colors.grey[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      todayEntries.add(text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("💫 Daily Gratitude", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'What are you grateful for today?',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => submitGratitude(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Today's Entries:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...todayEntries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text("• $e"),
            )),
            const SizedBox(height: 24),
            const Text("📅 Gratitude History", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (pastGratitudes.isEmpty)
              const Text("No past entries yet.")
            else
              ...pastGratitudes.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...entry.value.map((e) => Text("• $e")),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}
