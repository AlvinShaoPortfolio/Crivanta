import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrivantaLogo extends StatelessWidget{
  const CrivantaLogo({super.key});

  @override
  Widget build(BuildContext context){
    return Image.asset(
      'assets/images/crivantaLogo.png',
      width: 100,
      height: 100,
    );
  }
}

class InputField extends StatelessWidget{
  final IconData myIcon;
  final double horizontalInset, verticalInset;
  final String text;
  final Color myColor;
  final bool obscureText;
  final TextEditingController? controller;

  const InputField({super.key, required this.myIcon, required this.horizontalInset, required this.verticalInset, required this.text, required this.myColor, required this.obscureText, required this.controller});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: verticalInset),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: myColor,
          prefixIcon: Icon(myIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          hintText: text,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
        ),
      ),
    );
  }
}

class DisplayError extends StatelessWidget {
  final String error;
  const DisplayError({super.key, required this.error});

  @override
  Widget build(BuildContext context){
    if (error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(error, style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

Future<int?> getExperience(String userID, String field) async{
  try{
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('profile')
        .doc('onboarding')
        .get();

    final data = doc.data() as Map<String, dynamic>?;

    if(data != null && data['experience'] != null){
      return data['experience'][field] ?? 0;
    }
    else{
      return 0;
    }
  }
  catch(e){
    print('Error fetching experience: $e');
    return null;
  }
}

Future <void> increaseExperience(String userId, String field, int amount) async{
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('onboarding')
        .update({
      'experience.$field': FieldValue.increment(amount),
    });
  }
  catch (e) {
    print('Error incrementing experience: $e');
  }
}

Future<Color> getColor(String userId, String field) async {
  int experience = await getExperience(userId, field) ?? 0;

  if (experience < 500) return Colors.grey;
  if (experience < 1000) return Colors.green;
  if (experience < 2000) return Colors.blue;
  if (experience < 5000) return Colors.purple;
  if (experience < 10000) return Colors.yellow;

  return Colors.red;
}


