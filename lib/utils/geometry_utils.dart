import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utilitaires pour les calculs géométriques
class GeometryUtils {
  /// Calcule la distance entre deux points
  static double distance(Offset p1, Offset p2) {
    return (p2 - p1).distance;
  }

  /// Calcule l'angle en radians entre deux points
  /// L'angle est mesuré depuis l'horizontale (axe X)
  static double angleBetweenPoints(Offset p1, Offset p2) {
    return math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
  }

  /// Convertit des radians en degrés
  static double radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  /// Convertit des degrés en radians
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Calcule le point milieu entre deux points
  static Offset midpoint(Offset p1, Offset p2) {
    return Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
  }

  /// Calcule le périmètre d'un polygone
  static double polygonPerimeter(List<Offset> points) {
    if (points.length < 2) return 0.0;

    double perimeter = 0.0;
    for (int i = 0; i < points.length; i++) {
      final next = (i + 1) % points.length;
      perimeter += distance(points[i], points[next]);
    }
    return perimeter;
  }

  /// Calcule l'aire d'un polygone (formule de Shoelace)
  static double polygonArea(List<Offset> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final next = (i + 1) % points.length;
      area += points[i].dx * points[next].dy;
      area -= points[next].dx * points[i].dy;
    }
    return area.abs() / 2.0;
  }

  /// Vérifie si un point est à l'intérieur d'un polygone
  /// Utilise l'algorithme du Ray Casting
  static bool isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy)) &&
          (point.dx <
              (polygon[j].dx - polygon[i].dx) * (point.dy - polygon[i].dy) /
                      (polygon[j].dy - polygon[i].dy) +
                  polygon[i].dx)) {
        inside = !inside;
      }
    }
    return inside;
  }

  /// Calcule le ratio d'échelle entre une distance mesurée et sa valeur réelle
  /// 
  /// [measuredDistance] : Distance en pixels sur l'image
  /// [realValue] : Valeur réelle avec unité (en mm, cm, m, etc.)
  /// 
  /// Retourne le ratio pixels/unité
  static double calculateScale(double measuredDistance, double realValue) {
    if (realValue == 0) return 1.0;
    return measuredDistance / realValue;
  }

  /// Convertit une distance en pixels vers une valeur réelle
  /// en utilisant un ratio d'échelle
  static double pixelsToReal(double pixels, double scale) {
    if (scale == 0) return pixels;
    return pixels / scale;
  }

  /// Calcule le centre d'un ensemble de points
  static Offset centroid(List<Offset> points) {
    if (points.isEmpty) return Offset.zero;

    double sumX = 0;
    double sumY = 0;
    for (final point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }

    return Offset(sumX / points.length, sumY / points.length);
  }

  /// Calcule les paramètres d'une ellipse à partir de 4 points
  /// Retourne (center, radiusX, radiusY)
  static (Offset, double, double) ellipseFromPoints(List<Offset> points) {
    if (points.length < 4) {
      return (Offset.zero, 50.0, 50.0);
    }

    // Calculer le centre comme centroïde
    final center = centroid(points);

    // Calculer les rayons moyens
    double sumDistances = 0;
    for (final point in points) {
      sumDistances += distance(center, point);
    }
    final avgRadius = sumDistances / points.length;

    // TODO: Améliorer le calcul pour obtenir radiusX et radiusY distincts
    return (center, avgRadius, avgRadius * 0.7);
  }

  /// Calcule la perpendiculaire à une ligne passant par un point
  /// Retourne l'angle perpendiculaire en radians
  static double perpendicularAngle(double lineAngle) {
    return lineAngle + math.pi / 2;
  }

  /// Vérifie si un point est proche d'une ligne (avec tolérance)
  static bool isPointNearLine(Offset point, Offset lineStart, Offset lineEnd, double tolerance) {
    final d = distancePointToLine(point, lineStart, lineEnd);
    return d <= tolerance;
  }

  /// Calcule la distance d'un point à une ligne
  static double distancePointToLine(Offset point, Offset lineStart, Offset lineEnd) {
    final lineLength = distance(lineStart, lineEnd);
    if (lineLength == 0) return distance(point, lineStart);

    final num = ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
            (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy))
        .abs();
    final denom = lineLength * lineLength;

    final t = (num / denom).clamp(0.0, 1.0);
    final projection = Offset(
      lineStart.dx + t * (lineEnd.dx - lineStart.dx),
      lineStart.dy + t * (lineEnd.dy - lineStart.dy),
    );

    return distance(point, projection);
  }

  /// Formate une valeur de distance avec l'unité appropriée
  static String formatDistance(double value, String unit) {
    if (value < 1 && unit == 'm') {
      return '${(value * 100).toStringAsFixed(1)} cm';
    }
    if (value < 0.01 && unit == 'm') {
      return '${(value * 1000).toStringAsFixed(1)} mm';
    }
    return '${value.toStringAsFixed(2)} $unit';
  }
}
