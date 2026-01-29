import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

/// Service pour transformer une image en perspective (redressement type scanner)
class PerspectiveTransformer {
  /// Calcule la matrice de transformation de perspective
  /// à partir de 4 points source vers 4 points destination
  /// 
  /// [sourcePoints] : Les 4 coins de la zone à redresser dans l'image originale
  /// [destinationPoints] : Les 4 coins du rectangle de destination
  /// 
  /// Retourne une Matrix4 pour la transformation
  static vm.Matrix4 calculatePerspectiveTransform(
    List<Offset> sourcePoints,
    List<Offset> destinationPoints,
  ) {
    if (sourcePoints.length != 4 || destinationPoints.length != 4) {
      throw ArgumentError('Il faut exactement 4 points source et 4 points destination');
    }

    // TODO: Implémenter le calcul de la matrice de perspective
    // Utiliser l'algorithme de transformation perspective homographique
    // ou utiliser un package comme opencv_4 si disponible
    
    // Pour l'instant, retourner une matrice identité
    return vm.Matrix4.identity();
  }

  /// Redresse une image en utilisant 4 points de référence
  /// 
  /// [image] : Image source à redresser
  /// [corners] : Les 4 coins à redresser (ordre: top-left, top-right, bottom-right, bottom-left)
  /// 
  /// Retourne une nouvelle image redressée
  static Future<ui.Image?> straightenImage(
    ui.Image image,
    List<Offset> corners,
  ) async {
    if (corners.length != 4) {
      print('Erreur: Il faut exactement 4 points pour le redressement');
      return null;
    }

    try {
      // TODO: Implémenter le redressement d'image
      // 1. Calculer les dimensions du rectangle de destination
      // 2. Créer une nouvelle image avec ces dimensions
      // 3. Appliquer la transformation de perspective
      // 4. Retourner l'image transformée

      // Pour l'instant, retourner l'image originale
      print('Redressement d\'image - TODO');
      return image;
    } catch (e) {
      print('Erreur lors du redressement: $e');
      return null;
    }
  }

  /// Calcule la largeur et hauteur optimales pour le rectangle redressé
  /// basé sur les distances entre les points
  static Size calculateOptimalSize(List<Offset> corners) {
    if (corners.length != 4) {
      return const Size(100, 100);
    }

    // Calcul des distances
    final topWidth = (corners[0] - corners[1]).distance;
    final bottomWidth = (corners[3] - corners[2]).distance;
    final leftHeight = (corners[0] - corners[3]).distance;
    final rightHeight = (corners[1] - corners[2]).distance;

    // Prendre les moyennes
    final width = (topWidth + bottomWidth) / 2;
    final height = (leftHeight + rightHeight) / 2;

    return Size(width, height);
  }

  /// Vérifie si 4 points forment un quadrilatère valide
  static bool isValidQuadrilateral(List<Offset> points) {
    if (points.length != 4) return false;

    // Vérifier que les points ne sont pas colinéaires
    // TODO: Ajouter une vérification plus robuste
    
    return true;
  }

  /// Ordonne les points dans le sens: top-left, top-right, bottom-right, bottom-left
  static List<Offset> orderPoints(List<Offset> points) {
    if (points.length != 4) return points;

    // Trier par somme x+y pour trouver top-left et bottom-right
    final sorted = List<Offset>.from(points);
    sorted.sort((a, b) => (a.dx + a.dy).compareTo(b.dx + b.dy));

    final topLeft = sorted[0]; // Plus petite somme
    final bottomRight = sorted[3]; // Plus grande somme

    // Parmi les 2 points restants, celui avec x le plus petit est top-right
    final remaining = [sorted[1], sorted[2]];
    remaining.sort((a, b) => a.dx.compareTo(b.dx));

    final topRight = remaining[1];
    final bottomLeft = remaining[0];

    return [topLeft, topRight, bottomRight, bottomLeft];
  }
}
