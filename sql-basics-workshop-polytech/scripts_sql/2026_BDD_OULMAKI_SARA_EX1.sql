-- ============================================
-- Exercice 1 : Population de la base de données
-- Réalisé par : OULMAKI Sara
-- Date : 2026-05-18
-- ============================================

-- Suppression des tables si elles existent déjà (dans l'ordre pour respecter les FK)
DROP TABLE IF EXISTS participation_defi;
DROP TABLE IF EXISTS stream;
DROP TABLE IF EXISTS creneau;
DROP TABLE IF EXISTS defi;
DROP TABLE IF EXISTS streamer;

-- Table Streamer
CREATE TABLE streamer (
    id_streamer SERIAL PRIMARY KEY,
    pseudo      VARCHAR(100) NOT NULL UNIQUE,
    url_twitch  VARCHAR(255)
);

-- Table Créneau
CREATE TABLE creneau (
    id_creneau           SERIAL PRIMARY KEY,
    id_streamer          INT NOT NULL,
    date_debut_autorisee TIMESTAMP NOT NULL,
    date_fin_autorisee   TIMESTAMP NOT NULL,
    FOREIGN KEY (id_streamer) REFERENCES streamer(id_streamer) ON DELETE CASCADE
);

-- Table Défi
CREATE TABLE defi (
    id_defi          SERIAL PRIMARY KEY,
    intitule         VARCHAR(255) NOT NULL,
    montant_palier   DECIMAL(12,2) NOT NULL,
    etat_validation  BOOLEAN DEFAULT FALSE
);

-- Table Stream
CREATE TABLE stream (
    id_stream          SERIAL PRIMARY KEY,
    id_streamer        INT NOT NULL,
    id_creneau         INT NOT NULL,
    titre              VARCHAR(255) NOT NULL,
    heure_debut        TIMESTAMP NOT NULL,
    heure_fin          TIMESTAMP NOT NULL,
    date_fin_effective TIMESTAMP,
    FOREIGN KEY (id_streamer) REFERENCES streamer(id_streamer) ON DELETE CASCADE,
    FOREIGN KEY (id_creneau)  REFERENCES creneau(id_creneau)  ON DELETE CASCADE
);

-- Table Participation_Defi (liaison M:N)
CREATE TABLE participation_defi (
    id_streamer INT NOT NULL,
    id_defi     INT NOT NULL,
    PRIMARY KEY (id_streamer, id_defi),
    FOREIGN KEY (id_streamer) REFERENCES streamer(id_streamer) ON DELETE CASCADE,
    FOREIGN KEY (id_defi)     REFERENCES defi(id_defi)         ON DELETE CASCADE
);

-- ---------------------------------------------
-- TABLE STREAMER
-- Dictionnaire :
-- pseudo     : VARCHAR(100) - nom unique du streamer, NOT NULL
-- url_twitch : VARCHAR(255) - lien chaîne Twitch, NULL autorisé
-- ---------------------------------------------

INSERT INTO streamer (pseudo, url_twitch) VALUES
('ZeratoR',        'https://www.twitch.tv/zerator'),
('Antoine Daniel', 'https://www.twitch.tv/antoinedaniel'),
('Mister MV',      'https://www.twitch.tv/mistermv'),
('Ultia',          'https://www.twitch.tv/ultia'),
('Maghla',         'https://www.twitch.tv/maghla'),
('Ponce',          'https://www.twitch.tv/ponce'),
('Locklear',       'https://www.twitch.tv/locklear'),
('Domingo',        'https://www.twitch.tv/domingo'),
('Gotaga',         'https://www.twitch.tv/gotaga'),
('Kameto',         'https://www.twitch.tv/kameto');

-- ---------------------------------------------
-- TABLE CRÉNEAU
-- Dictionnaire :
-- id_streamer          : INT FK → streamer
-- date_debut_autorisee : TIMESTAMP - début du créneau autorisé
-- date_fin_autorisee   : TIMESTAMP - fin du créneau autorisé
-- ---------------------------------------------

INSERT INTO creneau (id_streamer, date_debut_autorisee, date_fin_autorisee) VALUES
-- ZeratoR (id=1)
(1, '2025-09-05 18:00:00', '2025-09-06 02:00:00'),
(1, '2025-09-06 10:00:00', '2025-09-06 18:00:00'),
(1, '2025-09-07 14:00:00', '2025-09-07 22:00:00'),
-- Antoine Daniel (id=2)
(2, '2025-09-05 20:00:00', '2025-09-06 04:00:00'),
(2, '2025-09-06 12:00:00', '2025-09-06 20:00:00'),
(2, '2025-09-07 16:00:00', '2025-09-08 00:00:00'),
-- Mister MV (id=3)
(3, '2025-09-05 16:00:00', '2025-09-06 00:00:00'),
(3, '2025-09-06 08:00:00', '2025-09-06 16:00:00'),
-- Ultia (id=4)
(4, '2025-09-05 19:00:00', '2025-09-06 03:00:00'),
(4, '2025-09-06 14:00:00', '2025-09-06 22:00:00'),
-- Maghla (id=5)
(5, '2025-09-05 17:00:00', '2025-09-06 01:00:00'),
(5, '2025-09-06 11:00:00', '2025-09-06 19:00:00'),
-- Ponce (id=6)
(6, '2025-09-05 21:00:00', '2025-09-06 05:00:00'),
(6, '2025-09-06 13:00:00', '2025-09-06 21:00:00'),
-- Locklear (id=7)
(7, '2025-09-05 18:00:00', '2025-09-06 02:00:00'),
(7, '2025-09-06 10:00:00', '2025-09-06 18:00:00'),
-- Domingo (id=8)
(8, '2025-09-05 20:00:00', '2025-09-06 04:00:00'),
(8, '2025-09-06 15:00:00', '2025-09-06 23:00:00'),
-- Gotaga (id=9)
(9, '2025-09-05 19:00:00', '2025-09-06 03:00:00'),
(9, '2025-09-06 09:00:00', '2025-09-06 17:00:00'),
-- Kameto (id=10)
(10, '2025-09-05 22:00:00', '2025-09-06 06:00:00'),
(10, '2025-09-06 16:00:00', '2025-09-07 00:00:00');

-- ---------------------------------------------
-- TABLE DÉFI
-- Dictionnaire :
-- intitule        : VARCHAR(255) - description du défi, NOT NULL
-- montant_palier  : DECIMAL(12,2) - montant à atteindre en euros
-- etat_validation : BOOLEAN - TRUE si validé, FALSE par défaut
-- ---------------------------------------------

INSERT INTO defi (intitule, montant_palier, etat_validation) VALUES
('Saut en parachute',            500.00,    FALSE),
('Teinture de cheveux',          1000.00,   TRUE),
('Jeu d horreur en direct',      2000.00,   TRUE),
('Course en karting',            5000.00,   FALSE),
('Déguisement 24h',     7500.00,   TRUE),
('Concert improvisé',            10000.00,  FALSE),
('Tatouage en direct',           15000.00,  TRUE),
('Marathon de 42km',             25000.00,  FALSE),
('Courir 12h non-stop',  50000.00,  TRUE),
('Défi ultime',           100000.00, FALSE);

-- ---------------------------------------------
-- TABLE PARTICIPATION_DEFI
-- Tableau de correspondance streamer ↔ défi
-- Défis solo et défis collectifs
-- ---------------------------------------------

INSERT INTO participation_defi (id_streamer, id_defi) VALUES
-- Défis solo
(1, 1),   -- ZeratoR       → Saut en parachute
(2, 2),   -- Antoine Daniel → Teinture de cheveux
(3, 3),   -- Mister MV     → Jeu d'horreur
(4, 4),   -- Ultia         → Course karting
(5, 5),   -- Maghla        → Déguisement ridicule
(6, 6),   -- Ponce         → Concert improvisé
(7, 7),   -- Locklear      → Tatouage
(8, 8),   -- Domingo       → Marathon
-- Défis collectifs
(1, 9),   -- ZeratoR       → Raid 12h
(2, 9),   -- Antoine Daniel → Raid 12h
(3, 9),   -- Mister MV     → Raid 12h
(1, 10),  -- ZeratoR       → Défi ultime
(2, 10),  -- Antoine Daniel → Défi ultime
(3, 10),  -- Mister MV     → Défi ultime
(4, 10),  -- Ultia         → Défi ultime
(5, 10),  -- Maghla        → Défi ultime
(9, 1),   -- Gotaga        → Saut en parachute (collectif)
(10, 1);  -- Kameto        → Saut en parachute (collectif)

-- ---------------------------------------------
-- TABLE STREAM
-- Dictionnaire :
-- id_streamer        : FK → streamer
-- id_creneau         : FK → creneau (doit être valide)
-- titre              : VARCHAR(255) NOT NULL
-- heure_debut        : TIMESTAMP NOT NULL (dans le créneau)
-- heure_fin          : TIMESTAMP NOT NULL (dans le créneau)
-- date_fin_effective : TIMESTAMP NULL (NULL si pas encore terminé)
-- ---------------------------------------------

INSERT INTO stream (id_streamer, id_creneau, titre, heure_debut, heure_fin, date_fin_effective) VALUES
(1,  1,  'ZeratoR ouvre le ZEvent !',         '2025-09-05 18:30:00', '2025-09-06 01:00:00', '2025-09-06 01:15:00'),
(2,  4,  'Antoine Daniel - Soirée karaoké',    '2025-09-05 20:30:00', '2025-09-06 03:00:00', '2025-09-06 03:00:00'),
(3,  7,  'Mister MV - Jeux rétro',             '2025-09-05 16:30:00', '2025-09-05 23:30:00', NULL),
(4,  9,  'Ultia - Just Dance marathon',        '2025-09-05 19:30:00', '2025-09-06 02:30:00', '2025-09-06 02:45:00'),
(5,  11, 'Maghla - Soirée horreur',            '2025-09-05 17:30:00', '2025-09-06 00:30:00', NULL),
(6,  13, 'Ponce - Blind test musical',         '2025-09-05 21:30:00', '2025-09-06 04:00:00', '2025-09-06 04:10:00'),
(7,  15, 'Locklear - FPS non-stop',            '2025-09-05 18:30:00', '2025-09-06 01:30:00', NULL),
(8,  17, 'Domingo - Débats & gaming',          '2025-09-05 20:30:00', '2025-09-06 03:30:00', '2025-09-06 03:30:00'),
(9,  19, 'Gotaga - Warzone 24h',               '2025-09-05 19:30:00', '2025-09-06 02:00:00', NULL),
(10, 21, 'Kameto - Nuit blanche ZEvent',       '2025-09-05 22:30:00', '2025-09-06 05:30:00', '2025-09-06 05:45:00'),
(1,  2,  'ZeratoR - Deuxième session',         '2025-09-06 10:30:00', '2025-09-06 17:00:00', '2025-09-06 17:00:00'),
(2,  5,  'Antoine Daniel - Afternoon show',    '2025-09-06 12:30:00', '2025-09-06 19:00:00', NULL),
(3,  8,  'Mister MV - Session du samedi',      '2025-09-06 08:30:00', '2025-09-06 15:00:00', '2025-09-06 15:20:00'),
(4,  10, 'Ultia - Samedi détente',             '2025-09-06 14:30:00', '2025-09-06 21:00:00', NULL),
(5,  12, 'Maghla - Clôture ZEvent',            '2025-09-06 11:30:00', '2025-09-06 18:30:00', '2025-09-06 18:30:00');

-- VÉRIFICATION

SELECT * FROM streamer         ORDER BY id_streamer;
SELECT * FROM creneau          ORDER BY id_creneau;
SELECT * FROM defi             ORDER BY id_defi;
SELECT * FROM participation_defi;
SELECT * FROM stream           ORDER BY id_stream;

