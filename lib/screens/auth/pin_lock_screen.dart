import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/security_helper.dart';
import '../../utils/animations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class PinLockScreen extends StatefulWidget {
  final bool isConfirming;
  final String? initialPin;
  final Function(String)? onComplete;

  const PinLockScreen({
    super.key,
    this.isConfirming = false,
    this.initialPin,
    this.onComplete,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String _enteredPin = "";
  late AnimationController _shakeController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    if (!widget.isConfirming) {
      final bool enabled = await SecurityHelper.isBiometricEnabled();
      if (enabled) {
        final bool authenticated = await SecurityHelper.authenticate();
        if (authenticated && widget.onComplete != null) {
          widget.onComplete!("BIOMETRIC_SUCCESS");
        }
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    if (_enteredPin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() => _enteredPin += key);
      if (_enteredPin.length == 4) _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  Future<void> _verifyPin() async {
    if (widget.isConfirming) {
      if (_enteredPin == widget.initialPin) {
        await SecurityHelper.savePin(_enteredPin);
        if (widget.onComplete != null) widget.onComplete!(_enteredPin);
      } else {
        _triggerError();
      }
    } else {
      final savedPin = await SecurityHelper.getPin();
      if (_enteredPin == savedPin) {
        if (widget.onComplete != null) widget.onComplete!(_enteredPin);
      } else {
        _triggerError();
      }
    }
  }

  void _triggerError() {
    HapticFeedback.vibrate();
    setState(() => _isError = true);
    _shakeController.forward().then((_) {
      _shakeController.reset();
      setState(() { _enteredPin = ""; _isError = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ Fix: SingleChildScrollView prevents overflow on small screens
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildPinDots(),
                  const Spacer(),
                  _buildNumPad(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final title = widget.isConfirming ? "Confirm PIN" : (widget.initialPin == null ? "Create PIN" : "Enter PIN");
    return Column(
      children: [
        const Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.primary),
        const SizedBox(height: 24),
        Text(title, style: AppStyles.heading2),
        const SizedBox(height: 8),
        const Text("Please enter your 4-digit security code", style: AppStyles.body2),
      ],
    );
  }

  Widget _buildPinDots() {
    return AppAnimations.shakeOnError(
      controller: _shakeController,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isFilled = index < _enteredPin.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 16, width: 16,
            decoration: BoxDecoration(
              color: _isError ? AppColors.error : (isFilled ? AppColors.primary : Colors.grey.shade300),
              shape: BoxShape.circle,
              boxShadow: isFilled ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)] : [],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...["1","2","3","4","5","6","7","8","9"].map(_buildNumButton),
          _buildBiometricButton(),
          _buildNumButton("0"),
          _buildBackspaceButton(),
        ],
      ),
    );
  }

  Widget _buildNumButton(String key) {
    return AppAnimations.scaleOnPress(
      onTap: () => _onKeyPress(key),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppStyles.cardShadow),
        child: Center(child: Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return AppAnimations.scaleOnPress(
      onTap: _onBackspace,
      child: const Center(child: Icon(Icons.backspace_outlined, size: 28)),
    );
  }

  Widget _buildBiometricButton() {
    return FutureBuilder<bool>(
      future: SecurityHelper.canCheckBiometrics(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return AppAnimations.scaleOnPress(
            onTap: _checkBiometrics,
            child: const Center(child: Icon(Icons.fingerprint, size: 32, color: AppColors.primary)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
