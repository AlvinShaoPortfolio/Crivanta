import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'UserDashboard.dart';

class ProfileCreation extends StatelessWidget{
  const ProfileCreation({super.key});

  @override
  Widget build(BuildContext context){
    return startingQuestionnaire();
  }
}

class startingQuestionnaire extends StatefulWidget{

  const startingQuestionnaire({super.key});

  @override
  State<startingQuestionnaire> createState() => _startingQuestionnaire();
}

class _startingQuestionnaire extends State<startingQuestionnaire>{
  final List<Map<String, dynamic>> questionData = [
    {
      "question": "What is your age group?",
      "options": ["Under 18", "18-24", "25-34", "34-44", "45-54", "55+"],
      "max": 1,
    },
    {
      "question": "What is your primary self-improvement goal?",
      "options": ["Mental Clarity and focus", "Physical health and fitness", "Emotional resilience", "Financial growth and independence", "Social skills and relationships", "Productivity and time management", "Spiritual growth and purpose"],
      "max": 7,
    },
    {
      "question": "Which areas of self improvement are you most interested in?",
      "options": ["Mind", "Body", "Soul", "Emotional", "Financial", "Social", "Productivity"],
      "max": 3,
    },
    {
      "question": "What is your experience level in self-Improvement",
      "options": ["Beginner", "Intermediate", "Advanced"],
      "max": 1,
    },
    {
      "question": "How do you prefer to learn?",
      "options": ["Reading articles", "Watching Videos", "Listen to podcasts", "Interactive challenges or courses"],
      "max": 1,
    },
    {
      "question": "How much time do you dedicate to self-improvement daily?",
      "options": ["Less than 10 minutes", "10-30 minutes", "30-60 minutes", "Over an hour"],
      "max": 1,
    },
    {
      "question": "What is your biggest self-improvement challenge?",
      "options": ["Staying consistent", "Finding the right information", "Lack of motivation", "Managing time effectively", "Overcoming self-doubt"],
      "max": 1,
    },
  ];
  final Map<int, Set<String>> answers = {};

  void updateAnswer(int index, Set<String> selected) {
    setState(() {
      answers[index] = selected;
    });
  }

  void handleSubmit() async{
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.')),
      );
      return;
    }

    Map<String, dynamic> submission = {};

    for (int i = 0; i < questionData.length; i++) {
      String questionText = questionData[i]["question"];
      Set<String> selectedOptions = answers[i] ?? {};
      submission[questionText] = selectedOptions.toList();
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile') // optional: or just use .doc('profile')
          .doc('questionnaire')
          .set({
        'timestamp': FieldValue.serverTimestamp(),
        'responses': submission,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserDashboard()),
      );
    }
    catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    }
  }

  bool hasOneAnswer(){
    for (int i = 0; i < questionData.length; i++) {
      if (!answers.containsKey(i) || answers[i]!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...List.generate(questionData.length, (i) {
            final q = questionData[i];
            return MultipleChoiceQuestion(
              key: ValueKey(i),
              question: q["question"],
              options: List<String>.from(q["options"]),
              maxSelections: q["max"],
              onSelectionChanged: (selected) => updateAnswer(i, selected),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: hasOneAnswer() ? handleSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasOneAnswer() ? Colors.blue : Colors.grey,
            ),
            child: const Text("Submit"),
          ),
        ],
      )
    );
  }

}

class MultipleChoiceQuestion extends StatefulWidget{
  final String question;
  final List<String> options;
  final int maxSelections;
  final void Function(Set<String>) onSelectionChanged;

  const MultipleChoiceQuestion({super.key, required this.question, required this.options, required this.maxSelections, required this.onSelectionChanged});

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestion();
}

class _MultipleChoiceQuestion extends State<MultipleChoiceQuestion>{
  final Set<String> selectedChoices = {};

  void toggleOption(String option) {
    setState(() {
      if (selectedChoices.contains(option)) {
        selectedChoices.remove(option);
      } else {
        if (selectedChoices.length < widget.maxSelections) {
          selectedChoices.add(option);
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You can only select up to ${widget.maxSelections} option(s)."),
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }
      }
      widget.onSelectionChanged(selectedChoices);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.options.map((option) {
            return MultipleChoiceOption(
              choice: option,
              selected: selectedChoices.contains(option),
              onPressed: () => toggleOption(option),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class MultipleChoiceOption extends StatelessWidget{
  final String choice;
  final bool selected;
  final VoidCallback onPressed;

  const MultipleChoiceOption({super.key, required this.choice, required this.selected, required this.onPressed,});

  @override
  Widget build(BuildContext context){
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(selected ? Colors.blue : Colors.white),
        foregroundColor: WidgetStateProperty.all(selected ? Colors.black : Colors.black),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.black),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        ),
      ),
      child: Text(choice),
    );
  }
}
