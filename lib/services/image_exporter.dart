import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// Service pour exporter des canvas et images en PNG
class ImageExporter {
  /// Exporte un widget en image PNG
  /// [key] : GlobalKey du RepaintBoundary contenant le widget à exporter
  /// [filename] : Nom du fichier de sortie (sans extension)
  /// Retourne le chemin du fichier créé
  static Future<String?> exportWidgetToPNG(
    GlobalKey key,
    String filename,
  ) async {
    try {
      // Récupération du RenderObject
      RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        print('Erreur: RenderRepaintBoundary non trouvé');
        return null;
      }

      // Conversion en image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        print('Erreur: Impossible de convertir en ByteData');
        return null;
      }

      // Sauvegarde du fichier
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename.png';
      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      print('Image exportée: $path');
      return path;
    } catch (e) {
      print('Erreur lors de l\'export PNG: $e');
      return null;
    }
  }

  /// Exporte une image avec un masque polygonal (découpage)
  /// [imagePath] : Chemin de l'image source
  /// [polygonPoints] : Points du polygone de découpage
  /// [filename] : Nom du fichier de sortie
  /// Retourne le chemin du fichier créé avec fond transparent
  static Future<String?> exportWithPolygonMask(
    String imagePath,
    List<Offset> polygonPoints,
    String filename,
  ) async {
    try {
      // TODO: Implémenter le découpage avec masque polygonal
      // 1. Charger l'image source
      final sourceFile = File(imagePath);
      final sourceBytes = await sourceFile.readAsBytes();
      final sourceImage = img.decodeImage(sourceBytes);

      if (sourceImage == null) {
        print('Erreur: Impossible de décoder l\'image source');
        return null;
      }

      // 2. Créer un masque à partir du polygone
      // 3. Appliquer le masque pour rendre transparent le fond
      // 4. Sauvegarder l'image avec transparence

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename.png';
      
      // Temporaire : sauvegarde simple
      final file = File(path);
      await file.writeAsBytes(img.encodePng(sourceImage));

      print('Image découpée exportée: $path');
      return path;
    } catch (e) {
      print('Erreur lors du découpage PNG: $e');
      return null;
    }
  }

  /// Exporte une liste de bytes en fichier PNG
  static Future<String?> exportBytesToPNG(
    List<int> bytes,
    String filename,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename.png';
      final file = File(path);
      await file.writeAsBytes(bytes);

      print('Fichier PNG sauvegardé: $path');
      return path;
    } catch (e) {
      print('Erreur lors de la sauvegarde PNG: $e');
      return null;
    }
  }
}
