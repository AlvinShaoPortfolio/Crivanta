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
  Map<String, List<String>> history = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGratitudes();
  }

  Future<void> fetchGratitudes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User is null");
        return;
      }

      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gratitudes');

      final snapshots = await collection.orderBy(FieldPath.documentId, descending: true).get();

      Map<String, List<String>> newHistory = {};

      for (final doc in snapshots.docs) {
        final data = doc.data();
        final entries = List<String>.from(data['entries'] ?? []);
        newHistory[doc.id] = entries;
      }

      setState(() {
        todayEntries = newHistory[todayId] ?? [];
        history = newHistory;
        isLoading = false;
      });
    }
    catch (e) {
      print("Error fetching gratitudes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addGratitude(String note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || note.trim().isEmpty) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('gratitudes')
        .doc(todayId);

    final doc = await docRef.get();
    bool alreadyGivenExp = doc.exists && doc.data()?['expGiven'] == true;

    await docRef.set({
      'entries': FieldValue.arrayUnion([note]),
      if (!alreadyGivenExp) 'expGiven': true,
    }, SetOptions(merge: true));

    if (!alreadyGivenExp) {
      final onboardingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('onboarding');

      await onboardingRef.set({
        'experience.soul': FieldValue.increment(200),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              alreadyGivenExp ? '✅ You\'ve already claimed Soul EXP for today.' : '✨ You gained +100 Soul EXP for your daily gratitude!',
            ),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      alreadyGivenExp = true;
    }

    setState(() {
      todayEntries.add(note);
      _controller.clear();
      history[todayId] = todayEntries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator()) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("💫 Daily Gratitude", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),

        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Type your gratitude here...",
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => addGratitude(_controller.text),
            ),
          ),
        ),

        const SizedBox(height: 12),
        const Text("Today's Entries:", style: TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 6),
        ...todayEntries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("• $entry"),
        )),

        const SizedBox(height: 20),
        const Text("📅 Gratitude History", style: TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 6),
        if (history.keys.where((k) => k != todayId).isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text("No past gratitude entries yet."),
          )
        else
          ...history.entries.where((e) => e.key != todayId).map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...entry.value.map((note) => Text("• $note")),
                ],
              ),
            );
          })

      ],
    );
  }
}

