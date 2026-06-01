-- ============================================
-- Exercice 7 : Gestion des validations avec CASE et contraintes
-- Réalisé par : OULMAKI Sara
-- Date : 2026-06-01
-- ============================================

-- Partie A : Validation des streams contre les créneaux

/*

1. Créez une requête affichant pour chaque stream :
    Le titre du stream
    Le pseudo du streamer
    Les dates du créneau autorisé
    Les heures réelles du stream
    Un statut VALIDE ou INVALIDE (en utilisant CASE)
    VALIDE : si heure_debut >= date_debut_autorisee ET heure_fin <= date_fin_autorisee
    INVALIDE : sinon

    CASE
        WHEN ...condition...
        THEN 'VALEUR'
        ELSE 'AUTRE VALEUR'
    END as validation

*/

SELECT 
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin,
    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS statut_validation
FROM stream st
JOIN streamer s ON st.id_streamer = s.id_streamer
JOIN creneau c ON st.id_creneau = c.id_creneau
ORDER BY s.pseudo, st.heure_debut;

-- 2. Identifiez les streams invalides (requête filtrée avec WHERE)

SELECT 
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin
FROM stream st
JOIN streamer s ON st.id_streamer = s.id_streamer
JOIN creneau c ON st.id_creneau = c.id_creneau
WHERE st.heure_debut < c.date_debut_autorisee OR st.heure_fin > c.date_fin_autorisee
ORDER BY s.pseudo, st.heure_debut;

-- Partie B : Détection des dépassements de fin

/* 
-- 3. Créez une requête affichant pour chaque stream :
    Le titre du stream
    Le pseudo du streamer
    L'heure de fin prévue (heure_fin)
    La date de fin effective (date_fin_effective)
    Un statut OK ou DEPASSEMENT (en utilisant CASE)
    La durée du dépassement en minutes (si applicable)

*/

SELECT 
    st.titre,
    s.pseudo,
    st.heure_fin AS heure_fin_prevue,
    st.date_fin_effective,
    CASE
        WHEN st.date_fin_effective IS NULL THEN 'OK'
        WHEN st.date_fin_effective <= st.heure_fin THEN 'OK'
        ELSE 'DEPASSEMENT'
    END AS statut_depassement,
    CASE
        WHEN st.date_fin_effective > st.heure_fin THEN EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60
        ELSE 0
    END AS duree_depassement_minutes
FROM stream st
JOIN streamer s ON st.id_streamer = s.id_streamer
ORDER BY s.pseudo, st.heure_fin;

-- 4. Affichez un résumé : nombre de streams en retard, durée moyenne de retard
    -- Combinez les deux requêtes en une seule pour un aperçu complet de la conformité des streams.

-- 4. Résumé : nombre de streams en retard + durée moyenne de retard

SELECT 
    COUNT(*) AS nb_streams_en_retard,
    ROUND(AVG(EXTRACT(EPOCH FROM (date_fin_effective - heure_fin)) / 60), 2) AS retard_moyen_minutes
FROM stream
WHERE date_fin_effective > heure_fin;

-- Combinaison des deux requêtes (validation créneau + dépassement)
SELECT 
    st.titre,
    s.pseudo,
    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS statut_creneau,
    CASE
        WHEN st.date_fin_effective IS NULL THEN 'OK'
        WHEN st.date_fin_effective <= st.heure_fin THEN 'OK'
        ELSE 'DEPASSEMENT'
    END AS statut_depassement,
    CASE
        WHEN st.date_fin_effective > st.heure_fin 
        THEN ROUND(EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)
        ELSE 0
    END AS duree_depassement_minutes
FROM stream st
JOIN streamer s ON st.id_streamer = s.id_streamer
JOIN creneau c ON st.id_creneau = c.id_creneau
ORDER BY s.pseudo, st.heure_debut;


