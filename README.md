# Application Multi-Outils Flutter

Application Flutter modulaire comprenant trois fonctionnalités principales :
1. **Éditeur d'autocollants** - Création de formes, flèches et textes annotés
2. **Découpage de photos** - Extraction d'objets avec fond transparent
3. **Outil de prise de cotes** - Redressement d'image et cotation précise

---

## 📁 Structure du projet

```
gq_app3/
│
├─ lib/
│  ├─ main.dart                    # Point d'entrée, navigation
│  │
│  ├─ pages/                       # Pages principales
│  │  ├─ sticker_editor_page.dart   # Section 1: Éditeur autocollants
│  │  ├─ photo_cropper_page.dart    # Section 2: Découpage photo
│  │  └─ measurement_page.dart      # Section 3: Prise de cotes
│  │
│  ├─ models/                      # Modèles de données
│  │  ├─ sticker_element.dart       # ShapeElement, ArrowElement, TextElement
│  │  └─ measurement_element.dart   # LinearDimension, DiameterDimension
│  │
│  ├─ services/                    # Services métier
│  │  ├─ image_exporter.dart        # Export PNG
│  │  ├─ perspective_transformer.dart # Redressement photo
│  │  └─ library_manager.dart       # Gestion bibliothèque (Hive)
│  │
│  ├─ widgets/                     # Widgets réutilisables
│  │  ├─ sticker_canvas.dart        # Canvas interactif section 1
│  │  ├─ photo_cropper_canvas.dart  # Canvas interactif section 2
│  │  └─ measurement_canvas.dart    # Canvas interactif section 3
│  │
│  └─ utils/                       # Utilitaires
│     └─ geometry_utils.dart        # Calculs géométriques
│
├─ assets/
│  └─ images/                      # Stockage images
│
├─ pubspec.yaml                    # Dépendances
└─ README.md
```

---

## 🚀 Fonctionnalités

### 1️⃣ Éditeur d'autocollants
- ✅ Formes : rectangle, carré, cercle, ovale, traits
- ✅ Flèches simples et doubles
- ✅ Ajout de texte
- ✅ Sélection couleur et épaisseur
- ⏳ Déplacement et redimensionnement
- ⏳ Sauvegarde en bibliothèque
- ⏳ Export PNG

### 2️⃣ Découpage de photos
- ✅ Import depuis galerie/caméra
- ✅ Sélection polygonale de l'objet
- ⏳ Création PNG avec fond transparent
- ⏳ Sauvegarde des découpages

### 3️⃣ Prise de cotes
- ✅ Import photo
- ✅ Sélection 4 points pour redressement
- ⏳ Transformation perspective
- ✅ Cotation linéaire
- ✅ Cotation diamètre
- ⏳ Cotation d'axe
- ⏳ Calcul ratio d'échelle
- ⏳ Export image annotée

---

## 📦 Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^0.8.7+4      # Caméra/galerie
  image: ^4.1.1                # Traitement PNG
  vector_math: ^2.1.0          # Calculs géométriques
  matrix_gesture_detector: ^0.4.0 # Transformations
  path_provider: ^2.0.14       # Stockage local
  hive: ^2.2.3                 # Base de données locale
  hive_flutter: ^1.2.0
  flutter_svg: ^2.0.7          # Support SVG
```

---

## 🛠️ Installation

1. Cloner le projet
```bash
cd gq_app3
```

2. Installer les dépendances
```bash
flutter pub get
```

3. Lancer l'application
```bash
flutter run
```

---

## 📝 État du développement

### ✅ Fait
- Structure du projet conforme à l'architecture
- Modèles de données (StickerElement, DimensionElement)
- Pages principales avec navigation
- Services (ImageExporter, PerspectiveTransformer, LibraryManager)
- Widgets canvas interactifs de base
- Utilitaires géométriques

### ⏳ À faire
- Implémentation complète des interactions canvas
- Détection de collision pour sélection d'éléments
- Transformation de perspective réelle
- Export PNG avec masque polygonal
- Interface utilisateur complète
- Sélecteur de couleurs et épaisseurs
- Gestion de la bibliothèque d'éléments
- Calcul automatique du ratio d'échelle
- Tests unitaires

---

## 🎯 Prochaines étapes

1. **Finaliser les interactions canvas**
   - Sélection, déplacement, redimensionnement des éléments
   - Ajout d'UI pour les outils (boutons, menus)

2. **Implémenter l'export PNG**
   - RepaintBoundary pour capture
   - Découpage avec masque polygonal
   - Sauvegarde dans assets/images/

3. **Ajouter la transformation de perspective**
   - Calcul matrice homographique
   - Application au canvas

4. **Interface utilisateur**
   - Palettes de couleurs
   - Sélecteur d'épaisseur
   - Boîtes de dialogue pour valeurs de cotes
   - Bibliothèque d'éléments sauvegardés

---

## 📄 Licence

Projet privé - Usage interne uniquement
