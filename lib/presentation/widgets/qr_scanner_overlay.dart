import 'package:flutter/material.dart';

class QRScannerOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const QRScannerOverlay({
    super.key,
    this.borderColor = Colors.white,
    this.borderWidth = 4.0,
    this.borderLength = 30.0,
    this.borderRadius = 0.0,
    this.cutOutSize = 250.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: QRScannerOverlayPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        borderLength: borderLength,
        borderRadius: borderRadius,
        cutOutSize: cutOutSize,
      ),
    );
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  QRScannerOverlayPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.borderLength,
    required this.borderRadius,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw the surrounding dark area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw the corner borders
    _drawCornerBorder(canvas, cutOutRect, borderPaint);
  }

  void _drawCornerBorder(Canvas canvas, Rect cutOutRect, Paint borderPaint) {
    final radius = borderRadius > 0 ? borderRadius : 0.0;
    final rrect = RRect.fromRectAndRadius(cutOutRect, Radius.circular(radius));

    // Top-left corner
    _drawSingleCorner(
      canvas,
      rrect,
      borderPaint,
      Alignment.topLeft,
    );

    // Top-right corner
    _drawSingleCorner(
      canvas,
      rrect,
      borderPaint,
      Alignment.topRight,
    );

    // Bottom-left corner
    _drawSingleCorner(
      canvas,
      rrect,
      borderPaint,
      Alignment.bottomLeft,
    );

    // Bottom-right corner
    _drawSingleCorner(
      canvas,
      rrect,
      borderPaint,
      Alignment.bottomRight,
    );
  }

  void _drawSingleCorner(
    Canvas canvas,
    RRect rrect,
    Paint paint,
    Alignment alignment,
  ) {
    final rect = rrect.outerRect;
    final borderOffset = borderWidth / 2;

    switch (alignment) {
      case Alignment.topLeft:
        final start = Offset(rect.left + borderOffset, rect.top + borderLength);
        final end = Offset(rect.left + borderOffset, rect.top + borderOffset);
        final cornerEnd = Offset(rect.left + borderLength, rect.top + borderOffset);
        
        canvas.drawLine(start, end, paint);
        canvas.drawLine(end, cornerEnd, paint);
        break;

      case Alignment.topRight:
        final start = Offset(rect.right - borderOffset, rect.top + borderLength);
        final end = Offset(rect.right - borderOffset, rect.top + borderOffset);
        final cornerEnd = Offset(rect.right - borderLength, rect.top + borderOffset);
        
        canvas.drawLine(start, end, paint);
        canvas.drawLine(end, cornerEnd, paint);
        break;

      case Alignment.bottomLeft:
        final start = Offset(rect.left + borderOffset, rect.bottom - borderLength);
        final end = Offset(rect.left + borderOffset, rect.bottom - borderOffset);
        final cornerEnd = Offset(rect.left + borderLength, rect.bottom - borderOffset);
        
        canvas.drawLine(start, end, paint);
        canvas.drawLine(end, cornerEnd, paint);
        break;

      case Alignment.bottomRight:
        final start = Offset(rect.right - borderOffset, rect.bottom - borderLength);
        final end = Offset(rect.right - borderOffset, rect.bottom - borderOffset);
        final cornerEnd = Offset(rect.right - borderLength, rect.bottom - borderOffset);
        
        canvas.drawLine(start, end, paint);
        canvas.drawLine(end, cornerEnd, paint);
        break;

      default:
        break;
    }
  }

  @override
  bool shouldRepaint(QRScannerOverlayPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        borderLength != oldDelegate.borderLength ||
        borderRadius != oldDelegate.borderRadius ||
        cutOutSize != oldDelegate.cutOutSize;
  }
}