import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  InputWidget(
      {required this.controller,
      required this.hint,
      this.keyboardType = TextInputType.none,
      this.color = const Color(0xFF383838)});

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: false,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            filled: true,
            fillColor: color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            )),
      ),
    );
  }
}
