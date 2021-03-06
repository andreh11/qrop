# Journal des modifications

Tous les changements importants seront documentés dans ce fichier.

## Non publiés

## Ajouts

## Changements

## Correctifs

## 0.4.6 − 2021-03-05

## Ajouts
 - Ajout de la traduction en espagnol (Joey Albert and BotaFlo).
 - Ajout de la traduction en occitan (BotaFlo).
 - Ajout de la compilation croisée MXE pour Windows (@ah).
 - Ajout d'une fenêtre d'affichage des nouvelles du projet (@mbruel).
 - *Android.* Ajout des APKs et des dialogues nécessaires pour Android (@mbruel).

## Changements
 - *Paramètres.* La liste des langues affiche dorénavant toutes les traductions
   disponibles (@ah). 

## Correctifs
 - *Assolement* Correction d'un bug de raffraîchissement (@ah).
 - *Assolement.* Correction de la mauvaise liste des séries pour la saison en
   cours (certaines séries apparaissaient alors qu'elle ne faisaient pas partie
   de la saison affichée) (@ah).
 - *Tâches*. Correction de la hauteur de la fenêtre des tâches pour les tâches
   créées automatiquement (#311, @julienboulay).
 - *Assolement.* Correction de la longueur de la description dans le diagramme
   des séries (#299, @julienboulay).
 - *Base de données.* Correction d'une erreur à l'ouverture de la base de
   données (#284, @mbruel).
 - Correction du gel de l'application au démarrage (#326, @mbruel). 
 - *Android.* Correction des sorties PDF pour Android (@mbruel).
 - *Parcellaire.* Correction du crash de l'application lors de la création d'un
   emplacement sans renseigner un nom (@Mickael_G).
 - *Séries.* Correction d'une problème de date lors de l'import CSV (#184,
   @Xeros).
 - Correction d'une problème d'affichage avec un thème système sombre
   (@julienboulay).

## 0.4.5 "La Rauze" - 2020-12-07 

### Changements
 - *Sélecteur de date* − Amélioration du sélecteur de date et conformité au
   style Material.
 - *Series* − Toujours afficher le nom du fournisseur si la fonctionnalité a été
   activée (#176).
 - *Graphique* : toutes les données de la vue sont mises à jour lorsque
   l'utilisateurice effectue une recherche sur les séries.
 - *Calendrier* : l'export PDF suit dorénavant la vue en cours : semaine et
   filtre fait/à faire/en retard (#205).
 - Amélioration du filtre des séries : possiblité d'afficher toutes les séries,
   ou seulement celles de plein champs ou sous abri.

### Corrections
 - *Semences* − Correction du texte de l'infobulle du bouton d'export (#244).
 - *Liste de semences* − Correction de la mise à jour des liste par
   mois et par trimestre lors du passage d'une base de données à une
   autre (#241).
 - *Seed list* − Fix month and quart list update when switching between databases (#241).
 - *Widget calendrier* − Correction de l'affichage des jours et numéros de
   semaine.
 - *Graphiques* − Correction de la mise-à-jour de la vue lorsqu'une autre base
   de données est sélectionnée (#214).
 - *Dialogue des tâches* − Correction du bug d'affichage des emplacements : une
   partie de la vue n'était pas toujours visible (#201).
 - *Parcellaire* − Correction du bug d'affichage pour les séries plurianuelles
   (#169).
 - *Parcellaire* − Correction d'un bug de rafraîchissement lors du passage à la
   vue.
 - *Parcellaire* − Correction du bug d'édition (impossiblité d'éditer un ou
   plusieurs emplacements).

## 0.4.4 − 2020-01-28

### Corrections
 - *Parcellaire* − Correction de la mise à jour de la sélection lors de l'ajout
   de sous-emplacements.
 - Utiliser « système » comme paramètre de langue par défaut.
 - *Dialogue des séries* − Afficher le champs densité même si les planches
   ne sont pas standardisées.
 - *Calendrier* − Correction du mauvais nom de mois.
 - *Dialogue des séries* − Correction du mauvais nombre de semences pour
   des séries en semis direct avec plusieurs graines par trou.

## 0.4.3 « Albens » − 2020-01-23
  - *Paramètres* − Correction du comportement de barre de défilement.

## 0.4.2 « Albens » − 2020-01-23

### Ajouts
  - *Paramètres* − Ajout d'un menu déroulant pour sélectionner la langue (#156).

### Changements
  − *PDF* − Affichage du nom des mois à la place de nombres dans les sections (#168).
  - Amélioration de l'infrastructure des traductions.

### Corrections
  - *PDF* − Correction des mauvaises unités pour les poids : kg au lieu de g (#165).
  - *Plan de culture* − Correction du bogue de duplication lors de l'utilisation
    de dates complètes (#175).
  - Correction de la numérotation automatique des emplacements (#164).
  - Correction de la sélection des années dans les champs date (#171).
  - *PDF* − Parcellaire : correction de la hauteur des emplacemens lorsque les
    tâches ne sont pas affichées.

## 0.4.1. - 2019-12-02

### Changements
  - *Paramètres* − Champs entier à la place des boutons fléchés (#149).

### Corrections
  - *Parcellaire* − Correction d'un bogue faisant crasher le programme lors de
    la création d'un nouveau parcellaire.
  - *Paramètres* − L'interrupteur « densité » est maitenant disponible même si
    l'utilisateurice n'a pas de planches standardisées (#144).
  - *Plan de culture* − Correction de l'affichage des images associées aux notes (#154).

## 0.4 « Bobéhec » - 2019-10-11

### Ajouts
  − *Parcellaire* − Afficher la longueur de la série affectée à une planche
  lorsqu'elle ne remplit pas la planche (ou qu'elle est plus longue que la planche).
  - Ajout d'infobulles pour les boutons de la barre de gauche.
  - *Édition des séries* − Ajout d'un champs densité au mètre carré (#126).

### Changements
  - *Parcellaire* − En glissant/déposant une série tout en maintenant la touche
    Ctrl, la série est affectée aux emplacements suivants si nécessaire.
  - *Parcellaire* − Amélioration de la sortie PDF : muliligne, meilleur
    affichage des tâches et séries.
  - *Parcellaire* − Vue sur plusieurs lignes (#76).
  - *Parcellaire* − Lors de l'édition du parcellaire, Ctrl+Clic gauche
    sélectionne l'ensemble des fils d'un emplacement (#113).
  - *Semences et plants* − Ajout d'une sortie PDF pour les listes mensuelle et
    trimestrielle (#131).
  - *Semences et plants* − Ajout d'une vue mensuelle et d'une trimestrielle (#131).
  - *Plan de culture* − Amélioration mineure du graphique.
  - *PDF* − Améliorations mineures des sorties PDF du calendrier des tâches.
  - *Plan de culture* − Amélioration de l'apparence des panneaux latéraux.
  - Amélioration de la performance des vues séries et tâches.

### Corrections
  - *Parcellaire* − Afficher la couleur des tâches.
  - *Édition des séries* − Correction du bogue qui empêchait les conflits de
    séries lorsque ceux-ci étaient activés.
  - *Semences et plants* − Correction de la fonction de tri des dates et noms.
  - Correction de la longueur à assigner lors d'une assignation multiple à un
    emplacement.

## 0.3 - 2019-06-15

### Ajouts
  - *Calendrier* − Ajout de fonctions de tri pour les tâches (#122).
  - *Fournisseur de semences* − Ajout d'un bouton radio pour choisir le fournisseur
    de semence par défaut (#111).
  - *Dialogue des tâches* − Création de plusieurs tâches en même temps (#133).
  - Ajout d'une fonctionnalité de variété par défaut : lorsqu'une espèce est
    choisie dans le formulaire des séries, l'espèce par défaut est automatiquement
    sélectionnée. De plus, lorsqu'une nouvelle espèce est créée, une série
    « Inconnue » est créée automatiquement (#128).
  - Ajout de graphiques de distribution des séries (longueur de planche) et
    de chiffre d'affaire.
  - *Parcellaire* − Ajout de l'affichage des tâches.
  - *Tâches* − Ajout des itinéraires de cultures.
  - *Plan de culture* - Affichage du chiffre d'affaire escompté.
  - Ajout de la numérotation des séries par espèce et date de plantation.

### Changements
  - *Édition des séries* − Vérification de la cohérence des dates lors de l'édition
    d'une seule série (#119).
  - *Série* − Il est dorénavant possible pour une série de ne pas avoir d'unité
    (#106).
  - Sortie papier de l'assolement : plus d'espace pour les nom d'emplacements
    longs (#141).
  - *Dialogue des récoltes* − Affiche les séries en cours de récoltes.
    Lorsqu'une série est sélecitonnée, n'afficher que les séries de la même
    espèce.
  - Afficher les messages d'erreurs pour les champs obligatoires.
  - Amélioration des champs de durée : passage des heures au minutes avec la
    touche tabulation (#99).
  - *Plan de culture* − N'afficher la couleur des séries que lorsqu'elles ont
    été plantées ou semées.

### Corrections
  - Correction du bogue des mois 10-11-12 pour les sélectionneurs de dates
    complètes (#114).
  - *Plan de culture* − Dupliquer les étiquettes lorsque les séries sont
    dupliquées.
  - *Dialogue des récoltes* − Diviser le temps de récoltes entre plusieurs
    séries (#97).
  - *Assolement* − Ne pas afficher de conflit de rotation lorsque deux séries
    se croisent sur le même emplacement (#117).
  - Fenêtre de dialogue simples : résolution du problème de positionnement (#107).
  - *Dialogue des récoltes* − Mise à jour de la quantité lorsqu'une récolte est
    modifiée deux fois de suite (#101).
  - *Dialogue des récoltes* − Afficher la bonne unité pour le ou la série(s)
    sélectionnée(s), en supposant qu'elles ont toutes la même unité (#100).
  - Correction du comportement des champs de durée : il n'est plus possible
    d'entrer des minutes > 60 (#102).

## 0.2 - 2019-05-13

  - Il est maintenant possible de travailler avec deux bases de données en même
    temps en cliquant sur les boutons « 1 » (base de données principale) et « 2
    » du panneau de gauche. L'utilisateur-ice peut créer, ouvrir et exporter des
    bases de données.

## 0.2 - 2019-05-02

### Ajouts
  - *Plan de culture* Import et export du plan de culture en fichier CSV.
  - Ajout d'une fonctionnalité de duplication du plan de culture d'une année à une
    autre.
  - Ajout de l'export PDF pour le plan de culture, le calendrier des tâches,
    le parcellaire, les récoltes et les listes de semences et plants à commander.
  - Ajout d'une vue des listes de semences et plants à commander.
  - *Vue des séries* − Sélection d'un intervalle de séries avec la touche Shift
    (souris ou clavier).
  - *Parcellaire* − Ajout d'un bouton pour afficher la couleur de la famille ou de
    l'espèce.
  - Fonctionnalité basique de prise de notes pour les séries (avec ajout de photos).
  - Onglet récolte.
  - Gestion des planches standardisées : il est dorénavant possible de définir une
    longueur de planche standard et de l'utiliser comme unité pour définir la
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
  - *Édition de séries* − Il est dorénatant possible d'éditer les emplacements
    d'une série dans le dialogue d'édition des séries.
  - Affichage des étiquettes dans la vue des séries et le semainier.
  - Si le type d'une série est modifiée et qu'il passe de « Plant, fait » à
    « Semis direct » ou « Plant, acheté », la tâche de pépinière associée est
    dorénavant supprimée et le durée de pépinière est mise à 0.
  - Nombre décimaux au lieu d'entiers pour les longueurs de planche, graines par
    gramme et surface.
  - *Vue, édition des séries* : si les dates sont entrées par numéro de semaine,
    on considère que la récolte se termine à la *fin* de la semaine de fin de
    récolte indiquée.
  - *Édition des séries* : il est dorénavant possible d'éditer par lot les
    étiquettes de série.
  - L'année commence maintenant par l'hiver plutôt que par le printemps.
  - *Diagramme des séries* − Pour le format de date « semaine », ne plus
    afficher les indicateurs < et > d'années.

### Corrections
  - Correction du bogue de changement de type de série (#94)
  - Correction d'un bogue d'affichage des notes de séries.
  - *Édition des séries* : les quantités sont dorénavant correctement recalculées
    lors de l'édition d'une ou plusieurs séries.
  - *Édition des séries* : lors de l'édition d'une ou plusieurs séries (par lot),
    si la longueur, le nombre de rang ou la distance sur la rang sont modifiées,
    recalculer pour chaque série le nombre de plants nécessaires.
  - *Ajout de séries* : lorsque une série est créée avec affection d'emplacements
    depuis la fênetre d'ajout de séries, les emplacements sont imméditement
    dans la vue des séries.
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

### Corrections
  - Construction du fichier AppImage.

## 0.1 - 2019-01-09

Première version publique.
