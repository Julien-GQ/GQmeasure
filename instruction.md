# Instructions pour Copilot - Création d'une application Flutter modulaire

# Objectif général :
Créer une application Flutter multi-section avec trois fonctionnalités principales :
1. Éditeur d'autocollants (formes, flèches, texte, épaisseur, couleur)
2. Découpage de photos pour générer des PNG
3. Outil de prise de cotes et redressement d'image type scanner

---

# Section 1 : Éditeur d'autocollants

## Fonctionnalités :
- Ajouter des formes : rectangle, carré, cercle, ovale, traits, flèches simples et doubles
- Ajouter du texte associé aux flèches ou formes
- Sélection de la couleur et de l’épaisseur des lignes
- Déplacer, redimensionner et supprimer les éléments
- Possibilité de sauvegarder des éléments dans une bibliothèque personnelle
- Exporter le résultat final en PNG

## Classes / structure :
- StickerElement (classe abstraite)
    - ShapeElement (rectangle, cercle, etc.)
    - ArrowElement (flèche simple ou double)
    - TextElement
- StickerCanvas (widget qui gère le dessin et les interactions)
- LibraryManager (gestion des éléments sauvegardés)

---

# Section 2 : Découpage de photos

## Fonctionnalités :
- Importer une photo depuis la galerie ou la caméra
- Découper manuellement un objet pour créer un PNG avec fond transparent
- Possibilité d’utiliser un outil de pointage pour définir un polygone autour de l’objet
- Exporter le découpage en PNG pour utilisation dans la section 1

## Classes / structure :
- PhotoCropper (widget interactif pour sélectionner les points)
- PNGExporter (convertir le polygone sélectionné en PNG)
- PhotoLibraryManager (optionnel : sauvegarde des découpages)

---

# Section 3 : Outil de prise de cotes et redressement d’image

## Fonctionnalités :
- Importer une photo
- Proposer à l’utilisateur de sélectionner 4 points pour redresser la photo (perspective flatten / scanner style)
- Calculer la transformation de perspective pour aligner les 4 points
- Option pour accepter ou annuler la mise à jour
- Prendre des mesures sur l’image redressée :
    - Cotation linéaire (2 points + valeur)
    - Cotation diamètre (4 points → ellipse approximative + diamètre)
    - Cotation d’axe (ligne + double flèche + valeur)
- Calculer un ratio d’échelle si plusieurs mesures connues sont données
- Exporter l’image annotée et les cotes

## Classes / structure :
- PhotoMeasureCanvas (widget avec CustomPainter pour dessins interactifs)
- PerspectiveTransformer (calcul de la transformation de la photo à partir des 4 points)
- DimensionElement (classe abstraite)
    - LinearDimensionElement
    - DiameterDimensionElement
    - AxisDimensionElement

---

# Architecture générale

- MainApp : MaterialApp avec BottomNavigationBar ou Drawer pour naviguer entre les 3 sections
- Chaque section est un module Flutter indépendant :
    - StickerEditorPage
    - PhotoCropperPage
    - MeasurementPage
- Stockage local pour :
    - Bibliothèque d’autocollants / formes
    - Découpages PNG
    - Photos et mesures sauvegardées
- Export en PNG pour toutes les sections

---

# Instructions pour Copilot :

1. Créer le projet Flutter standard.
2. Générer les fichiers / classes pour chaque section selon la structure ci-dessus.
3. Créer les widgets interactifs de base avec CustomPainter et GestureDetector pour les sections 1 et 3.
4. Créer des fonctions d’import/export PNG.
5. Ajouter la navigation entre les trois sections via BottomNavigationBar.
6. Commenter chaque section avec TODO pour les fonctionnalités avancées :
    - Flèches double
    - Textes attachés aux éléments
    - Transformation de perspective pour redressement
    - Ratio d’échelle automatique
7. Générer les classes de base pour les éléments (StickerElement, ShapeElement, ArrowElement, DimensionElement etc.) avec leurs propriétés (position, couleur, épaisseur, texte).

---

# Notes supplémentaires :

- Penser à utiliser des packages Flutter existants si besoin : 
    - image_picker pour la photo
    - vector_math pour les calculs géométriques
    - image pour traitement PNG
    - tflite_flutter ou opencv_4 si futur traitement automatique des objets est souhaité
- Chaque section doit pouvoir fonctionner indépendamment
- La navigation entre sections doit être fluide et intuitive
- J'ai déjà plusieurs script dans le dossier utilisé et déplace les au bon endroit selon l'architecture proposé



#architecture proposé :

gq_app3/
│
├─ lib/
│ ├─ main.dart # Entrée principale de l'app, navigation
│ ├─ pages/
│ │ ├─ sticker_editor_page.dart
│ │ ├─ photo_cropper_page.dart
│ │ └─ measurement_page.dart
│ │
│ ├─ models/
│ │ ├─ sticker_elements.dart # ShapeElement, ArrowElement, TextElement
│ │ └─ measurement_elements.dart # LinearDimension, DiameterDimension, AxisDimension
│ │
│ ├─ services/
│ │ ├─ image_exporter.dart # Sauvegarde PNG
│ │ ├─ perspective_transformer.dart # Redressement photo
│ │ └─ library_manager.dart # Gestion de bibliothèque stickers / cotes
│ │
│ ├─ widgets/
│ │ ├─ sticker_canvas.dart # CustomPainter + interactions pour section 1
│ │ ├─ photo_cropper_canvas.dart # CustomPainter + gestures section 2
│ │ └─ measurement_canvas.dart # CustomPainter + gestures section 3
│ │
│ └─ utils/
│ └─ geometry_utils.dart # Calcul distances, angles, transformations, ratio d’échelle
│
├─ assets/
│ └─ images/ # Photos importées, PNG découpés
│
├─ pubspec.yaml
└─ README.md