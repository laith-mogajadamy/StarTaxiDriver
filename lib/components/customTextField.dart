import 'package:driver_taxi/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color hintColor;
  final Color iconColor;
  final IconData? iconData;
  final double fontSize;
  final IconButton? suffixIcon;
  final bool? obscureText;
  final bool isNumeric;
  final TextInputType? keyboardType;
  final Color fillColor;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.fillColor = AppColors.textField_color,
    this.hintColor = Colors.black26,
    this.iconColor = Colors.black,
    this.iconData,
    this.fontSize = 17.0,
    this.suffixIcon,
    this.obscureText,
    this.validator,
    this.isNumeric = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: isNumeric ? TextInputType.number : keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, fontSize: fontSize),
        filled: true,
        fillColor: fillColor,
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          iconData,
          color: iconColor,
          size: 21,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 17.0),
      ),
      obscureText: obscureText ?? false,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
