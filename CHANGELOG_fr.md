
# Changelog

Tous les changements importants seront documentés dans ce fichier.

## Non publiés

### Ajouts
  - Ajout de l'export papier pour le calendrier des tâches.
  - Ajout de l'export papier pour le plan de culture.
  - Ajout d'une vue des listes de semences et plants à commander.
  - *Vue des séries* − Sélection d'un intervalle de séries avec la touche Shift
    (souris ou clavier).
  - *Parcellaire* − Ajout d'un bouton afficher la couleur de la famille ou de
    l'espèce.
  - Fonctionnalité basique de prise de notes pour les séries.
  - Onglet récolte.
  - Gestion des planches standardisées : l'utilisateurice peut entre une
    longueur de planche standard et l'utiliser comme unité pour définir la
    longueur des séries.
  - *Parcellaire* − Ajout d'un mode « sous abris » permettant d'afficher
    uniquement les emplacements et séries sous abris. Ajout d'un raccourci
    clavier pour ce mode.
  - *Parcellaire* − Ajout d'un bouton indiquant les séries en conflit de place
    sur un emplacement. Un clic sur ce bouton ouvre un menu permettant de
    choisir une série en conflit pour l'éditer, l'enlever de l'emplacement ou
    bien la diviser s'il reste de la place sur l'emplacement.
  - *Parcellaire* − Ajout d'une fonctionnalité d'affectation à un bloc :
    lorsqu'on dépose une série sur un emplacement qui contient des
    sous-emplacements, affecter la série aux sous-emplacements, en vérifiant la
    place disponible si les conflits de série ne sont pas autorisés.
  - *Parcellaire* − Ajout d'une option pour autoriser les conflits de série sur
    un même emplacement.
  - *Parcellaire* − Option pour afficher le nom complet des emplacements.

### Changements
  - L'année commence maintenant par l'hiver plutôt que par le printemps.
  - *Diagramme des séries* − Pour le format de date « semaine », ne plus
    afficher les indicateurs < et > d'années.

### Corrections
  - *Édition des séries* − Les champs sont désormais toujours visibles lorsque
    l'on se déplace avec la touche tabulation.
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
  - *Parcellaire* − Le bouton pour afficher/cacher le panneau des séries est
    désormais attaché au panneau lui-même.
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
