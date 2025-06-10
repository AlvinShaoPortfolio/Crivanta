import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BudgetBalancer extends StatefulWidget {
  const BudgetBalancer({super.key});

  @override
  State<BudgetBalancer> createState() => _BudgetBalancerState();
}

class _BudgetBalancerState extends State<BudgetBalancer> {
  final double totalBudget = 1000.0;
  final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool expGiven = false;
  bool isLoading = true;

  final Map<String, double> categories = {
    'Rent': 400,
    'Groceries': 150,
    'Entertainment': 100,
    'Transport': 100,
    'Savings': 250,
  };

  @override
  void initState() {
    super.initState();
    checkIfExpGiven();
  }

  Future<void> checkIfExpGiven() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('budget_balancer')
        .doc(todayId)
        .get();

    if (doc.exists && doc.data()?['expGiven'] == true) {
      setState(() => expGiven = true);
    }

    setState(() => isLoading = false);
  }

  Future<void> giveExpOnce() async {
    if (expGiven) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ You already claimed Finance EXP for today.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('onboarding')
        .set({
      'experience': {
        'financial': FieldValue.increment(200),
      }
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('budget_balancer')
        .doc(todayId)
        .set({'expGiven': true});

    setState(() => expGiven = true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✨ You earned +200 Finance EXP!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  double get totalSpent => categories.values.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📊 Budget Balancer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Total Budget: \$${totalBudget.toStringAsFixed(2)}"),
        Text("Current Total: \$${totalSpent.toStringAsFixed(2)}",
            style: TextStyle(color: totalSpent > totalBudget ? Colors.red : Colors.green)),
        const SizedBox(height: 10),
        ...categories.keys.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$category: \$${categories[category]!.toStringAsFixed(2)}"),
              Slider(
                min: 0,
                max: totalBudget,
                divisions: 100,
                value: categories[category]!,
                label: categories[category]!.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() {
                    categories[category] = value;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (totalSpent <= totalBudget) {
                giveExpOnce();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ You are over budget. Adjust your expenses.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Submit Budget"),
          ),
        )
      ],
    );
  }
}
