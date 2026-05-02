import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // --- Page Transitions ---
  
  static Route slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static Route fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Route scaleRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }

  // --- List Animations ---

  static Widget staggeredListEntry({
    required int index,
    required Widget child,
    Duration duration = const Duration(milliseconds: 375),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Interval(
        (0.1 * index).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOut,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // --- Number Animations ---

  static Widget countUpText({
    required double value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 1500),
    String prefix = '',
    String suffix = '',
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.fastOutSlowIn,
      builder: (context, value, child) {
        return Text(
          '$prefix${value.toStringAsFixed(2)}$suffix',
          style: style,
        );
      },
    );
  }

  // --- Micro-interactions ---

  static Widget scaleOnPress({required Widget child, VoidCallback? onTap}) {
    return _ScaleOnPressWrapper(onTap: onTap, child: child);
  }

  static Widget shakeOnError({
    required Widget child,
    required AnimationController controller,
  }) {
    return _ShakeWidget(controller: controller, child: child);
  }

  // --- Placeholder Widgets (Replacement for missing Lottie files) ---

  static Widget lottieSuccess({double size = 100}) {
    return Icon(Icons.check_circle_outline, size: size, color: Colors.green);
  }

  static Widget lottieEmpty({double size = 200}) {
    return Icon(Icons.hourglass_empty_rounded, size: size, color: Colors.grey);
  }

  static Widget lottieLoading({double size = 150}) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _ScaleOnPressWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _ScaleOnPressWrapper({required this.child, this.onTap});

  @override
  State<_ScaleOnPressWrapper> createState() => _ScaleOnPressWrapperState();
}

class _ScaleOnPressWrapperState extends State<_ScaleOnPressWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnimation = _controller.drive(Tween(begin: 1.0, end: 0.95));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _ShakeWidget extends StatelessWidget {
  final Widget child;
  final AnimationController controller;

  const _ShakeWidget({required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.only(
            left: offsetAnimation.value + 24.0,
            right: 24.0 - offsetAnimation.value,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
