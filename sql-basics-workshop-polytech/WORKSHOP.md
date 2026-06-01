# Gestion de l'Infrastructure de Données du ZEvent

## Présentation du projet
Dans cet exercice, nous allons créer une base de données pour gérer les dons du ZEvent.

## Consignes de rendu
### Date 
À définir lors du premier TP. 

### Format 

cf. [README](./README.md)

## 📊 Analyse des besoins (Contexte ZEvent)

L'objectif est de structurer les flux d'informations d'un marathon de streaming. Identifiez les entités pivots du système :

* Streamer : L'acteur central (pseudo, configuration, présence physique).
* Stream : La session temporelle (un streamer pouvant avoir plusieurs créneaux).
* Créneau : Les slots horaires autorisés pour les streamers.
* Défi (_Donation Goal_) : Les objectifs à atteindre, pouvant impliquer plusieurs participants simultanément.

Identifiez les attributs critiques pour l'intégrité des données, notamment les types de données financiers (``DECIMAL`` pour les montants) et temporels (``TIMESTAMP`` pour les flux de dons).

## 📐 Modélisation Conceptuelle (MCD)

En utilisant le formalisme MERISE, représentez les interactions complexes du ZEvent :

* Entités et Attributs : Définissez les clés primaires pour chaque entité.
* Associations et Cardinalités

| Entité 1| Entité 2 | Description |
| :--- | :--- | :--- |
| Streamer | Stream | Un streamer peut diffuser plusieurs fois |
| Streamer | Créneau | Un streamer peut avoir plusieurs créneaux autorisés |
| Stream | Créneau | Un stream doit respecter un créneau |
| Streamer | Défi | Plusieurs streamers peuvent s'unir pour un même objectif (ex: un tournoi ou un défi collectif)|

Contraintes : Précisez les cardinalités minimales et maximales (ex: ``1,1`` ou ``0,n``, ``m-n``).

## ⚙️ Modélisation Logique (MLD)

Transformez votre schéma conceptuel en un schéma relationnel optimisé pour PostgreSQL.

Traduction des relations :

- Les relations ``1:N`` se traduisent par l'importation d'une clé étrangère dans la table "fille".
- La relation ``M:N`` doit impérativement être décomposée en une table de liaison portant les clés primaires des deux tables parentes (ex: ``participation_defi``).
- Typage et Optimisation : Documentez précisément le schéma en choisissant des types PostgreSQL appropriés (ex: ``SERIAL`` pour l'auto-incrémentation, ``TEXT`` pour les messages de dons volumineux).
- Intégrité Référentielle : Définissez les comportements en cascade (``ON DELETE CASCADE``) pour assurer la cohérence de la base lors de la suppression d'un streamer ou d'un défi.

## Conception de la base de données

La base de données peut être créée en utilisant un logiciel de gestion de base de données relationnelle. Dans le cadre de ce TP, nous utiliserons PostgreSQL.

### Schéma SQL attendu

Vous devez créer les tables suivantes avec les colonnes indiquées :

**Streamer**
- `id_streamer` (SERIAL, clé primaire)
- `pseudo` (VARCHAR, unique)
- `url_twitch` (VARCHAR)

**Créneau**
- `id_creneau` (SERIAL, clé primaire)
- `id_streamer` (INT, clé étrangère)
- `date_debut_autorisee` (TIMESTAMP)
- `date_fin_autorisee` (TIMESTAMP)

**Stream**
- `id_stream` (SERIAL, clé primaire)
- `id_streamer` (INT, clé étrangère)
- `id_creneau` (INT, clé étrangère)
- `titre` (VARCHAR)
- `heure_debut` (TIMESTAMP)
- `heure_fin` (TIMESTAMP)
- `date_fin_effective` (TIMESTAMP, nullable)

**Défi**
- `id_defi` (SERIAL, clé primaire)
- `intitule` (VARCHAR)
- `montant_palier` (DECIMAL(12,2))
- `etat_validation` (BOOLEAN)

**Participation_Defi** (Table de liaison M:N)
- `id_streamer` (INT, clé étrangère)
- `id_defi` (INT, clé étrangère)
- Clé primaire composée : (id_streamer, id_defi)

## Implémentation de la base de données

Après avoir conçu la base de données, mettez en place en créant les tables et vérifiez que les contraintes de clé étrangère sont bien présentes. Les exercices ci-dessous vous permettront de mettre en place des requêtes avec des niveaux de difficultés progressives.

---

# 📚 PHASE 1 : Fondamentaux

## Exercice 1 : Population de la base de données

### Contexte
L'objectif de cet exercice est de simuler l'activité de l'événement en alimentant la base de données que vous avez créée précédemment. Vous devrez respecter les contraintes d'intégrité (clés étrangères) lors des insertions.

**Renseigner dans le script SQL toutes les requêtes que vous réalisez pour peupler les tables.**

### Instructions

#### Population de la table « Streamer »
- Dictionnaire de données : Proposez une description du contenu de la table (ex: Quel type pour le pseudo ? Comment gérer l'URL Twitch ?).
- Implémentation : (Déjà réalisée dans le script global, vérifiez simplement la structure).
- Insertion : Complétez la table avec au moins 10 streamers célèbres (ex: ZeratoR, Antoine Daniel, Mister MV, Ultia, etc.).

#### Population de la table « Créneau »

Un créneau est une période de temps pendant laquelle un streamer est autorisé à diffuser.

- Dictionnaire de données : Proposez un contenu cohérent (ID Streamer, Date/Heure début autorisée, Date/Heure fin autorisée).
- Implémentation : Assurez-vous que les dates sont au format ``TIMESTAMP``.
- Insertion : Ajoutez au moins 2-3 créneaux par streamer (ex: créneau du vendredi soir, créneau du samedi matin, etc.).

#### Population de la table « Défi »

Dans le contexte du ZEvent, le défi est un objectif de donation (ex: "Saut en parachute", "Teinture de cheveux", "Jeu d'horreur").

- Dictionnaire de données : Proposez un contenu cohérent (Intitulé du défi, montant palier à atteindre, état de validation).
- Implémentation : Assurez-vous que le type ``DECIMAL(12, 2)`` est bien utilisé pour les montants.
- Insertion : Ajoutez au moins 10 défis variés avec des paliers allant de 500 € à 100 000 €.

#### Population de la table « Participation_Defi » (Relation M:N)

C'est ici que vous liez les streamers aux défis qu'ils se sont engagés à réaliser. Un défi peut être collectif (plusieurs streamers sur un même saut en parachute).

- Description : Proposez un tableau de correspondance montrant quel streamer est lié à quel défi.
- Contrainte : Une participation est valide uniquement si les IDs existent dans les tables parentes.
- Insertion : Complétez avec au moins 15 lignes pour simuler des défis en solo et des défis en groupe.

#### Population de la table « Stream »

Un stream est une session temporelle avec une heure de début, une heure de fin, et une date de fin effective (qui peut être nulle si le stream n'est pas encore terminé).

- Tableau de description : Détaillez les attributs nécessaires pour une session (ID Streamer, ID Créneau, Titre, Heure Début, Heure Fin, Date Fin Effective).
- Format Temporel : Utilisez le format ISO ``YYYY-MM-DD HH:MM:SS`` pour les colonnes de type ``TIMESTAMP``.
- Insertion : Ajoutez au moins 10-15 streams. Assurez-vous que :
  - Chaque stream référence un créneau valide
  - Les heures de début/fin respectent le créneau autorisé
  - Certains streams ont une `date_fin_effective` remplie, d'autres `NULL`

> aside: positive
> **Conseil** : Utilisez des heures réalistes sur un week-end (ex: 2025-09-05 pour le vendredi, 2025-09-06 pour le samedi)


#### Vérification des données

Effectuez des requêtes ``SELECT`` pour vérifier que les données ont bien été insérées.


---

## Exercice 2 : Requêtes SELECT simples et filtrées

### Contexte
Cet exercice consolide vos compétences en sélection de données avec des clauses ``WHERE`` basiques.

### Instructions

Effectuez au moins 4 requêtes SELECT pour vérifier vos données :

1. **Tous les streamers avec leur URL Twitch**, ordonnés par pseudo
2. **Les créneaux du samedi 2025-09-06** (utilisez ``DATE()`` pour extraire la date)
3. **Les défis validés ayant un montant palier > 5000 €**
4. **Les streams dont la date de fin effective est NULL** (c'est-à-dire, non terminés)

---

## Exercice 3 : Requêtes de jointure simples

### Contexte
Cet exercice vous fait progresser vers les jointures : combiner les données de plusieurs tables.

### Instructions

Effectuez les 3 requêtes de jointure suivantes :

1. **Streamers et leurs créneaux** : Affichez le pseudo du streamer et les dates de ses créneaux autorisés. Ordonnez par pseudo puis par date de créneau.

2. **Streams avec informations du streamer et du créneau** : Affichez le titre du stream, le pseudo du streamer, et la date du créneau. Filtrez sur les streams du 2025-09-05 ou du 2025-09-06.

3. **Défis et leurs participants** : Affichez l'intitulé du défi, les pseudonymes des streamers y participant, et le montant du palier. Utilisez la table ``participation_defi``.

---

# 📈 PHASE 2 : Requêtes Intermédiaires 

## Exercice 4 : Agrégations et statistiques

### Contexte
Vous allez maintenant calculer des statistiques sur vos données en utilisant les fonctions d'agrégation et ``GROUP BY``.

### Instructions

Effectuez les 4 requêtes suivantes :

1. **Nombre total de streams par streamer** : Affichez le pseudo et le nombre de streams effectués, même pour les streamers n'ayant aucun stream (nombre = 0). Ordonnez par nombre décroissant.
   > **Conseil** : Utilisez  ``COALESCE(COUNT(...), 0)`` pour afficher 0 au lieu de NULL.

2. **Montant total des paliers de défis par état de validation** : Affichez si le défi est validé ou pas, et le montant total des paliers pour chaque état. 

3. **Nombre de streamers ayant au moins 2 défis** : Affichez le pseudo et le nombre de défis de chaque streamer ayant au moins 2 défis.

4. **Durée moyenne des streams (en heures)** : Calculez ``(heure_fin - heure_debut)`` en heures pour chaque stream, puis affichez la durée moyenne globale. Affichez également le titre du stream.
   > **Conseil** : Utilisez ``EXTRACT(EPOCH FROM (heure_fin - heure_debut)) / 3600`` pour obtenir les heures. Utilisez également la fonction ``ÀVG`` et ``OVER()`` pour afficher la durée moyenne à côté de chaque stream (ex. ``AVG(...) OVER() AS duree_moyenne``).

5. **Afficher uniquement les streamers qui ont effectivement lancé au moins un stream, avec le titre de leur session**: Affiche le pseudo, le titre et l'heure de début.

---

## Exercice 5 : Mises à jour (UPDATE) et suppressions (DELETE)

### Contexte
Vous allez modifier et supprimer des données dans la base.

### Instructions

#### Partie A : UPDATE

1. **Modifier un montant palier** : Augmentez de 10% le montant palier du défi "Saut en parachute" (ou un autre défi).

2. **Valider tous les défis non validés ayant au moins 3 participants** : 
   - Utilisez une sous-requête pour compter le nombre de participants par défi
   - Mettez à jour l'état de validation à ``TRUE``

#### Partie B : DELETE

3. **Supprimer les streams non terminés** : Supprimez tous les streams dont la ``date_fin_effective``  est ``ǸULL``.

4. **Supprimer les créneaux passés** : Supprimez les créneaux dont la date de fin autorisée est antérieure à aujourd'hui.
   > **Conseil** : Utilisez la fonction ``CURRENT_DATE``

> aside: negative
> ⚠️ **ATTENTION** : Avant de supprimer, verifiez que les données référencées par des clés étrangères seront gérées (cf. ``CASCADE``). Testez d'abord avec un ``SELECT``.

---

# 🔍 PHASE 3 : Schéma Avancé et Requêtes M:N

## Exercice 6 : Requêtes avancées sur les données existantes

### Contexte
Avant d'étendre le modèle, maîtrisons les requêtes complexes sur le schéma actuel : requêtes avec sous-requêtes, ``LEFT JOIN``, ``HAVING``, `NOT EXISTS` et agrégations avancées.

### Instructions

Effectuez les 5 requêtes suivantes :

1. **Streamers ayant au moins un défi** : Affichez le pseudo du streamer et le nombre de défis auxquels il participe. 

2. **Défis n'ayant aucun participant** : Affichez l'intitulé et le montant des défis qui n'ont aucun streamer participant. 

3. **Défis ayant plus de 2 streamers participants** : Affichez l'intitulé, le montant, et le nombre de participants. 
> **Conseil** : Utilisez la fonction ``COALESCE(COUNT(...), 0)``

4. **Nombre de défis par streamer avec le montant total engagé** : Pour chaque streamer, affichez :
   - Pseudo
   - Nombre de défis
   - Montant total des paliers de ses défis
   - Ordonnez par montant total décroissant

5. **Streamers et créneaux avec nombre de streams effectués par créneau** : Affichez :
   - Pseudo du streamer
   - Dates du créneau
   - Nombre de streams effectués pour ce créneau

---

## Exercice 7 : Gestion des validations avec ``CASE`` et contraintes

### Contexte
Nous ajoutons des fonctionnalités de vérification de conformité : les streams doivent respecter les créneaux autorisés, et nous devons détecter les dépassements.

### Instructions

#### Partie A : Validation des streams contre les créneaux

1. Créez une requête affichant pour chaque stream :
   - Le titre du stream
   - Le pseudo du streamer
   - Les dates du créneau autorisé
   - Les heures réelles du stream
   - Un statut ``VALIDE`` ou ``INVALIDE`` (en utilisant ``CASE``)
     - VALIDE : si ``heure_debut >= date_debut_autorisee`` ET ``heure_fin <= date_fin_autorisee``
     - INVALIDE : sinon

```sql
CASE
    WHEN ...condition...
    THEN 'VALEUR'
    ELSE 'AUTRE VALEUR'
END as validation
```

2. Identifiez les streams invalides (requête filtrée avec ``WHERE``)

#### Partie B : Détection des dépassements de fin

3. Créez une requête affichant pour chaque stream :
   - Le titre du stream
   - Le pseudo du streamer
   - L'heure de fin prévue (``heure_fin``)
   - La date de fin effective (``date_fin_effective``)
   - Un statut ``OK`` ou ``DEPASSEMENT`` (en utilisant ``CASE``)
   - La durée du dépassement en minutes (si applicable)


4. Affichez un résumé : nombre de streams en retard, durée moyenne de retard

Combinez les deux requêtes en une seule pour un aperçu complet de la conformité des streams.

---

# ⚡ PHASE 4 : Performance et Indexation 

## Exercice 8 : Analyse de performance et création d'index

### Contexte
Nous simulons les effets indésirables du traitement d'un grand volume de données. L'objectif est d'analyser les problèmes de performance avec des **full table scans** et de les résoudre par la création d'**index appropriés**.

### Instructions

#### Étape 1 : Charger des données massives

Exécutez le script suivant pour charger un volume important de données (~ 700K lignes) :

```sql
TRUNCATE TABLE stream, participation_defi, creneau, defi, streamer RESTART IDENTITY CASCADE;

-- 2. Insert 50,000 streamers
DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO streamer (pseudo, url_twitch)
        VALUES ('pseudo_' || i, 'https://twitch.tv/pseudo_' || i);
    END LOOP;
END $$;

-- 3. Insert 50,000 défis
DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO defi (intitule, montant_palier, etat_validation)
        VALUES (
            'defi_' || i,
            (random() * 50000)::DECIMAL(12,2) + 500,
            (random() < 0.5)
        );
    END LOOP;
END $$;

-- 4. Insert 250,000 participations (M:N)
-- Correction : Utilisation de FLOOR et gestion des conflits de clés primaires
DO $$
BEGIN
    FOR i IN 1..250000 LOOP
        INSERT INTO participation_defi (id_streamer, id_defi)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 50000 + 1)::INT
        )
        ON CONFLICT DO NOTHING; -- Évite l'erreur si le couple existe déjà
    END LOOP;
END $$;

-- 5. Insert 100,000 créneaux
DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00' + (random() * 48)::INT * INTERVAL '1 hour';
        end_date := start_date + (random() * 4 + 1)::INT * INTERVAL '1 hour';
        INSERT INTO creneau (id_streamer, date_debut_autorisee, date_fin_autorisee)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            start_date,
            end_date
        );
    END LOOP;
END $$;

-- 6. Insert 100,000 streams
DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
    effective_end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00' + (random() * 48)::INT * INTERVAL '1 hour';
        end_date := start_date + (random() * 4 + 1)::INT * INTERVAL '1 hour';
        effective_end_date := CASE WHEN random() < 0.7 
                              THEN end_date 
                              ELSE end_date + (random() * 3)::INT * INTERVAL '1 hour'
                              END;
        INSERT INTO stream (id_streamer, id_creneau, titre, heure_debut, heure_fin, date_fin_effective)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 100000 + 1)::INT,
            'Stream caritatif ' || i,
            start_date,
            end_date,
            effective_end_date
        );
    END LOOP;
END $$;

```

#### Étape 3 : Exécuter une requête complexe SANS index

Exécutez cette requête et observez les performances :

```sql
EXPLAIN ANALYZE
SELECT 
    s.pseudo,
    d.intitule,
    COUNT(st.id_stream) as nb_streams,
    COUNT(CASE WHEN st.date_fin_effective > st.heure_fin THEN 1 END) as nb_depassements
FROM streamer s
JOIN participation_defi pd ON s.id_streamer = pd.id_streamer
JOIN defi d ON pd.id_defi = d.id_defi
LEFT JOIN stream st ON s.id_streamer = st.id_streamer
-- MODIFICATION : On applique une fonction sur la colonne indexée
-- Cela empêche l'utilisation de l'index B-Tree classique
WHERE (s.id_streamer + 0) < 5000 
GROUP BY s.id_streamer, s.pseudo, d.id_defi, d.intitule
ORDER BY s.pseudo, d.intitule;
```

#### Étape 4 : Analyser le plan d'exécution

1. Notez le temps d'exécution (planning time + execution time)
2. Recherchez les **Seq Scan** (scans séquentiels = full table scans)
3. Identifiez les opérations coûteuses (haut nombre de lignes traitées)
4. Documentez vos observations

> aside: positive
> **Conseil** : Vous pouvez aussi consulter l'onglet graphique dans pgAdmin pour une vue visuelle du plan.

#### Étape 5 : Créer les index appropriés

Créez ces index pour optimiser la requête :

```sql
-- Index sur les clés étrangères impliquées dans les jointures
CREATE INDEX idx_participation_defi_id_streamer 
    ON participation_defi(id_streamer);
CREATE INDEX idx_participation_defi_id_defi 
    ON participation_defi(id_defi);

-- Index sur les jointures de stream
CREATE INDEX idx_stream_id_streamer 
    ON stream(id_streamer);

-- Index sur les comparaisons et filtres
CREATE INDEX idx_stream_date_fin_effective 
    ON stream(date_fin_effective);

-- Index composé pour les filtres combinés
CREATE INDEX idx_stream_id_streamer_date_fin_effective 
    ON stream(id_streamer, date_fin_effective);
```

#### Étape 6 : Réexécuter la requête et comparer

Réexécutez le ``EXPLAIN ANALYZE`` de l'étape 3 et comparez :

1. Temps d'exécution (avant / après)
2. Types de scans (Seq Scan → Index Scan)
3. Nombre de lignes traitées
4. Calculez le gain en performance (%)

> aside: positive
> **Résultat attendu** : Vous devriez observer une amélioration de 50-80% en temps d'exécution.

#### Étape 7 (Bonus) : Index pour les recherches LIKE

Pour optimiser les recherches par pattern sur le pseudo :

```sql
-- Activer l'extension trigram
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Créer un index trigram pour les recherches LIKE
CREATE INDEX idx_streamer_pseudo_trgm 
    ON streamer USING gin (pseudo gin_trgm_ops);
```

Testez avec cette requête :

```sql
EXPLAIN ANALYZE
SELECT s.pseudo, COUNT(pd.id_defi) as nb_defis
FROM streamer s
LEFT JOIN participation_defi pd ON s.id_streamer = pd.id_streamer
WHERE s.pseudo LIKE '%pseudo%1%'
GROUP BY s.id_streamer, s.pseudo;
```

#### Étape 8 : Conclusion

Documentez votre analyse :

1. Quels index ont eu le plus d'impact ?
2. Pourquoi les jointures sur ``participation_defi`` étaient lentes sans index ?
3. Quel est le gain de performance global (en %) ?

---

# 🎯 PHASE 5 : Bonus - Optionnel

## Exercice 9 : Requêtes avancées supplémentaires

### Contexte
Pour ceux qui terminent avant le temps imparti, voici des exercices supplémentaires pour approfondir vos connaissances.

### Instructions

#### Partie A : Fenêtres (Window Functions)

1. **Rang des streamers par nombre de streams** :
```sql
SELECT 
    pseudo,
    COUNT(DISTINCT st.id_stream) as nb_streams,
    ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT st.id_stream) DESC) as rang
FROM streamer s
LEFT JOIN stream st ON s.id_streamer = st.id_streamer
GROUP BY s.id_streamer, s.pseudo;
```

2. **Total cumulé des montants de défis** :
```sql
SELECT 
    intitule,
    montant_palier,
    SUM(montant_palier) OVER (ORDER BY id_defi) as total_cumule
FROM defi
ORDER BY id_defi;
```

#### Partie B : CTEs (Common Table Expressions)

3. **Utiliser une CTE pour identifier les streamers très actifs** :
```sql
WITH streamer_actifs AS (
    SELECT 
        s.id_streamer,
        s.pseudo,
        COUNT(st.id_stream) as nb_streams
    FROM streamer s
    LEFT JOIN stream st ON s.id_streamer = st.id_streamer
    GROUP BY s.id_streamer, s.pseudo
    HAVING COUNT(st.id_stream) > 2
)
SELECT * FROM streamer_actifs
ORDER BY nb_streams DESC;
```

---

## Exercice 10 : Optimisation avancée

### Contexte
Approfondir l'optimisation des requêtes complexes.

### Instructions

1. **Analyser une requête très complexe avec plusieurs jointures** : Décrivez les étapes d'optimisation :
   - Identifier les goulots d'étranglement : quelles sont les jointures les plus coûteuses ? Quels sont les filtres les moins sélectifs ? Quelles sont les opérations de tri ou d'agrégation les plus lourdes ?
   - Proposer des index spécifiques
2. **Créer des index partiels** (``WHERE`` clause dans l'index) :  Indexer uniquement les streams qui ont dépassé leur horaire prévu pour accélérer les rapports de retard.
3. **Étudier les statistiques de tables** (``ANALYZE``, ``pg_stat_statements``)

Exemple de requête complexe multi-jointures :

```sql
EXPLAIN ANALYZE
SELECT 
    s.pseudo,
    d.intitule,
    COUNT(DISTINCT st.id_stream) as nb_streams,
    AVG(EXTRACT(EPOCH FROM (st.heure_fin - st.heure_debut)) / 3600) as duree_moyenne,
    COUNT(CASE WHEN st.date_fin_effective > st.heure_fin THEN 1 END) as nb_depassements,
    SUM(CASE WHEN st.date_fin_effective > st.heure_fin 
             THEN EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60 
             ELSE 0 END) as total_depassement_minutes
FROM streamer s
JOIN participation_defi pd ON s.id_streamer = pd.id_streamer
JOIN defi d ON pd.id_defi = d.id_defi
LEFT JOIN stream st ON s.id_streamer = st.id_streamer
LEFT JOIN creneau cr ON st.id_creneau = cr.id_creneau
WHERE s.id_streamer < 10000
    AND cr.date_fin_autorisee >= '2025-09-05'
GROUP BY s.id_streamer, s.pseudo, d.id_defi, d.intitule
HAVING COUNT(DISTINCT st.id_stream) > 0
ORDER BY nb_depassements DESC;
```

---

# 📋 Résumé des Phases 

| Phase | Exercices | Contenu |
|-------|-----------|---------|
| **Phase 1** | Ex1-3 | CRUD, SELECT, JOIN simples | 
| **Phase 2** | Ex4-5 | Agrégations, UPDATE, DELETE | 
| **Phase 3** | Ex6-7 | Requêtes avancées, CASE, validation | 
| **Phase 4** | Ex8 | Index, EXPLAIN ANALYZE, performance | 
| **Phase 5** | Ex9-10 | Window Functions, CTEs, optimisation avancée | 
---

# ✅ Checklist d'Autoévaluation

Avant de rendre votre travail, assurez-vous que :

- [ ] Tous les fichiers SQL sont commentés et ordonnés par exercice
- [ ] Les données du schéma Phase 1-4 sont cohérentes et documentées
- [ ] Les requêtes d'Ex6-7 exécutent sans erreur
- [ ] Les index d'Ex8 montrent une amélioration mesurable
- [ ] Vos observations sur les performances sont documentées
- [ ] Vous avez testé vos scripts sur une instance PostgreSQL propre

---

# 🆘 Ressources et Troubleshooting

## Erreurs courantes

**Erreur : "Column ambiguous"**
- Solution : Préfixez les colonnes avec l'alias de la table (``s.pseudo``, ``d.intitule``)

**Erreur : "Foreign key constraint fails"**
- Solution : Vérifiez que l'ID référencé existe dans la table parente

**Erreur : "Table already exists"**
- Solution : Utilisez ``DROP TABLE IF EXISTS`` avant de créer une table

## Documentation PostgreSQL

- Fonctions de date/heure : https://www.postgresql.org/docs/current/functions-datetime.html
- Window Functions : https://www.postgresql.org/docs/current/functions-window.html
- CTEs : https://www.postgresql.org/docs/current/queries-with.html
- EXPLAIN/ANALYZE : https://www.postgresql.org/docs/current/sql-explain.html


## Documentation générale
- Formes normales : https://blog.idriss-code.fr/formes-normales-guide-pratique-pour-developpeurs/
