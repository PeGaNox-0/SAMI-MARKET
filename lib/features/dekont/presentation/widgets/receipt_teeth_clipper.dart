import 'package:flutter/material.dart';

/// Custom clipper that renders serrated / zig-zag teeth along the bottom edge
/// of receipt paper, matching authentic thermal receipts.
class ReceiptTeethClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothDepth;

  const ReceiptTeethClipper({
    this.toothWidth = 10.0,
    this.toothDepth = 5.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - toothDepth);

    final numTeeth = (size.width / toothWidth).floor();
    final actualToothWidth = size.width / numTeeth;

    for (int i = numTeeth - 1; i >= 0; i--) {
      final midX = (i + 0.5) * actualToothWidth;
      final endX = i * actualToothWidth;

      path.lineTo(midX, size.height);
      path.lineTo(endX, size.height - toothDepth);
    }

    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ReceiptTeethClipper oldClipper) {
    return oldClipper.toothWidth != toothWidth || oldClipper.toothDepth != toothDepth;
  }
}
