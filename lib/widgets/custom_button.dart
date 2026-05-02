import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

enum ButtonVariant { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading || onPressed == null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveDisabled ? null : onPressed,
          borderRadius: AppStyles.borderRadiusMedium,
          child: Ink(
            decoration: _getDecoration(effectiveDisabled),
            child: Container(
              padding: _getPadding(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: _getIconSize(),
                      height: _getIconSize(),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(effectiveDisabled)),
                      ),
                    )
                  else ...[
                    if (icon != null) ...[
                      Icon(icon, size: _getIconSize(), color: _getTextColor(effectiveDisabled)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: _getTextColor(effectiveDisabled),
                        fontWeight: FontWeight.bold,
                        fontSize: _getFontSize(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(bool disabled) {
    if (variant == ButtonVariant.outline || variant == ButtonVariant.text) {
      return BoxDecoration(
        borderRadius: AppStyles.borderRadiusMedium,
        border: variant == ButtonVariant.outline
            ? Border.all(color: disabled ? Colors.grey : AppColors.primary, width: 1.5)
            : null,
      );
    }

    if (useGradient && !disabled && variant == ButtonVariant.primary) {
      return BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppStyles.borderRadiusMedium,
        boxShadow: AppColors.primaryShadow,
      );
    }

    return BoxDecoration(
      color: disabled
          ? Colors.grey.shade300
          : (variant == ButtonVariant.primary ? AppColors.primary : AppColors.secondary),
      borderRadius: AppStyles.borderRadiusMedium,
      boxShadow: (variant == ButtonVariant.primary && !disabled) ? AppColors.primaryShadow : null,
    );
  }

  Color _getTextColor(bool disabled) {
    if (disabled) return Colors.grey.shade600;
    if (variant == ButtonVariant.outline || variant == ButtonVariant.text) return AppColors.primary;
    return Colors.white;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
      default:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small: return 12;
      case ButtonSize.large: return 18;
      default: return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small: return 16;
      case ButtonSize.large: return 24;
      default: return 20;
    }
  }
}
