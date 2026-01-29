# 🚀 Guide de Démarrage Rapide - gq_app3

## Étapes d'Installation et Lancement

### 1️⃣ Vérifier l'installation Flutter
```powershell
flutter doctor
```

### 2️⃣ Se placer dans le répertoire du projet
```powershell
cd c:\dev\gq\gq_app3
```

### 3️⃣ Installer les dépendances
```powershell
flutter pub get
```

### 4️⃣ Vérifier qu'il n'y a pas d'erreurs de compilation
```powershell
flutter analyze
```

### 5️⃣ Lancer l'application
```powershell
# Pour Windows
flutter run -d windows

# Pour Web
flutter run -d chrome

# Pour un émulateur Android/iOS
flutter run
```

---

## 🔧 Modifications Nécessaires Avant le Premier Lancement

### Initialiser LibraryManager dans main.dart

Le fichier [main.dart](main.dart) doit être mis à jour pour initialiser Hive :

```dart
import 'package:flutter/material.dart';
import 'lib/pages/sticker_editor_page.dart';
import 'lib/pages/photo_cropper_page.dart';
import 'lib/pages/measurement_page.dart';
import 'lib/services/library_manager.dart'; // ← AJOUTER

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← AJOUTER
  await LibraryManager.initialize(); // ← AJOUTER
  runApp(MyApp());
}

// ... reste du code
```

---

## 📦 Packages à Installer

Tous les packages sont déjà listés dans [pubspec.yaml](pubspec.yaml) :

- ✅ `image_picker` : Sélection photo depuis galerie/caméra
- ✅ `image` : Traitement et manipulation d'images
- ✅ `vector_math` : Calculs géométriques et matrices
- ⚠️ `matrix_gesture_detector` : Commenté (non disponible sur pub.dev)
- ✅ `path_provider` : Accès au système de fichiers
- ✅ `hive` & `hive_flutter` : Base de données locale
- ✅ `flutter_svg` : Support SVG

**Note:** Pour les transformations de perspective, utilisez directement `Matrix4` de `vector_math`.

---

## 🎯 Première Utilisation

### Navigation entre les sections

L'application démarre avec 3 onglets accessibles via la barre de navigation inférieure :

1. **📌 Autocollants** - Éditeur de formes et annotations
2. **📸 Découpage** - Extraction d'objets avec fond transparent
3. **📏 Cotes** - Prise de mesures et redressement d'image

### Tests Rapides

#### Section Autocollants
1. Appuyer sur le bouton `+` pour ajouter un élément
2. Les éléments apparaissent sur le canvas
3. (À implémenter) Sélection et déplacement

#### Section Découpage
1. Cliquer sur le canvas pour ajouter des points
2. Les points forment un polygone de sélection
3. (À implémenter) Import d'image et export PNG

#### Section Cotes
1. Sélectionner un mode de mesure
2. Ajouter des points pour créer des cotes
3. (À implémenter) Redressement perspective

---

## 🛠️ Développement en Cours

### Fonctionnalités à Compléter

#### Court Terme (1-2 jours)
- [ ] Sélection et déplacement d'éléments dans le canvas
- [ ] UI pour sélection couleur et épaisseur
- [ ] Import image depuis galerie/caméra
- [ ] Export PNG de base

#### Moyen Terme (3-7 jours)
- [ ] Transformation de perspective fonctionnelle
- [ ] Découpage PNG avec masque polygonal
- [ ] Bibliothèque d'éléments sauvegardés
- [ ] Interface de saisie des valeurs de cotes

#### Long Terme (2-4 semaines)
- [ ] Calcul automatique du ratio d'échelle
- [ ] Flèches doubles avec têtes
- [ ] Rotation et redimensionnement avancés
- [ ] Export PDF des mesures
- [ ] Mode sombre
- [ ] Localisation FR/EN

---

## 📚 Documentation des Fichiers

### Fichiers Principaux

| Fichier | Description | Statut |
|---------|-------------|--------|
| [main.dart](main.dart) | Point d'entrée, navigation | ✅ Fonctionnel |
| [pubspec.yaml](pubspec.yaml) | Dépendances du projet | ✅ Complet |
| [instruction.md](instruction.md) | Cahier des charges original | 📖 Référence |
| [README.md](README.md) | Documentation principale | 📖 À jour |
| [ANALYSE_PROJET.md](ANALYSE_PROJET.md) | Rapport d'analyse détaillé | 📊 Complet |

### Dossiers

| Dossier | Contenu | Fichiers |
|---------|---------|----------|
| [lib/pages](lib/pages) | Pages de l'application | 3 |
| [lib/models](lib/models) | Modèles de données | 2 |
| [lib/services](lib/services) | Services métier | 3 |
| [lib/widgets](lib/widgets) | Widgets réutilisables | 3 |
| [lib/utils](lib/utils) | Fonctions utilitaires | 1 |
| [assets/images](assets/images) | Images et exports | - |

---

## 🐛 Résolution de Problèmes

### Erreur : "Target of URI doesn't exist: 'package:flutter/material.dart'"
**Solution:** Exécuter `flutter pub get`

### Erreur : "No Windows desktop project configured"
**Solution:** 
```powershell
# Ajouter le support Windows au projet
flutter create --platforms=windows .
```

### Erreur : "Hive not initialized"
**Solution:** Ajouter l'initialisation de LibraryManager dans main()

### Erreur : "is not a valid Dart package name"
**Solution:** Le nom dans pubspec.yaml doit être en minuscules avec underscores (déjà corrigé: `outils_mesure_app`)

### Erreur : "No device connected"
**Solution:** 
```powershell
# Vérifier les devices disponibles
flutter devices

# Lancer avec un device spécifique
flutter run -d windows
```

### Performance lente sur grande image
**Solution:** Implémenter la compression dans image_exporter.dart

---

## 📞 Support

Pour toute question sur l'architecture ou l'implémentation, consulter :
- [instruction.md](instruction.md) - Spécifications originales
- [ANALYSE_PROJET.md](ANALYSE_PROJET.md) - Analyse détaillée
- [README.md](README.md) - Documentation complète

---

## ✅ Checklist de Vérification

Avant de commencer le développement, vérifier :

- [ ] Flutter SDK installé (`flutter doctor` OK)
- [ ] Dépendances installées (`flutter pub get` exécuté)
- [ ] LibraryManager initialisé dans main.dart
- [ ] Application compile sans erreur (`flutter analyze`)
- [ ] Application démarre (`flutter run`)
- [ ] Navigation entre les 3 sections fonctionne

---

*Dernière mise à jour : 29 janvier 2026*
