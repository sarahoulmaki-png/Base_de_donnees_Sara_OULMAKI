# Workshop SQL - Gestion de l'Infrastructure de Données du ZEvent

## 📖 Vue d'ensemble

Ce workshop SQL couvre les concepts fondamentaux à avancés de PostgreSQL à travers une étude de cas réaliste : la gestion des données du **ZEvent** (marathon de streaming caritatif).

### Objectifs

✅ Maîtriser les opérations CRUD (Create, Read, Update, Delete)
✅ Concevoir et implémenter un schéma relationnel M:N
✅ Écrire des requêtes avancées (jointures complexes, agrégations, sous-requêtes)
✅ Valider l'intégrité des données avec des contraintes SQL
✅ Optimiser les performances avec des index et l'analyse d'exécution

---

## 📚 Structure du Workshop

### Phases Pédagogiques

Le workshop est organisé en **4 phases obligatoires + 1 bonus** :

| Phase | Exercices | Objectif |
|-------|-----------|----------|
| **Phase 1** |  Ex1-3 | Fondamentaux CRUD et jointures simples |
| **Phase 2** |  Ex4-5 | Agrégations et modifications de données |
| **Phase 3** |  Ex6-7 | Requêtes avancées et validation |
| **Phase 4** |  Ex8 | Performance et indexation |
| **Phase 5** | Ex9-10 | (Optionnel) Window Functions et CTEs |

### Documents Fournis

```
📁 Workshop SQL
├── 📄 WORKSHOP.md                  ← Énoncé principal (à lire en entier)
├── 📄 README.md                    ← Ce fichier
└── 📁 scripts_sql/                 ← À compléter par l'étudiant
    ├── 2024_BDD_DUPONT_ALICE_EX1.sql
    ├── 2024_BDD_DUPONT_ALICE_EX2.sql
    ├── ...
    └── 2024_BDD_DUPONT_ALICE_EX8.sql
```

---

## 🚀 Démarrage Rapide
Le démarrage est décrit dans le fichier [START_HERE](./START_HERE.md).
---

## 📋 Énoncés des Phases

### Phase 1 : Fondamentaux

**Exercice 1** : Population manuelle de 5 tables
- Streamer, Créneau, Stream, Défi, Participation_Defi
- ~10-15 lignes par table

**Exercice 2** : SELECT simples avec WHERE
- 4 requêtes basiques de filtrage

**Exercice 3** : Jointures INNER/LEFT
- 3 requêtes combinant 2-3 tables

### Phase 2 : Requêtes Intermédiaires

**Exercice 4** : Agrégations (COUNT, SUM, AVG)
- 4 requêtes avec GROUP BY et HAVING

**Exercice 5** : UPDATE et DELETE
- 4 requêtes de modification/suppression

### Phase 3 : Avancé

**Exercice 6** : Requêtes M:N avancées
- 5 requêtes sur la relation streamer-défi

**Exercice 7** : Validation avec CASE
- Validation des créneaux
- Détection des dépassements
- Calcul des durées

### Phase 4 : Performance

**Exercice 8** : Index et EXPLAIN ANALYZE
- Charger 400K+ lignes de données
- Analyser requête SANS index
- Créer index appropriés
- Comparer avant/après
- Bonus : Index LIKE avec trigram

---

## 📊 Dépendances entre Exercices

```
Ex1 (Création + Chargement) 
  ↓
Ex2 (SELECT simple) → Ex3 (JOIN)
                       ↓
                   Ex4 (GROUP BY) → Ex5 (UPDATE/DELETE)
                       ↓
                   Ex6 (M:N avancé)
                       ↓
                   Ex7 (CASE + validation)
                       ↓
                   Ex8 (Index + Perf)
```

**Important** : Chaque exercice dépend des données des précédents. 

---

## 🎯 Compétences par Phase

| Phase | Compétences Clés |
|-------|-----------------|
| **Phase 1** | ``INSERT``, ``SELECT``, ``WHERE``, ``ORDER BY``, ``INNER/LEFT JOIN``, ``GROUP BY`` |
| **Phase 2** | ``COUNT/SUM/AVG``, ``HAVING``, ``UPDATE``, ``DELETE``, sous-requêtes |
| **Phase 3** | ``DISTINCT``, ``EXISTS``, ``CASE``, ``EXTRACT``, ``NOT EXISTS`` |
| **Phase 4** | ``CREATE INDEX``, ``EXPLAIN ANALYZE``, optimisation |
| **Phase 5** | ``ROW_NUMBER()``, ``SUM()`` ``OVER()``, ``WITH...AS`` (CTEs) |

---

## 📝 Format de Rendu

### Nommage des fichiers

#### Modélisation MCD/MLD

Copier coller une copie d'écran dans le projet GIT avec ce format :

- ```2024_BDD_[NOM]_[PRENOM]_MCD.png```
- ```2024_BDD_[NOM]_[PRENOM]_MLD.png```

#### Fichiers SQL

```
2024_BDD_[NOM]_[PRENOM]_EX[N].sql
```

Exemple : `2024_BDD_DUPONT_ALICE_EX1.sql`

### Contenu attendu

Chaque fichier SQL doit contenir :

```sql
-- ============================================
-- Exercice N : [Titre]
-- Réalisé par : [Nom Prénom]
-- Date : [Date]
-- ============================================

-- 1. [Description de la requête]
SELECT ...

-- 2. [Description de la requête]
UPDATE ...

-- etc.
```

### Livraison

1. Tous les fichiers SQL dans un dossier `scripts_sql/`
2. Tous les fichiers de modélisation (MCD/MLD) dans le dossier racine du projet
2. Commit et push sur GitHub
3. Envoyer le lien par mail avec sujet : **[BDD4][NOM][PRENOM] - Rendu de TP**

---

## ⚠️ Points d'Attention

### Erreurs courantes

| Erreur | Solution |
|--------|----------|
| "Column ambiguous" | Préfixez avec alias : `s.pseudo`, `d.intitule` |
| "FK constraint fails" | Vérifiez que l'ID parent existe |
| "Table already exists" | Utilisez `DROP TABLE IF EXISTS` |
| "NULL dans agrégation" | Utilisez `COALESCE(..., 0)` |

### Ordre d'Insertion Recommandé

Pour l'exercice 1, respectez cet ordre :

1. **Streamer** (table indépendante)
2. **Créneau** (FK → Streamer)
3. **Défi** (table indépendante)
4. **Participation_Defi** (FK → Streamer + Défi)
5. **Stream** (FK → Streamer + Créneau)

### Accents, caractères spéciaux

NE PAS UTILISER de caractères spéciaux ou de caractères accentués (ex. é) !

---

## 🔧 Troubleshooting

### Le chargement d'Ex8 prend 15+ minutes

C'est normal ! Les insertions massives sont lentes.
- Vérifiez que vous n'avez pas les FK activées pendant l'insertion
- Les 250K participations prennent le plus de temps (~1 min)

### EXPLAIN ANALYZE affiche "Planning time: 5000ms"

C'est normal pour la première exécution (cache PostgreSQL).
- Réexécutez 2 fois pour un temps réaliste

### _Je suis en retard_

**Priorité** : Les exercices 1 à 7 sont essentiels
- Vous pouvez sauter la phase 4 et la refaire après le TP
- Les données de l'exercice 8 sont indépendantes (script de reset)

---

## 📚 Ressources

### Documentation PostgreSQL

- **Fonctions Date/Heure** : https://www.postgresql.org/docs/current/functions-datetime.html
- **Window Functions** : https://www.postgresql.org/docs/current/functions-window.html
- **CTEs (WITH)** : https://www.postgresql.org/docs/current/queries-with.html
- **EXPLAIN/ANALYZE** : https://www.postgresql.org/docs/current/sql-explain.html
- **Indexes** : https://www.postgresql.org/docs/current/sql-createindex.html

### Outils Utiles

- **Visualiser EXPLAIN** : https://explain.depesz.com/
- **Index Strategies** : https://use-the-index-luke.com/
- **SQL Tutorial** : https://www.postgresqltutorial.com/

---

## ✅ Checklist de Rendu

Avant de rendre votre travail, vérifiez que :

- [ ] Tous les fichiers Ex1-8 présents
- [ ] Toutes les requêtes exécutent sans erreur
- [ ] Chaque requête est commentée
- [ ] Les données sont cohérentes (Ex1 cohérent pour Ex2-7)
- [ ] Phase 4 (Ex8) : observations documentées (timing, gain perf)
- [ ] Git repository public avec README.md
- [ ] Mail envoyé avec le lien git
