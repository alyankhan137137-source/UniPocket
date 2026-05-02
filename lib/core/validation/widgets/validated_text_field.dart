import 'dart:async';
import 'package:flutter/material.dart';
import '../validation_result.dart';
import '../sanitizers/input_sanitizer.dart';

class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValidationResult Function(String?) validator;
  final TextInputType keyboardType;
  final IconData? icon;
  final Function(String)? onChanged;
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

  void _onChanged(String value) {
    if (!_hasStartedTyping) setState(() => _hasStartedTyping = true);
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _result = widget.validator(value);
      });
      if (widget.onChanged != null) widget.onChanged!(value);
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
