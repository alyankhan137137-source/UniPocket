import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final int maxLines;
  final Function(String)? onChanged;
  final bool autofocus;

  const CustomInput({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: maxLines,
          onChanged: onChanged,
          autofocus: autofocus,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            counterText: "", // Hide default counter
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: AppStyles.borderRadiusMedium,
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppStyles.borderRadiusMedium,
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppStyles.borderRadiusMedium,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppStyles.borderRadiusMedium,
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
