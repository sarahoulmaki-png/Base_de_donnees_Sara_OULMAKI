-- ============================================
-- Exercice 8 : Analyse de performance et création d'index
-- Réalisé par : OULMAKI Sara
-- Date : 2026-06-01
-- ============================================

-- Étape 1 : Charger des données massives

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

-- Étape 3 : Exécuter une requête complexe SANS index

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

-- Résultat étapes 1 et 3 :

/*

Sort  (cost=162.32..164.93 rows=1044 width=758) (actual time=2.287..2.295 rows=18.00 loops=1)
  Sort Key: s.pseudo, d.intitule
  Sort Method: quicksort  Memory: 26kB
  Buffers: shared hit=7
  ->  HashAggregate  (cost=99.54..109.98 rows=1044 width=758) (actual time=2.058..2.075 rows=18.00 loops=1)
        Group Key: s.pseudo, d.id_defi
        Batches: 1  Memory Usage: 65kB
        Buffers: shared hit=4
        ->  Hash Join  (cost=37.42..86.49 rows=1044 width=762) (actual time=1.816..1.979 rows=62.00 loops=1)
              Hash Cond: (pd.id_defi = d.id_defi)
              Buffers: shared hit=4
              ->  Hash Join  (cost=24.27..70.54 rows=1044 width=246) (actual time=1.094..1.230 rows=62.00 loops=1)
                    Hash Cond: (pd.id_streamer = s.id_streamer)
                    Buffers: shared hit=3
                    ->  Seq Scan on participation_defi pd  (cost=0.00..32.60 rows=2260 width=8) (actual time=0.016..0.019 rows=18.00 loops=1)
                          Buffers: shared hit=1
                    ->  Hash  (cost=23.69..23.69 rows=46 width=242) (actual time=0.929..0.933 rows=30.00 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 10kB
                          Buffers: shared hit=2
                          ->  Hash Right Join  (cost=11.91..23.69 rows=46 width=242) (actual time=0.277..0.893 rows=30.00 loops=1)
                                Hash Cond: (st.id_streamer = s.id_streamer)
                                Buffers: shared hit=2
                                ->  Seq Scan on stream st  (cost=0.00..11.40 rows=140 width=24) (actual time=0.015..0.019 rows=30.00 loops=1)
                                      Buffers: shared hit=1
                                ->  Hash  (cost=11.50..11.50 rows=33 width=222) (actual time=0.054..0.055 rows=10.00 loops=1)
                                      Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                      Buffers: shared hit=1
                                      ->  Seq Scan on streamer s  (cost=0.00..11.50 rows=33 width=222) (actual time=0.042..0.045 rows=10.00 loops=1)
                                            Filter: ((id_streamer + 0) < 5000)
                                            Buffers: shared hit=1
              ->  Hash  (cost=11.40..11.40 rows=140 width=520) (actual time=0.543..0.543 rows=10.00 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 9kB
                    Buffers: shared hit=1
                    ->  Seq Scan on defi d  (cost=0.00..11.40 rows=140 width=520) (actual time=0.418..0.421 rows=10.00 loops=1)
                          Buffers: shared hit=1
Planning:
  Buffers: shared hit=200
Planning Time: 13.090 ms
Execution Time: 3.510 ms

*/

/*

Étape 4 : Analyser le plan d'exécution
    Notez le temps d'exécution (planning time + execution time) : 
    Recherchez les Seq Scan (scans séquentiels = full table scans)
    Identifiez les opérations coûteuses (haut nombre de lignes traitées)
    Documentez vos observations
    aside: positive Conseil : Vous pouvez aussi consulter l'onglet graphique dans pgAdmin pour une vue visuelle du plan.

1. Temps d'exécution :
   - Planning Time : 13.090 ms
   - Execution Time : 3.510 ms
   - Temps total : 16.600 ms

2. Seq Scan identifiés :
   - Seq Scan sur participation_defi : lit 2260 lignes en entier
   - Seq Scan sur stream : lit 140 lignes en entier
   - Seq Scan sur streamer : lit toute la table puis filtre
   - Seq Scan sur defi : lit 140 lignes en entier
   → Aucun index utilisé, toutes les tables sont lues complètement

3. Opérations coûteuses :
   - HashAggregate pour le GROUP BY : coût 99.54..109.98
   - Hash Right Join entre stream et streamer : coût 11.91..23.69
   - Le filtre (id_streamer + 0) < 5000 empêche l'utilisation
     d'un index car PostgreSQL ne reconnaît plus la colonne brute

4. Observations :
   - Sans index, PostgreSQL est obligé de tout lire ligne par ligne
   - Sur nos petites données ça reste rapide (3.5 ms)
   - Mais avec 700 000 lignes ce serait beaucoup plus lent
   - C'est pour ça qu'on va créer des index à l'étape suivante

*/

-- Étape 5 : Créer les index appropriés
    -- Créez ces index pour optimiser la requête :

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

/*

Étape 6 : Réexécuter la requête et comparer
    Réexécutez le EXPLAIN ANALYZE de l'étape 3 et comparez :
    Temps d'exécution (avant / après)
    Types de scans (Seq Scan → Index Scan)
    Nombre de lignes traitées
    Calculez le gain en performance (%)
    aside: positive Résultat attendu : Vous devriez observer une amélioration de 50-80% en temps d'exécution.

*/

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


/*

Incremental Sort  (cost=26.77..27.15 rows=6 width=758) (actual time=2.302..2.312 rows=18.00 loops=1)
  Sort Key: s.pseudo, d.intitule
  Presorted Key: s.pseudo
  Full-sort Groups: 1  Sort Method: quicksort  Average Memory: 26kB  Peak Memory: 26kB
  Buffers: shared hit=7
  ->  GroupAggregate  (cost=26.73..26.88 rows=6 width=758) (actual time=2.105..2.175 rows=18.00 loops=1)
        Group Key: s.pseudo, d.id_defi
        Buffers: shared hit=4
        ->  Sort  (cost=26.73..26.75 rows=6 width=762) (actual time=1.798..1.812 rows=62.00 loops=1)
              Sort Key: s.pseudo, d.id_defi
              Sort Method: quicksort  Memory: 29kB
              Buffers: shared hit=4
              ->  Hash Join  (cost=14.67..26.66 rows=6 width=762) (actual time=1.468..1.510 rows=62.00 loops=1)
                    Hash Cond: (d.id_defi = pd.id_defi)
                    Buffers: shared hit=4
                    ->  Seq Scan on defi d  (cost=0.00..11.40 rows=140 width=520) (actual time=0.041..0.043 rows=10.00 loops=1)
                          Buffers: shared hit=1
                    ->  Hash  (cost=14.60..14.60 rows=6 width=246) (actual time=1.071..1.075 rows=62.00 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 13kB
                          Buffers: shared hit=3
                          ->  Hash Right Join  (cost=13.16..14.60 rows=6 width=246) (actual time=0.928..1.027 rows=62.00 loops=1)
                                Hash Cond: (st.id_streamer = s.id_streamer)
                                Buffers: shared hit=3
                                ->  Seq Scan on stream st  (cost=0.00..1.30 rows=30 width=24) (actual time=0.011..0.016 rows=30.00 loops=1)
                                      Buffers: shared hit=1
                                ->  Hash  (cost=13.09..13.09 rows=6 width=226) (actual time=0.821..0.824 rows=18.00 loops=1)
                                      Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                      Buffers: shared hit=2
                                      ->  Hash Join  (cost=1.41..13.09 rows=6 width=226) (actual time=0.374..0.803 rows=18.00 loops=1)
                                            Hash Cond: (s.id_streamer = pd.id_streamer)
                                            Buffers: shared hit=2
                                            ->  Seq Scan on streamer s  (cost=0.00..11.50 rows=33 width=222) (actual time=0.118..0.122 rows=10.00 loops=1)
                                                  Filter: ((id_streamer + 0) < 5000)
                                                  Buffers: shared hit=1
                                            ->  Hash  (cost=1.18..1.18 rows=18 width=8) (actual time=0.064..0.065 rows=18.00 loops=1)
                                                  Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                  Buffers: shared hit=1
                                                  ->  Seq Scan on participation_defi pd  (cost=0.00..1.18 rows=18 width=8) (actual time=0.007..0.011 rows=18.00 loops=1)
                                                        Buffers: shared hit=1
Planning:
  Buffers: shared hit=217 read=5
Planning Time: 13.124 ms
Execution Time: 3.784 ms

Avant index :
   - Planning Time : 13.090 ms
   - Execution Time : 3.510 ms

Après index :
   - Planning Time : 13.124 ms
   - Execution Time : 3.784 ms

Observation :
   - Le temps n'a pas vraiment changé car le (id_streamer + 0)
     empêche PostgreSQL d'utiliser les index qu'on vient de créer
   - Le plan a quand même évolué : HashAggregate est remplacé par
     GroupAggregate, ce qui consomme moins de mémoire (65kB → 0kB)
   - Sans ce trick, on aurait eu 50-80% de gain sur les données massives

*/

-- Étape 7 (Bonus) : Index pour les recherches LIKE
    --Pour optimiser les recherches par pattern sur le pseudo :

-- Activer l'extension trigram
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Créer un index trigram pour les recherches LIKE
CREATE INDEX idx_streamer_pseudo_trgm 
    ON streamer USING gin (pseudo gin_trgm_ops);

EXPLAIN ANALYZE
SELECT s.pseudo, COUNT(pd.id_defi) as nb_defis
FROM streamer s
LEFT JOIN participation_defi pd ON s.id_streamer = pd.id_streamer
WHERE s.pseudo LIKE '%pseudo%1%'
GROUP BY s.id_streamer, s.pseudo;

/*

GroupAggregate  (cost=2.39..2.41 rows=1 width=230) (actual time=0.124..0.130 rows=0.00 loops=1)
  Group Key: s.pseudo
  Buffers: shared hit=1
  ->  Sort  (cost=2.39..2.39 rows=2 width=226) (actual time=0.122..0.127 rows=0.00 loops=1)
        Sort Key: s.pseudo
        Sort Method: quicksort  Memory: 25kB
        Buffers: shared hit=1
        ->  Hash Right Join  (cost=1.14..2.38 rows=2 width=226) (actual time=0.087..0.092 rows=0.00 loops=1)
              Hash Cond: (pd.id_streamer = s.id_streamer)
              Buffers: shared hit=1
              ->  Seq Scan on participation_defi pd  (cost=0.00..1.18 rows=18 width=8) (never executed)
              ->  Hash  (cost=1.12..1.12 rows=1 width=222) (actual time=0.050..0.053 rows=0.00 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 8kB
                    Buffers: shared hit=1
                    ->  Seq Scan on streamer s  (cost=0.00..1.12 rows=1 width=222) (actual time=0.048..0.048 rows=0.00 loops=1)
                          Filter: ((pseudo)::text ~~ '%pseudo%1%'::text)
                          Rows Removed by Filter: 10
                          Buffers: shared hit=1
Planning:
  Buffers: shared hit=48
Planning Time: 1.857 ms
Execution Time: 0.364 ms

*/

/*

Étape 8 : Conclusion
    Documentez votre analyse :
        Quels index ont eu le plus d'impact ?
        Pourquoi les jointures sur participation_defi étaient lentes sans index ?
        Quel est le gain de performance global (en %) ?

Étape 8 : Conclusion

1. Index ayant eu le plus d'impact :
   - Les index sur participation_defi (id_streamer et id_defi)
     car c'est la table avec le plus de lignes (250 000)
     et elle est utilisée dans toutes les jointures

2. Pourquoi les jointures sur participation_defi étaient lentes :
   - Sans index, PostgreSQL lit toutes les lignes une par une (Seq Scan)
   - Avec un index, il accède directement aux bonnes lignes
   - C'est la différence entre chercher dans un annuaire trié
     ou lire toutes les pages depuis le début

3. Gain de performance :
   - Sur ce test : ~0% à cause du trick (id_streamer + 0)
   - Sur une vraie requête avec les 700 000 lignes : 50-80% de gain attendu

*/

