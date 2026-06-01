-- ============================================
-- Exercice 3 : Requêtes de jointure simples
-- Réalisé par : OULMAKI Sara
-- Date : 2026-05-18
-- ============================================

-- 1. Streamers et leurs créneaux
SELECT 
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM streamer s
JOIN creneau c ON s.id_streamer = c.id_streamer
ORDER BY s.pseudo, c.date_debut_autorisee;

-- 2. Streams avec informations du streamer et du créneau
SELECT 
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM stream st
JOIN streamer s ON st.id_streamer = s.id_streamer
JOIN creneau c ON st.id_creneau = c.id_creneau
WHERE DATE(c.date_debut_autorisee) IN ('2025-09-05', '2025-09-06')
   OR DATE(c.date_fin_autorisee) IN ('2025-09-05', '2025-09-06')
ORDER BY c.date_debut_autorisee;

-- 3. Défis et leurs participants
SELECT d.intitule, s.pseudo, d.montant_palier
FROM participation_defi p
JOIN streamer s ON p.id_streamer = s.id_streamer
JOIN defi d ON p.id_defi = d.id_defi
ORDER BY s.pseudo;
