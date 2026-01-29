import 'package:flutter/material.dart';

abstract class DimensionElement {
  void draw(Canvas canvas);
}

class LinearDimensionElement extends DimensionElement {
  Offset p1;
  Offset p2;
  String value;

  LinearDimensionElement({required this.p1, required this.p2, required this.value});

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, paint);
    // TODO: ajouter double flèche et texte
  }
}

class DiameterDimensionElement extends DimensionElement {
  Offset center;
  double radiusX;
  double radiusY;
  String value;

  DiameterDimensionElement({required this.center, required this.radiusX, required this.radiusY, required this.value});

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawOval(Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2), paint);
    // TODO: ajouter double flèche interne et texte
  }
}
