
# Changelog

All notable changes to this project will be documented in this file.
Tous les changements

## 0.1.3 − 2019-01-23
### Corrections
  - Erreur de compilation sous Linux.

## 0.1.2 − 2019-01-23

### Ajouts
  - *Parcellaire* − Ajout d'un bouton-menu et de raccourcis clavier pour
    déplier/replier les emplacements par niveau.
  - Ajout de raccourcis clavier pour les actions les plus courantes (voir le
    guide utilisateur sur le wiki pour plus de détails).
  - *Paramètres* − Ajout d'une notification de redémarrage de l'application.
  - *Édition des séries* − Ajout d'une case à cocher pour les champs de durée
    permettant d'activer ou de désactiver le calcul des dates à partir des
    durées. Ajout d'une option dans les paramètres pour activer ou désactiver le
    calcul des dates par défaut et pour cacher les champs de durée.
  - *Plan de culture* − Afficher une icône pour les cultures sous abri.
  - *Parcellaire* − En survolant un court instant un emplacement avec une série,
    l'emplacement se déplie s'il possède des sous-emplacements.
  - *Base de données* − Ajout d'un framework de migration. On commence à migrer
    proprement les schémas de base de données. Pour chaque nouvelle version du
    schéma, on fixe une version dans la base données et on écrira une script SQL
    à part pour chaque nouvelle version. Chaque script sera appliqué
    successivement pour atteindre la dernière version.

### Changements
  - *Parcellaire* − Le bouton pour afficher/cacher le panneau des séries est désormais attaché au panneau lui-même.
  - Mise à jour de la traduction française.

### Corrections
  - *Vue des séries* − Initialiser correctement la case à cocher « sous abri ».
  - *Vue des séries* − Ajout d'une semaine au diagramme de récolte (il en manquait une).
  - *Édition des séries* − Bogue de mise à jour des dates qui empêchait la mise à jour des durées.
  - Boîte déroulante : correction du bogue de la barre de défilement du popup.
  - Nettoyer correctement la base de données avant de la réinitialiser.

## 0.1.1 - 2019-01-10

### Fixed
  - AppImage building.

## 0.1 - 2019-01-09

First public release.
