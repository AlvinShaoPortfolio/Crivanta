import 'package:flutter/material.dart';

class SkillProgressCard extends StatelessWidget {
  final String skillName;
  final int level;
  final int currentExp;
  final int expToNext;
  final Color barColor;

  const SkillProgressCard({super.key, required this.skillName, required this.level, required this.currentExp, required this.expToNext, required this.barColor,});

  @override
  Widget build(BuildContext context) {
    double progress = currentExp / expToNext;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skillName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Level $level", style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              color: barColor,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
