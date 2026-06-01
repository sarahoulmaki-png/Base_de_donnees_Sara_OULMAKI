-- ============================================
-- Exercice 4 : Agrégations et statistiques
-- Réalisé par : OULMAKI Sara
-- Date : 2026-06-01
-- ============================================

--1. Nombre total de streams par streamer : Affichez le pseudo et le nombre de streams effectués, même pour les streamers n'ayant aucun stream (nombre = 0). Ordonnez par nombre décroissant.

SELECT  s.pseudo, COALESCE(COUNT(st.id_stream), 0) AS stream_count
FROM Streamer s
LEFT JOIN Stream st ON st.id_streamer = s.id_streamer
GROUP BY s.pseudo
ORDER BY stream_count DESC;

--2. Montant total des paliers de défis par état de validation : Affichez si le défi est validé ou pas, et le montant total des paliers pour chaque état.

UPDATE Defi
SET etat_validation = TRUE
WHERE id_defi IN (1, 3, 5, 7, 9);

SELECT 
    d.intitule,
    SUM(d.montant_palier) AS total_paliers_valides
FROM defi d
WHERE d.etat_validation = TRUE
GROUP BY d.id_defi, d.intitule
ORDER BY d.intitule;

--3. Nombre de streamers ayant au moins 2 défis : Affichez le pseudo et le nombre de défis de chaque streamer ayant au moins 2 défis.

SELECT s.pseudo, COUNT(p.id_defi) AS nb_defis
FROM Streamer s
JOIN participation_defi p ON s.id_streamer = p.id_streamer
GROUP BY s.pseudo
HAVING COUNT(p.id_defi) >= 2
ORDER BY nb_defis DESC, s.pseudo;

--4. Durée moyenne des streams (en heures) : Calculez (heure_fin - heure_debut) en heures pour chaque stream, puis affichez la durée moyenne globale. Affichez également le titre du stream.

SELECT 
    st.titre,
    EXTRACT(EPOCH FROM (st.heure_fin - st.heure_debut)) / 3600 AS duree_heures,
    ROUND(AVG(EXTRACT(EPOCH FROM (st.heure_fin - st.heure_debut)) / 3600) OVER(), 2) AS duree_moyenne
FROM stream st
ORDER BY st.id_stream;

--5. Afficher uniquement les streamers qui ont effectivement lancé au moins un stream, avec le titre de leur session : Affiche le pseudo, le titre et l'heure de début.

SELECT DISTINCT
    s.pseudo,
    st.titre,
    st.heure_debut
FROM streamer s
INNER JOIN stream st ON s.id_streamer = st.id_streamer
ORDER BY s.pseudo, st.heure_debut;



