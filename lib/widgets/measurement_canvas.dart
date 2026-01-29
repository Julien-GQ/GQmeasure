import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/measurement_element.dart';

/// Mode d'interaction pour le canvas de mesure
enum MeasurementMode {
  perspective, // Mode de sélection des 4 points pour redressement
  linear, // Mode cotation linéaire
  diameter, // Mode cotation diamètre
  axis, // Mode cotation d'axe
  none, // Pas d'interaction
}

/// Widget Canvas pour la prise de cotes et redressement d'image
class MeasurementCanvas extends StatefulWidget {
  final ui.Image? image;
  final List<Offset> perspectivePoints; // Les 4 points pour le redressement
  final List<DimensionElement> dimensions;
  final MeasurementMode mode;
  final Function(Offset)? onPerspectivePointAdded;
  final Function(DimensionElement)? onDimensionAdded;
  final Function(int, Offset)? onPointMoved;

  const MeasurementCanvas({
    Key? key,
    this.image,
    required this.perspectivePoints,
    required this.dimensions,
    this.mode = MeasurementMode.none,
    this.onPerspectivePointAdded,
    this.onDimensionAdded,
    this.onPointMoved,
  }) : super(key: key);

  @override
  State<MeasurementCanvas> createState() => _MeasurementCanvasState();
}

class _MeasurementCanvasState extends State<MeasurementCanvas> {
  List<Offset> _tempPoints = []; // Points temporaires pour créer une dimension
  int? _selectedPointIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: CustomPaint(
        painter: _MeasurementCanvasPainter(
          image: widget.image,
          perspectivePoints: widget.perspectivePoints,
          dimensions: widget.dimensions,
          tempPoints: _tempPoints,
          mode: widget.mode,
          selectedPointIndex: _selectedPointIndex,
        ),
        child: Container(),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final tapPosition = details.localPosition;

    switch (widget.mode) {
      case MeasurementMode.perspective:
        if (widget.perspectivePoints.length < 4) {
          widget.onPerspectivePointAdded?.call(tapPosition);
          setState(() {});
        }
        break;

      case MeasurementMode.linear:
        _tempPoints.add(tapPosition);
        if (_tempPoints.length == 2) {
          // Créer la dimension linéaire
          final dimension = LinearDimensionElement(
            p1: _tempPoints[0],
            p2: _tempPoints[1],
            value: '0.0', // Valeur à définir par l'utilisateur
          );
          widget.onDimensionAdded?.call(dimension);
          _tempPoints.clear();
        }
        setState(() {});
        break;

      case MeasurementMode.diameter:
        _tempPoints.add(tapPosition);
        if (_tempPoints.length == 4) {
          // Créer la dimension diamètre
          // TODO: Calculer l'ellipse à partir des points
          final dimension = DiameterDimensionElement(
            center: tapPosition,
            radiusX: 50,
            radiusY: 50,
            value: '0.0',
          );
          widget.onDimensionAdded?.call(dimension);
          _tempPoints.clear();
        }
        setState(() {});
        break;

      case MeasurementMode.axis:
        _tempPoints.add(tapPosition);
        if (_tempPoints.length == 2) {
          // Créer la dimension d'axe
          // TODO: Implémenter AxisDimensionElement
          _tempPoints.clear();
        }
        setState(() {});
        break;

      case MeasurementMode.none:
        break;
    }
  }

  void _handlePanStart(DragStartDetails details) {
    // Chercher un point à déplacer
    final panPosition = details.localPosition;

    // Vérifier les points de perspective
    for (int i = 0; i < widget.perspectivePoints.length; i++) {
      if ((widget.perspectivePoints[i] - panPosition).distance < 20) {
        setState(() => _selectedPointIndex = i);
        return;
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_selectedPointIndex == null) return;

    widget.onPointMoved?.call(_selectedPointIndex!, details.localPosition);
    setState(() {});
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() => _selectedPointIndex = null);
  }
}

/// CustomPainter pour dessiner l'image, les points de perspective et les dimensions
class _MeasurementCanvasPainter extends CustomPainter {
  final ui.Image? image;
  final List<Offset> perspectivePoints;
  final List<DimensionElement> dimensions;
  final List<Offset> tempPoints;
  final MeasurementMode mode;
  final int? selectedPointIndex;

  _MeasurementCanvasPainter({
    this.image,
    required this.perspectivePoints,
    required this.dimensions,
    required this.tempPoints,
    required this.mode,
    this.selectedPointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner l'image de fond
    if (image != null) {
      final srcRect = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(image!, srcRect, dstRect, Paint());
    }

    // Dessiner les points de perspective
    if (mode == MeasurementMode.perspective || perspectivePoints.isNotEmpty) {
      _drawPerspectivePoints(canvas);
    }

    // Dessiner les dimensions
    for (final dimension in dimensions) {
      dimension.draw(canvas);
    }

    // Dessiner les points temporaires
    if (tempPoints.isNotEmpty) {
      _drawTempPoints(canvas);
    }
  }

  void _drawPerspectivePoints(Canvas canvas) {
    // Dessiner les lignes entre les points
    if (perspectivePoints.length > 1) {
      final linePaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < perspectivePoints.length - 1; i++) {
        canvas.drawLine(perspectivePoints[i], perspectivePoints[i + 1], linePaint);
      }

      // Fermer le rectangle si on a 4 points
      if (perspectivePoints.length == 4) {
        canvas.drawLine(perspectivePoints[3], perspectivePoints[0], linePaint);
      }
    }

    // Dessiner les points
    for (int i = 0; i < perspectivePoints.length; i++) {
      final isSelected = i == selectedPointIndex;
      final pointPaint = Paint()
        ..color = isSelected ? Colors.blue : Colors.green
        ..style = PaintingStyle.fill;

      canvas.drawCircle(perspectivePoints[i], isSelected ? 18 : 15, pointPaint);

      // Bordure blanche
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(perspectivePoints[i], isSelected ? 18 : 15, borderPaint);
    }
  }

  void _drawTempPoints(Canvas canvas) {
    final tempPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    for (final point in tempPoints) {
      canvas.drawCircle(point, 10, tempPaint);
    }

    // Dessiner des lignes entre les points temporaires
    if (tempPoints.length > 1) {
      final linePaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < tempPoints.length - 1; i++) {
        canvas.drawLine(tempPoints[i], tempPoints[i + 1], linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MeasurementCanvasPainter oldDelegate) {
    return oldDelegate.perspectivePoints != perspectivePoints ||
        oldDelegate.dimensions != dimensions ||
        oldDelegate.tempPoints != tempPoints ||
        oldDelegate.mode != mode ||
        oldDelegate.selectedPointIndex != selectedPointIndex ||
        oldDelegate.image != image;
  }
}
