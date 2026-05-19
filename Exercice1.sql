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

