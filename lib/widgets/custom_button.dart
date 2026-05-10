import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Available visual variants for the [CustomButton].
enum ButtonVariant { 
  /// Solid background with the primary color.
  primary, 
  /// Solid background with the secondary color.
  secondary, 
  /// Outlined border with no background.
  outline, 
  /// Simple text button without background or border.
  text 
}

/// Available sizes for the [CustomButton].
enum ButtonSize { 
  /// Smallest padding and font size.
  small, 
  /// Default padding and font size.
  medium, 
  /// Largest padding and font size for prominent actions.
  large 
}

/// A highly customizable button widget used throughout the application.
/// 
/// This widget supports multiple visual variants, sizes, and states (loading, disabled).
/// It also handles gradients and icons, providing a consistent interaction
/// model with built-in ink splashes and animations.
class CustomButton extends StatelessWidget {
  /// The text to display on the button.
  final String label;
  
  /// Callback function triggered when the button is tapped.
  final VoidCallback? onPressed;
  
  /// The visual style variant of the button.
  final ButtonVariant variant;
  
  /// The size dimensions of the button.
  final ButtonSize size;
  
  /// Whether to show a loading indicator instead of the label/icon.
  final bool isLoading;
  
  /// Whether the button is interactable.
  final bool isDisabled;
  
  /// Optional icon to display before the label.
  final IconData? icon;
  
  /// Whether to apply the brand gradient (applies to [ButtonVariant.primary] only).
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

  /// Calculates the decoration for the button based on its state and variant.
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

  /// Determines the text and icon color based on the current state.
  Color _getTextColor(bool disabled) {
    if (disabled) return Colors.grey.shade600;
    if (variant == ButtonVariant.outline || variant == ButtonVariant.text) return AppColors.primary;
    return Colors.white;
  }

  /// Returns the appropriate padding for the selected button size.
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

  /// Returns the appropriate font size for the selected button size.
  double _getFontSize() {
    switch (size) {
      case ButtonSize.small: return 12;
      case ButtonSize.large: return 18;
      default: return 16;
    }
  }

  /// Returns the appropriate icon size for the selected button size.
  double _getIconSize() {
    switch (size) {
      case ButtonSize.small: return 16;
      case ButtonSize.large: return 24;
      default: return 20;
    }
  }
}
