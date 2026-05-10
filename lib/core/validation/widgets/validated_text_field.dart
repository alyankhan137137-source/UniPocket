import 'dart:async';
import 'package:flutter/material.dart';
import '../validation_result.dart';
import '../sanitizers/input_sanitizer.dart';

/// A [TextFormField] wrapper that provides real-time validation and debouncing.
/// 
/// This widget handles the complexity of showing validation errors as the user
/// types, using a debounce timer to avoid flickering. It also supports optional
/// input sanitization when the field is submitted.
class ValidatedTextField extends StatefulWidget {
  /// The controller for the text being edited.
  final TextEditingController controller;
  
  /// The label text shown above or within the field.
  final String label;
  
  /// Optional placeholder text.
  final String? hint;
  
  /// A callback that takes the current text and returns a [ValidationResult].
  final ValidationResult Function(String?) validator;
  
  /// The type of keyboard to display.
  final TextInputType keyboardType;
  
  /// Optional icon to display at the start of the field.
  final IconData? icon;
  
  /// Callback triggered after the debounce period when the text changes.
  final Function(String)? onChanged;
  
  /// Whether to apply [InputSanitizer] to the text when the user finishes editing.
  final bool sanitizeOnFinish;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.onChanged,
    this.sanitizeOnFinish = true,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  ValidationResult _result = ValidationResult.valid();
  Timer? _debounce;
  bool _hasStartedTyping = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Handles text changes with debouncing to update validation state.
  void _onChanged(String value) {
    if (!_hasStartedTyping) setState(() => _hasStartedTyping = true);
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _result = widget.validator(value);
        });
        if (widget.onChanged != null) widget.onChanged!(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            suffixIcon: _hasStartedTyping && _result.isValid 
                ? const Icon(Icons.check_circle, color: Colors.green) 
                : null,
            errorText: _hasStartedTyping && !_result.isValid ? _result.errorMessage : null,
            border: const OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (widget.sanitizeOnFinish) {
              widget.controller.text = InputSanitizer.sanitizeString(value);
            }
          },
        ),
      ],
    );
  }
}
