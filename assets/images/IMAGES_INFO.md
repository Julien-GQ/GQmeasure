# 🎨 Images pour l'Animation d'Introduction

## Images Requises

Placez les 5 images suivantes dans ce dossier :

1. **fond_0.png** - Image de fond fixe (arrière-plan)
2. **fond_1.png** - Image qui arrive du HAUT vers le BAS
3. **fond_2.png** - Image qui arrive du BAS vers le HAUT
4. **fond_3.png** - Image qui arrive de GAUCHE vers DROITE
5. **fond_4.png** - Image qui arrive de DROITE vers GAUCHE

## Séquence d'Animation

```
0.0s  ━━━━━ Affichage de fond_0.png (fixe)
0.5s  ━━━━━ Début animation fond_1 (↓) et fond_2 (↑) - durée 1s
1.5s  ━━━━━ Pause de 0.5s
2.0s  ━━━━━ Début animation fond_3 (→) et fond_4 (←) - durée 1s
3.0s  ━━━━━ Pause de 1s
4.0s  ━━━━━ Navigation vers HomePage
```

## Recommandations

- **Format** : PNG avec transparence si besoin
- **Taille** : Adapter à la résolution de l'écran cible
- **Poids** : Optimiser pour un chargement rapide

## Test Sans Images

Si les images ne sont pas présentes, l'application affichera des rectangles colorés avec le nom du fichier manquant pour faciliter le développement.

---

**Note :** Les images seront chargées avec `Image.asset('assets/images/fond_X.png')`
