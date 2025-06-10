import 'package:crivanta/FitnessTask.dart';
import 'package:crivanta/SocialBingo.dart';
import 'package:flutter/material.dart';
import 'package:crivanta/EmotionLogger.dart';
import 'package:crivanta/GratitudeWidget.dart';
import 'package:crivanta/MindMemoryGame.dart';
import 'package:crivanta/BudgetBalancer.dart';

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
    case 'finance':
      return _financeQuiz();
    case 'social':
      return _conversationPrompt();
    default:
      return const Text("This skill has no additional content yet.");
  }
}

Widget _memoryPuzzle() {
  return MindMemoryGame();
}

Widget _workoutTip() {
  return FitnessTask();
}

Widget _dailyGratitude() {
  return const GratitudeWidget();

}

Widget _emotionTracker() {
  return const EmotionLogger();
}

Widget _financeQuiz() {
  return const BudgetBalancer();
}

Widget _conversationPrompt() {
  return SocialBingo();
}