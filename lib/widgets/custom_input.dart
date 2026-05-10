import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// A standardized text input field for the application.
/// 
/// This widget provides a consistent look and feel for all text entries, 
/// including custom styling for borders, padding, and icons. It supports
/// validation, different keyboard types, and password masking.
class CustomInput extends StatelessWidget {
  /// Controller for the text being edited.
  final TextEditingController? controller;
  
  /// The label displayed above the input field.
  final String label;
  
  /// Optional placeholder text shown inside the field.
  final String? hint;
  
  /// Widget to display at the beginning of the input field (e.g., an Icon).
  final Widget? prefixIcon;
  
  /// Widget to display at the end of the input field (e.g., a clear button or eye icon).
  final Widget? suffixIcon;
  
  /// A function that takes the current text and returns an error message if invalid.
  final String? Function(String?)? validator;
  
  /// The type of keyboard to display (e.g., email, numeric, phone).
  final TextInputType keyboardType;
  
  /// Whether to hide the text being entered (used for passwords).
  final bool obscureText;
  
  /// The maximum number of characters allowed.
  final int? maxLength;
  
  /// The maximum number of lines the input can expand to.
  final int maxLines;
  
  /// Callback triggered whenever the text content changes.
  final Function(String)? onChanged;
  
  /// Whether the field should automatically focus when it appears.
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
