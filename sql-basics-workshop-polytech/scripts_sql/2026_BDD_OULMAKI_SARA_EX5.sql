-- ============================================
-- Exercice 5 : Mises à jour (UPDATE) et suppressions (DELETE)
-- Réalisé par : OULMAKI Sara
-- Date : 2026-06-01
-- ============================================

-- Partie A : UPDATE

-- 1. Modifier un montant palier : Augmentez de 10% le montant palier du défi "Saut en parachute" (ou un autre défi).

UPDATE Defi
SET montant_palier = montant_palier * 1.10
WHERE intitule = 'Saut en parachute';
SELECT intitule, montant_palier
FROM Defi
WHERE intitule = 'Saut en parachute';

-- 2. Valider tous les défis non validés ayant au moins 3 participants :
    -- Utilisez une sous-requête pour compter le nombre de participants par défi
    -- Mettez à jour l'état de validation à TRUE

UPDATE Defi
SET etat_validation = TRUE
WHERE id_defi IN (
    SELECT id_defi
    FROM participation_defi
    GROUP BY id_defi
    HAVING COUNT(id_streamer) >= 3
);

SELECT d.intitule, d.etat_validation, COUNT(p.id_streamer) AS nb_participants
FROM Defi d
LEFT JOIN participation_defi p ON d.id_defi = p.id_defi
GROUP BY d.id_defi, d.intitule, d.etat_validation
ORDER BY nb_participants DESC;

-- Partie B : DELETE

-- 3. Supprimer les streams non terminés : Supprimez tous les streams dont la date_fin_effective est ǸULL.

DELETE FROM Stream
WHERE date_fin_effective IS NULL;

SELECT id_stream, titre, date_fin_effective
FROM Stream
WHERE date_fin_effective IS NULL;

-- 4. Supprimer les créneaux passés : Supprimez les créneaux dont la date de fin autorisée est antérieure à aujourd'hui.

DELETE FROM Creneau
WHERE date_fin_autorisee < CURRENT_DATE;

SELECT id_creneau, date_debut_autorisee, date_fin_autorisee
FROM Creneau
WHERE date_fin_autorisee < CURRENT_DATE;

