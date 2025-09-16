# Plan d'action et feuille de route pour l'automatisation de l'infrastructure

## Phase 1 : Adoption des fondations et de l'IaC (mois 1 à 3)

Objectif : Établir les pratiques clés de l'infrastructure en tant que code et les pipelines CI/CD initiaux pour l'infrastructure.

1. Établir un référentiel d'infrastructure en tant que code (IaC) :

**Action** : Créer et configurer un référentiel Git Azure Repos dédié au stockage de toutes les définitions d'infrastructure. Ce référentiel constituera la source unique de référence pour notre infrastructure, offrant un contrôle de version et une plateforme pour les projets collaboratifs.

**Détails** : Tous les composants de l'infrastructure (par exemple, serveurs, réseaux, stockage, bases de données) seront définis à l'aide de fichiers de configuration lisibles par machine (par exemple, des modèles ARM) plutôt que de processus manuels.

**Avantage** : Garantit la cohérence, la répétabilité et le contrôle des versions des modifications d'infrastructure.

2. Mettre en œuvre des pipelines CI/CD de base pour l'IaC (Azure Pipelines) :

**Action** : Adopter Azure Pipelines comme outil principal pour créer, tester et publier le code de l'infrastructure. Commencez par un ensemble de pipelines fondamentaux.

**Détails** :

▪ Pipelines de demandes de tirage (PR) pour l'IaC : Implémentez des pipelines de demandes de tirage (PR) pour les modifications du code d'infrastructure. Ces pipelines exécuteront des contrôles qualité rapides, tels que le linting, l'analyse statique du code et l'analyse de sécurité des modèles IaC, afin de détecter les vulnérabilités en amont. En cas d'échec des contrôles, le développeur devra apporter des modifications avant la fusion des branches git.

▪ Pipelines d'intégration continue (CI) pour l'IaC : Implémentez des pipelines d'intégration continue (CI) déclenchés par les fusions vers la branche principale. Ces pipelines exécuteront une validation plus complète et publieront les artefacts IaC (par exemple, les build de react, le code lambda en zip, etc) si tous les contrôles sont concluants.

**Avantage** : Accélération des contrôles qualité initiaux et garantie de l'intégrité du code d'infrastructure avant le déploiement.

3. Intégration de l'analyse de sécurité pour l'IaC :

**Action** : Intégrez des outils d'analyse de sécurité directement dans les pipelines de demandes de tirage et d'intégration continue pour analyser automatiquement le code d'infrastructure à la recherche de vulnérabilités.

**Détails** : Cela doit inclure l’analyse des erreurs de configuration courantes ou des schémas non sécurisés dans les fichiers IaC.

**Avantage** : Déplacement de la sécurité vers la gauche, identifiant et corrigeant les risques de sécurité de l’infrastructure plus tôt dans le cycle de développement. 4. Adopter YAML pour les définitions de pipelines :
◦ Action : Définir tous les nouveaux pipelines d’infrastructure en YAML.
◦ Détails : Les pipelines YAML peuvent être vérifiés dans le contrôle de source et versionnés avec le code de l’infrastructure, favorisant ainsi le « pipeline as code ».
◦ Avantage : Améliore la transparence, l’auditabilité et la réutilisabilité des définitions de pipelines.

## Phase 2 : Standardisation de l’environnement et préproduction automatisée (mois 4 à 6)

Objectif : Automatiser le provisionnement et la gestion des environnements hors production grâce à IaC et DevTest Labs. 1. Automatisation du provisionnement de l'environnement DevTest (Azure DevTest Labs) :
◦ Action : Intégrer Azure DevTest Labs au processus CI/CD pour provisionner les environnements Windows et Linux à l'aide de modèles et d'artefacts réutilisables.
◦ Détails : Configurer les pipelines CD pour créer automatiquement les environnements DevTest Labs, y déployer l'IaC (par exemple, des modèles ARM) et effectuer toute configuration post-déploiement nécessaire dans le cadre du processus de publication.
◦ Avantage : Fournir des environnements de test économiques et facilement reproductibles, réduisant ainsi les efforts manuels et les dérives environnementales. 2. Implémentation de déploiements de test automatisés :
◦ Action : Étendre le pipeline CD pour automatiser le déploiement des modifications d'infrastructure validées dans un environnement de test (en particulier l'environnement DevTest Labs).
◦ Détails : Après le déploiement, exécuter des tests d'acceptation automatisés sur l'environnement de test afin de valider la configuration et le comportement de l'infrastructure. Une étape de validation manuelle peut être incluse ici avant de poursuivre.
◦ Avantage : Garantit que les modifications d’infrastructure sont rigoureusement testées dans un environnement proche de celui de production, réduisant ainsi les risques de publication. 3. Stratégie d’expansion de l’environnement :
◦ Action : Envisager la création et le déploiement d’environnements supplémentaires au-delà des environnements de préproduction et de production au sein du pipeline de livraison continue.
◦ Détails : Il peut s’agir d’environnements pour les tests d’acceptation utilisateur (UAT) manuels, les tests de performance et de charge, ou d’environnements de restauration dédiés.
◦ Avantage : Fournit des espaces dédiés aux différentes phases de test, améliorant ainsi la qualité et la résilience globales. 4. Optimisation des coûts pour les environnements hors production :
◦ Action : Mettre en œuvre les politiques et procédures Azure DevTest Labs afin de maîtriser les coûts des environnements hors production.
◦ Détails : Cela inclut la définition de planifications d’arrêt automatique, la limitation de la taille des machines virtuelles et la surveillance de l’utilisation des ressources afin d’éviter les dépenses inutiles. Évaluer la pré-création des environnements DevTest Labs pour la vitesse du pipeline et évaluer les implications financières.
◦ Avantage : Gérer efficacement les dépenses cloud pendant les phases de développement et de test.

## Phase 3 : Automatisation, surveillance et optimisation de la production (mois 7 à 12)

Objectif : Réaliser des déploiements de production entièrement automatisés, sécurisés et surveillés de l’infrastructure, avec un retour d’information et des améliorations continus.

1. Automatiser l’infrastructure de production

Déploiements d'infrastructure :
◦ Action : Configurer le pipeline de livraison continue pour déployer automatiquement la solution d'infrastructure validée en production, ou via une passerelle manuelle contrôlée.
◦ Détails : Mettre en œuvre des tests de détection de fuites en production après le déploiement afin de garantir le bon fonctionnement de l'infrastructure. En cas d'échec (annulation manuelle ou échec du test de détection de fuites), le pipeline doit permettre des retours automatiques à une version antérieure.
◦ Avantage : Permet des déploiements rapides et à faible risque des modifications d'infrastructure en production. 2. Mettre en œuvre une surveillance complète de l'infrastructure :
◦ Action : Intégrer Azure Monitor, Application Insights et l'espace de travail Azure Log Analytics à tous les environnements, en commençant le plus tôt possible dans le pipeline de déploiement.
◦ Détails : Collecter et stocker les données d'observabilité (journaux, métriques, télémétrie applicative, métriques de plateforme) pour analyser l'intégrité, les performances et l'utilisation de l'infrastructure. Configurer des alertes et des tableaux de bord. Envisager des ressources de surveillance distinctes pour la production.
◦ Avantage : Identification proactive des problèmes, analyse plus rapide des causes profondes et amélioration de l'excellence opérationnelle. 3. Améliorer la sécurité de l'IaC de production :
◦ Action : Renforcer les contrôles de sécurité pour toutes les modifications d'infrastructure.
◦ Détails : S'assurer que toutes les modifications apportées aux environnements de production sont strictement effectuées via des pipelines. Mettre en œuvre des contrôles d'accès basés sur les rôles (RBAC) selon le principe du moindre privilège pour les pipelines et l'accès humain aux environnements. Intégrer des étapes pour suivre les dépendances, gérer les licences, analyser les vulnérabilités et maintenir les dépendances à jour pour l'IaC.
◦ Avantage : Minimise les accès non autorisés et réduit les risques de sécurité dans les infrastructures de production critiques. 4. Optimiser les agents de pipeline :
◦ Action : Évaluer l'utilisation d'agents hébergés par Microsoft par rapport aux agents auto-hébergés pour l'exécution des tâches de pipeline.
◦ Détails : Les agents hébergés par Microsoft offrent des avantages en matière de sécurité. Les agents auto-hébergés peuvent être nécessaires pour les déploiements sur des ressources au sein de réseaux virtuels sécurisés ou pour optimiser les coûts liés à des volumes de build élevés.
◦ Avantage : Équilibre entre sécurité, connectivité et rentabilité pour l'exécution du pipeline. 5. Amélioration continue et boucle de rétroaction :
◦ Action : Mettre en place un processus d’évaluation régulier (par exemple, revues post-incident, rétrospectives de sprint) pour analyser les données de surveillance, les performances du pipeline et les résultats du déploiement.
◦ Détails : Utiliser les informations issues de la surveillance, des déploiements échoués et des retours des équipes de développement et d’exploitation pour affiner en permanence les définitions IaC, les structures du pipeline (par exemple, en utilisant des modèles YAML pour la réutilisation) et les processus globaux.
◦ Avantage : Favoriser une culture d’apprentissage et d’amélioration continus, renforçant ainsi l’agilité et la fiabilité de l’automatisation de l’infrastructure au fil du temps.

---

Cette feuille de route propose une approche progressive pour adopter et faire évoluer systématiquement l’automatisation de l’infrastructure à l’aide des principes DevOps et d’Azure Pipelines, en relevant les principaux défis et en tirant parti des avantages mis en évidence dans les sources fournies.
