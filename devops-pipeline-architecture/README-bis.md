# Plan d'action et feuille de route pour l'automatisation de l'infrastructure

## Phase 1 : Adoption des fondations et de l'IaC

**Objectif** : Établir les pratiques clés de l'infrastructure en tant que code et les pipelines CI/CD initiaux pour l'infrastructure.

### 1. Établir un référentiel d'infrastructure en tant que code (IaC) :

**Action** : Créer et configurer un référentiel Git Azure Repos dédié au stockage de toutes les définitions d'infrastructure. Ce référentiel constituera la source unique de référence pour notre infrastructure, offrant un contrôle de version et une plateforme pour les projets collaboratifs.

**Détails** : Tous les composants de l'infrastructure (Lambdas, API Gateway, Glue, etc) seront définis à l'aide de fichiers de configuration lisibles par machine (par exemple, des modèles ARM) plutôt que de processus manuels.

**Avantage** : Garantit la cohérence, la répétabilité et le contrôle des versions des modifications d'infrastructure.

### 2. Mettre en œuvre des pipelines CI/CD de base pour l'IaC (Azure Pipelines) :

**Action** : Adopter Azure Pipelines comme outil principal pour créer, tester et publier le code de l'infrastructure. Commencez par un ensemble de pipelines fondamentaux.

**Détails** :

- Pipelines de demandes de tirage (PR) pour l'IaC : Implémentez des pipelines de demandes de tirage (PR) pour les modifications du code d'infrastructure. Ces pipelines exécuteront des contrôles qualité rapides, tels que le linting, l'analyse statique du code et l'analyse de sécurité des modèles IaC, afin de détecter les vulnérabilités en amont. En cas d'échec des contrôles, le développeur devra apporter des modifications avant la fusion des branches git.

- Pipelines d'intégration continue (CI) pour l'IaC : Implémentez des pipelines d'intégration continue (CI) déclenchés par les fusions vers la branche principale. Ces pipelines exécuteront une validation plus complète et publieront les artefacts IaC (par exemple, les build de react, le code lambda en zip, etc) si tous les contrôles sont concluants.

**Avantage** : Accélération des contrôles qualité initiaux et garantie de l'intégrité du code d'infrastructure avant le déploiement.

### 3. Intégration de l'analyse de sécurité pour l'IaC :

**Action** : Intégrez des outils d'analyse de sécurité directement dans les pipelines de demandes de tirage et d'intégration continue pour analyser automatiquement le code d'infrastructure à la recherche de vulnérabilités.

**Détails** : Cela doit inclure l'analyse des erreurs de configuration courantes ou des schémas non sécurisés dans les fichiers IaC.

**Avantage** : Déplacement de la sécurité vers la gauche, identifiant et corrigeant les risques de sécurité de l'infrastructure plus tôt dans le cycle de développement.

## Phase 2 : Standardisation de l'environnement et préproduction automatisée

**Objectif** : Automatiser le provisionnement et la gestion des environnements hors production grâce à IaC (lab, dev et test).

### 1. Automatisation du provisionnement de l'environnement lab, dev et test:

**Action** : Intégrer l'environnement lab, dev et test au processus CI/CD pour provisionner les environnements avec les artefacts réutilisables.

### 2. Implémentation de déploiements de test automatisés :

**Action** : Étendre le pipeline CD pour automatiser le déploiement des modifications d'infrastructure et applicatives validées dans un environnement de test.

**Détails** : Après le déploiement, exécuter des tests d'acceptation automatisés sur l'environnement de test afin de valider la configuration et le comportement de l'infrastructure (example: Cilium, playwight, etc). Une étape de validation manuelle peut être incluse ici avant de poursuivre.

**Avantage** : Garantit que les modifications d'infrastructure sont rigoureusement testées dans un environnement proche de celui de production, réduisant ainsi les risques de publication.

## Phase 3 : Automatisation, surveillance et optimisation de la production

**Objectif** : Réaliser des déploiements de production entièrement automatisés, sécurisés et surveillés de l'infrastructure, avec des notifications et des améliorations continus.

### 1. Automatiser l'infrastructure de production

**Déploiements d'infrastructure** :

**Action** : Configurer le pipeline de livraison continue pour déployer automatiquement la solution d'infrastructure validée en production, ou via une approbation manuel par un administrateur.

**Détails** : Mettre en œuvre des tests de détection des erreurs en production après le déploiement afin de garantir le bon fonctionnement de l'infrastructure (example: Appels API test, tester la page web avec Cilium ou playwight, etc). En cas d'échec (annulation manuelle ou échec du test de détection de fuites), le pipeline doit permettre des retours automatiques à une version antérieure.

**Avantage** : Permet des déploiements rapides et à faible risque des modifications d'infrastructure en production.

### 2. Mettre en œuvre une surveillance complète de l'infrastructure :

**Action** : Intégrer AWS CloudWatch, AWS Signaux d'applications (APM, ex XRay) à tous les environnements, en commençant le plus tôt possible dans le pipeline de déploiement.

**Détails** : Collecter et stocker les données d'observabilité (journaux, métriques, télémétrie applicative, métriques de plateforme) pour analyser l'intégrité, les performances et l'utilisation de l'infrastructure. Configurer des alertes et des tableaux de bord AWS CloudWatch. Envisager une surveillance distinctes pour la production (Équipe dédiée, developeurs PGF en appels, etc).

**Avantage** : Identification proactive des problèmes, analyse plus rapide des causes profondes et amélioration de l'excellence opérationnelle.

### 3. Amélioration continue et boucle de rétroaction :

**Action** : Mettre en place un processus d'évaluation régulier (par exemple, revues post-incident, rétrospectives de sprint) pour analyser les données de surveillance, les performances du pipeline et les résultats du déploiement.

**Détails** : Utiliser les informations issues de la surveillance, des déploiements échoués et des retours des équipes de développement et d'exploitation pour affiner en permanence les définitions IaC, les structures du pipeline.

**Avantage** : Favoriser une culture d'apprentissage et d'amélioration continus, renforçant ainsi l'agilité et la fiabilité de l'automatisation de l'infrastructure au fil du temps.

---

Cette feuille de route propose une approche progressive à fin d'adopter et faire évoluer l'automatisation de l'infrastructure à l'aide des principes DevOps et d'Azure Pipelines pour transformer les défis en opportunités et concrétiser les avantages documentés dans l'analyse préalable.

# Glossaire:

- demandes de tirage : Pull request
- infrastructure en tant que code (IaC) : Infrastructure as Code (IaC)
- contrôles d'accès basés sur les rôles (RBAC) : Role-Based Access Control (RBAC)
- principes DevOps : DevOps principles
- déploiements de production : production deployments
- environnements hors production : non-production environments
- tests d'acceptation : acceptance tests
- surveillance complète : comprehensive monitoring
- automatisation de l'infrastructure : infrastructure automation
- pipelines CI/CD : CI/CD pipelines
- boucle de rétroaction : feedback loop
- amélioration continue : continuous improvement
- culture d'apprentissage : learning culture
