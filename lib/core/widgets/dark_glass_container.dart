import 'dart:ui';
import 'package:flutter/material.dart';

class DarkGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final bool hasBlur;

  const DarkGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20.0,
    this.blurSigma = 16.0,
    this.backgroundColor = const Color(0xFF16161A),
    this.borderColor = const Color(
      0x26FFFFFF,
    ), // Colors.white.withValues(alpha: 0.15)
    this.onTap,
    this.hasBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final containerDecoration = BoxDecoration(
      color: backgroundColor.withValues(alpha: hasBlur ? 0.55 : 0.70),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(width: 1.2, color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: hasBlur ? 0.35 : 0.20),
          blurRadius: hasBlur ? 24 : 12,
          offset: const Offset(0, 6),
        ),
      ],
    );

    Widget body = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: containerDecoration,
      child: child,
    );

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: body,
        ),
      );
    }

    if (hasBlur && blurSigma > 0) {
      body = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: body,
        ),
      );
    }

    return Padding(
      padding: margin,
      child: body,
    );
  }
}
