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
