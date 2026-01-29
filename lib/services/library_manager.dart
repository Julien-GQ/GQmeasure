import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Service pour gérer la bibliothèque d'autocollants et éléments sauvegardés
class LibraryManager {
  static const String _stickerBoxName = 'stickers_library';
  static const String _photosBoxName = 'photos_library';
  static const String _measurementsBoxName = 'measurements_library';

  static Box? _stickerBox;
  static Box? _photosBox;
  static Box? _measurementsBox;

  /// Initialise Hive et ouvre les boxes nécessaires
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    _stickerBox = await Hive.openBox(_stickerBoxName);
    _photosBox = await Hive.openBox(_photosBoxName);
    _measurementsBox = await Hive.openBox(_measurementsBoxName);

    print('LibraryManager initialisé');
  }

  // ========== Gestion des autocollants ==========

  /// Sauvegarde un élément autocollant dans la bibliothèque
  static Future<void> saveStickerElement(String name, Map<String, dynamic> elementData) async {
    if (_stickerBox == null) {
      print('Erreur: Hive non initialisé');
      return;
    }

    await _stickerBox!.put(name, jsonEncode(elementData));
    print('Autocollant sauvegardé: $name');
  }

  /// Récupère un élément autocollant de la bibliothèque
  static Map<String, dynamic>? getStickerElement(String name) {
    if (_stickerBox == null) return null;

    final data = _stickerBox!.get(name);
    if (data == null) return null;

    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  /// Récupère tous les autocollants de la bibliothèque
  static List<String> getAllStickerNames() {
    if (_stickerBox == null) return [];
    return _stickerBox!.keys.cast<String>().toList();
  }

  /// Supprime un autocollant de la bibliothèque
  static Future<void> deleteStickerElement(String name) async {
    if (_stickerBox == null) return;
    await _stickerBox!.delete(name);
    print('Autocollant supprimé: $name');
  }

  // ========== Gestion des photos découpées ==========

  /// Sauvegarde le chemin d'une photo découpée
  static Future<void> saveCroppedPhoto(String name, String imagePath) async {
    if (_photosBox == null) return;

    await _photosBox!.put(name, imagePath);
    print('Photo découpée sauvegardée: $name');
  }

  /// Récupère le chemin d'une photo découpée
  static String? getCroppedPhoto(String name) {
    if (_photosBox == null) return null;
    return _photosBox!.get(name) as String?;
  }

  /// Récupère toutes les photos découpées
  static Map<String, String> getAllCroppedPhotos() {
    if (_photosBox == null) return {};
    
    final Map<String, String> photos = {};
    for (final key in _photosBox!.keys) {
      photos[key as String] = _photosBox!.get(key) as String;
    }
    return photos;
  }

  /// Supprime une photo découpée
  static Future<void> deleteCroppedPhoto(String name) async {
    if (_photosBox == null) return;
    await _photosBox!.delete(name);
    print('Photo découpée supprimée: $name');
  }

  // ========== Gestion des mesures ==========

  /// Sauvegarde des données de mesure
  static Future<void> saveMeasurement(String name, Map<String, dynamic> measurementData) async {
    if (_measurementsBox == null) return;

    await _measurementsBox!.put(name, jsonEncode(measurementData));
    print('Mesure sauvegardée: $name');
  }

  /// Récupère des données de mesure
  static Map<String, dynamic>? getMeasurement(String name) {
    if (_measurementsBox == null) return null;

    final data = _measurementsBox!.get(name);
    if (data == null) return null;

    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  /// Récupère toutes les mesures
  static List<String> getAllMeasurementNames() {
    if (_measurementsBox == null) return [];
    return _measurementsBox!.keys.cast<String>().toList();
  }

  /// Supprime une mesure
  static Future<void> deleteMeasurement(String name) async {
    if (_measurementsBox == null) return;
    await _measurementsBox!.delete(name);
    print('Mesure supprimée: $name');
  }

  // ========== Utilitaires ==========

  /// Nettoie toutes les données
  static Future<void> clearAll() async {
    await _stickerBox?.clear();
    await _photosBox?.clear();
    await _measurementsBox?.clear();
    print('Toutes les données de bibliothèque effacées');
  }

  /// Ferme toutes les boxes
  static Future<void> dispose() async {
    await _stickerBox?.close();
    await _photosBox?.close();
    await _measurementsBox?.close();
  }
}
