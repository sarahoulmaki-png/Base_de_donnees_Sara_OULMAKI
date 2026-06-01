-- ============================================
-- Exercice 6 : Requêtes avancées sur les données existantes
-- Réalisé par : OULMAKI Sara
-- Date : 2026-06-01
-- ============================================

-- 1. Streamers ayant au moins un défi : Affichez le pseudo du streamer et le nombre de défis auxquels il participe.

SELECT s.pseudo, COUNT(p.id_defi) AS nb_defis
FROM Streamer s
JOIN participation_defi p ON s.id_streamer = p.id_streamer
GROUP BY s.pseudo
ORDER BY nb_defis DESC, s.pseudo;

-- 2. Défis n'ayant aucun participant : Affichez l'intitulé et le montant des défis qui n'ont aucun streamer participant.

SELECT d.intitule, d.montant_palier
FROM Defi d
LEFT JOIN participation_defi p ON d.id_defi = p.id_defi
WHERE p.id_streamer IS NULL
ORDER BY d.intitule;

-- 3. Défis ayant plus de 2 streamers participants : Affichez l'intitulé, le montant, et le nombre de participants.
-- Conseil : Utilisez la fonction COALESCE(COUNT(...), 0)
SELECT 
    d.intitule,
    d.montant_palier,
    COALESCE(COUNT(p.id_streamer), 0) AS nb_participants
FROM Defi d
LEFT JOIN participation_defi p ON d.id_defi = p.id_defi
GROUP BY d.id_defi, d.intitule, d.montant_palier
HAVING COALESCE(COUNT(p.id_streamer), 0) > 2
ORDER BY nb_participants DESC, d.intitule;

-- 4. Nombre de défis par streamer avec le montant total engagé : Pour chaque streamer, affichez :
    -- Pseudo
    -- Nombre de défis
    -- Montant total des paliers de ses défis
    -- Ordonnez par montant total décroissant

SELECT 
    s.pseudo,
    COUNT(p.id_defi) AS nb_defis,
    COALESCE(SUM(d.montant_palier), 0) AS montant_total
FROM Streamer s
LEFT JOIN participation_defi p ON s.id_streamer = p.id_streamer
LEFT JOIN Defi d ON p.id_defi = d.id_defi
GROUP BY s.id_streamer, s.pseudo
ORDER BY montant_total DESC, s.pseudo;

-- 5. Streamers et créneaux avec nombre de streams effectués par créneau : Affichez :
    -- Pseudo du streamer
    -- Dates du créneau
    -- Nombre de streams effectués pour ce créneau

SELECT 
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    COUNT(st.id_stream) AS nb_streams
FROM Streamer s
JOIN Creneau c ON s.id_streamer = c.id_streamer
LEFT JOIN Stream st ON st.id_creneau = c.id_creneau
GROUP BY s.id_streamer, s.pseudo, c.id_creneau, c.date_debut_autorisee, c.date_fin_autorisee
ORDER BY s.pseudo, c.date_debut_autorisee;

