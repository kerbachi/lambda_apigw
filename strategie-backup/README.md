# Stratégie de sauvegarde (Backup) pour PGF

Le document suivant décrit la stratégie de sauvegrade pour la solution PGF. PGF est déployé en mode serverless avec des services AWS statiques et des services qui contiennet des données:

1. Objectif

- Garantir la résilience et la restauration fiable des données et du code de l’application PGF déployée sur AWS.

2. Périmètre:

- Composants stateless (config/infrastructure) et services contenant des données/code: RDS, S3, Lambda, Glue, Secrets Manager/SSM
- La stratégie comprend le déploiement dans le compte AWS du PGF et non pas des AWS clients (Payeurs)

## Gouvernance et responsabilités

### 1. Modèle multi-comptes

Les sauvegardes test, dev, prod seront sepéparés. Idéalement, les sauvegardes seront envoyé dans des compte AWS dédié pour backup (faisant partie de AWS Organizations).

### 2. Outil de backup

À précauniser l'outil standard AWS compatible avec les services AWS utilisé par PGF: AWS Backup comme planificateur central avec AWS Organizations Backup Policies (**À confirmer, car nécessite la coordination avec l'équipe architecte tactique CEI, Sinon, le cas échéant, utiliser AWS Backup configuré pour chaque compte AWS -lab, dev, prod-** ).

### 3. Séparation des résponsabilités

Équipe opérationnel Backup vs équipes applicatives; accès restreint aux coffres (least privilege).

### 4. Conformité et audit

- AWS Backup Audit Manager pour preuves de conformité.
- AWS Config/Drift detection de L.infrastructure et sa configuration peut être détecté par IaC.
- Utiliser **Vault Lock compliance** en prod

## Architecture de sauvegarde

- Coffres (Backup Vaults):

  - Un coffre par criticité (ex: lab, dev et prod), séparés par environnement et région.
  - Activer AWS Backup Vault Lock ( [idéalement en mode conformité pour prod](https://docs.aws.amazon.com/fr_fr/aws-backup/latest/devguide/vault-lock.html) ).

- Copies inter-comptes:

  - Le backup devrait [etre sauvegardé dans un autre compte AWS, et idéalement une autre région si c'est possible.

- Chiffrement:

  - KMS géré par le client (SSE-KMS) pour toutes les sauvegardes.
  - Clés KMS multi-régions (MRK) si restauration cross-region rapide requise.
  - Rotation et protection contre la suppression des clés.

- Observabilité:

  - Événements CloudWatch pour états des jobs (succès/échec) et alarmes.
  - Tableaux de bord de couverture (ressources protégées vs non protégées).

- Tests de restauration:

  - Utiliser les fonctionnalités de test de restauration d’AWS Backup lorsque disponibles.
  - Jeux de rôle (game days) trimestriels avec preuves (RTO/RPO mesurés).

## Stratégies de sauvegarde par service AWS

### Composants statiques

Composants ne contenant pas de données doivent être déployé avec un code IaC et automatisé par une pipeline, tel que décrit dans le document XXXX. Une tel automatisation permetrait de restaurer l'infra en cas d'incident, et de détecter, et eventuellement corriger, les changements effectués manuellements. Les composants cibles sont:

- EventBridge
- IAM
- API Gateway

### Composants contenant des données

Composant contenant des données nécessitant une étape supplémentaire pour sauvegarder les données qui ne peuvent pas être restauré avec le code IaC:

1. **RDS**

- Sauvegardes: AWS Backup comme orchestrateur (snapshots + journaux) avec point-in-time restauration continues (PITR).
- Copies: Inter-comptes (compte Backup) et inter-régions si possible.
- Chiffrement: \* _Si la copie sera inter-region_ \* l'utilisation de SSE-KMS nécessite une clés (Multi-Region Key) [MRK pour restauration cross-region](https://docs.aws.amazon.com/fr_fr/kms/latest/developerguide/multi-region-keys-overview.html).

- Bonnes pratiques:
  - Multi-AZ en production pour prod.
  - cahier d'exécution ( _Runbook_ ) de restauration (BD, paramètres, sécurité).
  - Tests de restauration périodiques sur environnements isolés.

2. **S3**

2.1. AWS Backup pour S3

Le backup de S3 est supporté par **AWS Backup**. La réplication de S3 est une solution potentielle, mais présente ces inconvénients:

- La réplication n’est pas une sauvegarde: elle réplique aussi les suppressions et écrasements; elle ne fournit pas de points de restauration immuables ni de rétention contrôlée. En cas d’erreur ou ransomware, l’erreur est simplement répliquée.

- AWS Backup crée des points de restauration (recovery points) dans des coffres dédiés (Backup Vaults) avec politiques de rétention, immutabilité via Vault Lock, et copies inter-comptes/inter-régions gérées. C’est centralisé, auditable (Backup Audit Manager) et cohérent avec les autres services (RDS, DynamoDB, etc.).

- Gouvernance/Conformité: politiques d’organisation (Organizations Backup Policies), tagging, preuves d’audit, séparation des rôles et du stockage (coffres) pour un modèle de moindre privilège.

  2.2 Protection de S3 avec AWS Backup (Pré-requis)

  - Activer Versioning sur les buckets critiques.
  - Chiffrement (SSE-KMS par défaut).
  - Bloquer l'accès publique, et appliquer S3 policy pour renforcer un accèes stricte au contenue du bucket S3.
  - Laisser juste les objects à sauvegrader dans le bucket, car AWS Backup, au moment d'écrire de ce document, ne supporte pas la sauvegarde séléctive d'objects à l'intérieur de S3

- Point à considérer ultérieurement pour optimiser les coûts:

  - Lifecycle: Transition vers Glacier/Deep pour archivage
  - Object Lock + Vault Lock.

3. **Lambda et Glue**

- Code:

  - Le code doit être sauvegardé dans Git, la pipeline CI/CD sert à déployer le code et permettre de restaurer la dernièere valide version.
  - Activer [versions](https://docs.aws.amazon.com/fr_fr/lambda/latest/dg/configuration-versions.html) et [aliases](https://docs.aws.amazon.com/fr_fr/lambda/latest/dg/configuration-aliases.html) Lambda; versionner les layers.
  - Sauvegarder les variables d’environnement sensibles dans [Secrets Manager](https://docs.aws.amazon.com/fr_fr/secretsmanager/latest/userguide/retrieving-secrets_lambda.html) / [SSM](https://docs.aws.amazon.com/fr_fr/systems-manager/latest/userguide/ps-integration-lambda-extensions.html) et éviter de les sauvegarder dans git.
  - **Pour Glue**: Mettre en place une exportation périodique du catalogue (API/Job) vers S3 versionné.

- Restauration:
  - Sera possible avec le re-déploiement via pipeline/IaC + réassociation des versions/aliases.

3. **QuickSight**

QuickSight étant un service managé BI, on ne “sauvegarde” pas des serveurs ou une base locale, mais les artefacts (dashboards, analyses, datasets, data sources, thèmes, dossiers) et leur configuration.

Méthode recommandée: **Asset Bundles** (export/import d’actifs): Exporter un bundle d’actifs (dashboards, analyses, datasets, data sources, thèmes, etc.) dans un fichier portable, puis l’importer pour restaurer ou cloner (dans le même compte, autre compte, ou autre région).

## Rétention et conformité

- Par environnement:

  - Lab/Dev: rétention réduite (ex. 7–14 jours).
  - Prod: rétention étendue selon tier (ex. 35–90 jours) + archives mensuelles/an.

- Conformité:

  - Vault Lock compliance en prod
  - Traçabilité via Backup Audit Manager.

## Organisation et automatisation

- Séparation des comptes test, dev et production avec des retentions différentes
- Rétention doit être configurée différement selon l'environnement
- Utilisation des balises (tags) pour automatiser la sauvegarde. Example de balises:
  - backup:enabled=true
  - backup:tier=lab|dev|prod
  - backup:retention_days=35|90
  - backup:copy_to_region=ca-central-1,ca-central-2
  - backup:copy_to_account=123456789012
  - data:classification=public|internal|confidential|restricted
  - application=pgf

## Opérations et runbooks

- Fenêtres de sauvegarde:

  - Planifier hors pics; coordonner avec maintenance DB.

- Runbooks:

  - Procédures pas-à-pas de restauration (RDS, S3, secrets, IaC).
  - Contacts, escalade, prérequis (KMS, réseaux, accès).

- Exercices:
  - Game days et restore testing trimestriels; stocker les preuves d’objectifs RTO/RPO.

## Idéale si c'est réalisable

- Créer des plans de backup multi-région
- Configurer des vaults séparés par criticité (Fichiers focus pré et post traitement par example)
- Appliquer AWS Backup Vault Lock pour la conformité

## Mile Stone

| Étape # | Ressource AWS | Description                                                                 |
| ------- | ------------- | --------------------------------------------------------------------------- |
| Étape 1 | AWS Backup    | Configuration de de AWS Backup (Plans de backup + ressources à sauvegarder) |
| Étape 2 | S3            | Préparer S3 et ajouter sauvegrade de S3                                     |
| Étape 3 | RDS           | Créer la sauvegarde de RDS                                                  |
| Étape 4 | QuickSight    | Créer des jeux d'Asset Bundle de QuickSight                                 |

## Liens:

- Sauvegarde S3: (https://docs.aws.amazon.com/aws-backup/latest/devguide/s3-backups.html
- Sauvegarde RDS: https://docs.aws.amazon.com/aws-backup/latest/devguide/rds-backup.html
- AWS Backup Vault: https://docs.aws.amazon.com/fr_fr/aws-backup/latest/devguide/vaults.html
- QuickSight Asset Bundle: https://docs.aws.amazon.com/fr_fr/quicksight/latest/developerguide/asset-bundle-ops.html
