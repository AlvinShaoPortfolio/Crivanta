import 'package:crivanta/GratitudeWidget.dart';
import 'package:flutter/material.dart';

Widget getSkillSpecificContent(String skillName) {
  switch (skillName.toLowerCase()) {
    case 'mind':
      return _memoryPuzzle();
    case 'body':
      return _workoutTip();
    case 'soul':
      return _dailyGratitude();
    case 'emotions':
      return _emotionTracker();
    case 'financial':
      return _financeQuiz();
    case 'social':
      return _conversationPrompt();
    default:
      return const Text("This skill has no additional content yet.");
  }
}

Widget _memoryPuzzle() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text("🧠 Memory Puzzle", style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text("Try to remember this sequence:"),
      Text("🍎 🐶 🎵 🚗 🕹️", style: TextStyle(fontSize: 24)),
      SizedBox(height: 8),
      Text("Come back in 10 seconds and recall them!"),
    ],
  );
}

Widget _workoutTip() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text("🏋️ Workout Tip", style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text("Try a 60-second wall sit after reading this!"),
    ],
  );
}

Widget _dailyGratitude() {
  return const GratitudeWidget();

}

Widget _emotionTracker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("❤️ Emotion Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text("How are you feeling right now?"),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: ["😊", "😐", "😢", "😡", "😨"].map((emoji) {
          return ElevatedButton(
            onPressed: () => debugPrint("Selected: $emoji"),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          );
        }).toList(),
      ),
    ],
  );
}

Widget _financeQuiz() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("💰 Finance Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text("What is a budget?"),
      const SizedBox(height: 8),
      Column(
        children: [
          ElevatedButton(onPressed: () {}, child: const Text("A way to track spending")),
          ElevatedButton(onPressed: () {}, child: const Text("A type of loan")),
          ElevatedButton(onPressed: () {}, child: const Text("A new cryptocurrency")),
        ],
      )
    ],
  );
}

Widget _conversationPrompt() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text("👥 Conversation Prompt", style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text("Ask someone: “What’s something you’re excited about lately?”"),
    ],
  );
}