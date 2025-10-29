# POC-GitOps-1

Ce projet implémente une stack GitOps complète centrée sur Argo CD comme moteur de déploiement :

Le GitOps est un pattern opérationnel qui utilise Git comme source de vérité unique pour l'infrastructure et les applications. La configuration déclarative (Kubernetes manifests, Helm charts) versionnée dans Git est automatiquement synchronisée avec le cluster par un contrôleur (Argo CD, Flux) suivant un modèle pull-based. Ce contrôleur compare continuellement l'état désiré (Git) avec l'état actuel du cluster et applique les différences. Chaque commit devient un déploiement potentiel, garantissant idempotence, traçabilité et rollback immédiat via git revert. L'approche élimine les dérives de configuration et standardise les déploiements sur tous les environnements.

## 📋 Table des Matières

   - 🎯 Overview
   - 🏗️ Architecture
   - 📦 Stack Technologique
   - 🚀 Démarrage Rapide
   - 📁 Structure du Projet
   - 🔧 Utilisation
   - 📊 Monitoring et Accès
   - 🛠️ Dépannage
   - 🧹 Nettoyage
  

## 🎯 Vue d'ensemple

Ce POC (Proof of Concept) démontre une stack GitOps complète avec des outils 100% open source pour le déploiement automatisé d'applications sur Kubernetes.

- Orchestration	            |   Minikube	       | Apache 2.0	    Cluster Kubernetes local
- Infrastructure as Code    |	OpenTofu           | MPL 2.0	    Provisionnement déclaratif
- GitOps	                |   Argo CD	           | Apache 2.0	    Déploiement continu
- Configuration	            |   Kustomize	       | Apache 2.0	    Gestion des manifests K8s
- Application	            |   Nginx	           | BSD 2-Clause	Application exemple

## 🏗️ Architecture Technique
```bash
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   DÉVELOPPEUR   │ -> │     GIT REPO     │ -> │    ARGO CD      │
│                 │    │  (Source of Truth)│    │  (GitOps Engine)│
└─────────────────┘    └──────────────────┘    └─────────┬───────┘
                                                         │
                                                 ┌───────▼───────┐
                                                 │   MINIKUBE    │
                                                 │   CLUSTER     │
                                                 └───────────────┘
```

## 🛠️ Stack technique déployée

### Argo CD - Moteur GitOps principal qui :

    - Surveille le dépôt Git OlivierLAVAUD/poc-gitops-1
    - Synchronise automatiquement le cluster
    - Fournit l'interface de monitoring

### Kustomize - Gestion de configuration :
    - base/ : Configuration standard NGINX
    - overlays/production/ : Personnalisations environnementales
    - Gère les variations sans duplication de code

### OpenTofu - Automatisation de l'infrastructure :
    - Provisionne les prérequis Minikube
    - Déploie la bootstrap configuration Argo CD

### 🔄 Flux GitOps implémenté

    - Déclaration : Configuration dans applications/apps/nginx/
    - Versioning : Commit Git sur la branche main
    - Sync : Argo CD détecte et déploie automatiquement
    - Monitoring : Interface Argo CD pour visualisation

### 📊 Application exemple

NGINX sert d'application témoin avec :

    - Déployment avec health checks
    - Service NodePort (port 30080)
    - Resource limits définis
    - Namespace dédié (nginx-poc)

### 🚀 Bootstrap automatisé

Le fichier argocd-bootstrap.yaml crée l'application racine Argo CD qui pointe vers le dépôt, établissant ainsi la boucle GitOps fermée où tout changement Git déclenche un redeploiement automatique.

Cette implémentation démontre un pattern GitOps production-ready avec synchronisation automatique, auto-healing et rollback via Git.

## 🔧 Points techniques
###  Configuration Argo CD avancée

- Le fichier argocd-bootstrap.yaml inclut :
    - Synchronisation automatique avec auto-healing
    - Création automatique des namespaces
    - Politique de retry avec backoff exponentiel
    - Ignore des différences pour les champs générés par Kubernetes

### Sécurité et bonnes pratiques

    - Limites de ressources sur les conteneurs
    - Probes de santé (liveness et readiness)
    - Labels cohérents pour toutes les ressources
    - Gestion des secrets avec mot de passe généré automatiquement

### Automatisation robuste

Le script principal run-poc-minikube.sh :

    - Vérifie les prérequis
    - Gère les couleurs et logging
    - Inclut des mécanismes d'attente et de vérification
    - Fournit des informations d'accès détaillées

### 🚀 Processus de déploiement

    - Préparation : Installation et démarrage de Minikube
    - Infrastructure : Configuration avec OpenTofu
    - GitOps : Déploiement d'Argo CD
    - Bootstrap : Configuration de l'application via GitOps
    - Vérification : Attente et validation de la synchronisation

### 💡 Points forts

    - Complètement automatisé : Un seul script déploie toute la stack
    - Reproductible : Basé sur des outils standards et open source
    - Pédagogique : Documentation complète avec dépannage
    - Production-ready : Inclut les bonnes pratiques (health checks, resource limits)
    - Extensible : Structure claire pour ajouter d'autres applications

### 🔄 Flux GitOps implémenté

    - Le développeur pousse du code dans le dépôt Git
    - Argo CD détecte les changements
    - Synchronisation automatique vers le cluster
    - Auto-healing en cas de dérive de configuration

### 📊 Monitoring intégré

- Le projet inclut des commandes pour :
    - Accéder à l'interface Argo CD
    - Vérifier le statut des applications
    - Consulter les logs
    - Surveiller les ressources Kubernetes

Cette POC démontre efficacement les principes GitOps avec une implémentation propre et professionnelle, utilisant les meilleures pratiques de l'industrie.

## 🎉 References Techniques

- [Docker | Containerization platform](https://www.docker.com/)
- [Kubernetes(K8S) | Container orchestration](https://kubernetes.io/releases/download/) - for Production Usage
- [Minikube | Local Kubernetes cluster](https://minikube.sigs.k8s.io/docs/) - for Development Usage
- [Argo CD | GitOps continuous delivery ](https://argo-cd.readthedocs.io/en/stable/)
- [OpenTofu | Open Source Infrastructure as Code tool (Terraform alternative) ](https://opentofu.org/) - 
- [Kustomize | Kubernetes native configuration management](https://kustomize.io/)
- [curl | cmd line for data transfer with Urls](https://curl.se/)
- [gh (GitHub CLI) | GitHub command line interface](https://cli.github.com/)
- [jq | JSON processor](https://doc.ubuntu-fr.org/json_query)

## 📦 Structure

```text
poc-gitops-1/
├── 📁 infrastructure/                      # Configuration OpenTofu
│   ├── main.tf                             # Définition de l'infrastructure
│   └── argocd-bootstrap.yaml               # Application Argo CD bootstrap
├── 📁 applications/                        # Applications à déployer
│   └── 📁 apps/
│       └── 📁 nginx/
│           ├── 📁 base/                    # Configuration de base
│           │   ├── deployment.yaml
│           │   ├── service.yaml
│           │   └── kustomization.yaml
│           └── 📁 overlays/
│               └── 📁 production/          # Configuration production
│                   └── kustomization.yaml
├── 📁 scripts/                             # Scripts d'automatisation
│   ├── install-minikube.sh
│   ├── start-minikube.sh
│   ├── check-minikube.sh
│   ├── deploy-argocd-minikube.sh
│   └── cleanup-minikube.sh
├── 🚀 run-poc-minikube.sh      # Script principal
└── 📖 README.md
```
## 🚀 Démarrage Rapide
    Prérequis

    - Docker Desktop installé et démarré
    - WSL2 (si sur Windows)
    - 4GB de RAM minimum disponibles

### Utilisation
```bash
# 1. Rendez tous les scripts exécutables
chmod +x scripts/*.sh
chmod +x run-poc-minikube.sh

# Déployer tout le POC
./run-poc-minikube.sh

# Nettoyer l'environnement
./scripts/cleanup-minikube.sh

# Vérifier le statut
./scripts/check-minikube.sh

# Accéder à Argo CD
minikube service argocd-server -n argocd

# Accéder au dashboard Kubernetes
minikube dashboard
```

## 📊 Monitoring et Accès
### URLs d'Accès
```bash

# Argo CD UI
minikube service argocd-server -n argocd

# Application Nginx
minikube service nginx-poc-gitops-1 -n nginx-poc

# Dashboard Kubernetes
minikube dashboard
```
### Identifiants

    Argo CD :
        Utilisateur: admin / Mot de passe: (généré automatiquement)

### Vérification du Statut
```bash
# Applications Argo CD
kubectl get applications -n argocd

# Pods de l'application
kubectl get pods -n nginx-poc

# Statut de synchronisation
argocd app get nginx-poc-gitops-1
```

## 🛠️ Dépannage
### Problèmes Courants

- Minikube ne démarre pas :
```bash
# Vérifier Docker
docker version

# Redémarrer Minikube
minikube delete
minikube start
```

- Argo CD non accessible :
```bash
# Vérifier les pods Argo CD
kubectl get pods -n argocd

# Vérifier les logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

- Application non synchronisée :
```bash
# Forcer la synchronisation
argocd app sync nginx-poc-gitops-1

# Vérifier les ressources
kubectl get all -n nginx-poc
```

### Commandes de Diagnostic
```bash

# Statut complet du cluster
kubectl get all -A

# Logs d'Argo CD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Événements du namespace
kubectl get events -n nginx-poc --sort-by='.lastTimestamp
```

## 🧹 Nettoyage

### Nettoyage Complet
```bash
# Script de nettoyage
./scripts/cleanup-minikube.sh

# Suppression complète de Minikube
minikube delete

```
- Suppression Sélective
```bash
# Supprimer l'application
kubectl delete application nginx-poc-gitops-1 -n argocd

# Supprimer les namespaces
kubectl delete namespace nginx-poc argocd

# Arrêter Minikube
minikube stop
```


