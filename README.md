# POC-GitOps-1

Stack moderne 100% open source pour le déploiement d'applications avec GitOps

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
   - 📈 Prochaines Étapes


## 🎯 Overview

Ce POC (Proof of Concept) démontre une stack GitOps complète avec des outils 100% open source pour le déploiement automatisé d'applications sur Kubernetes.

Objectifs :

  -  ✅ Déployer une stack GitOps complète
  -  ✅ Automatiser les déploiements d'applications
  -  ✅ Utiliser des outils 100% open source
  -  ✅ Fournir une base solide pour la production

## 🏗️ Architecture
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

## 📦 Stack Technologique

- Orchestration	            |   Minikube	       | Apache 2.0	    Cluster Kubernetes local
- Infrastructure as Code    |	OpenTofu           | MPL 2.0	    Provisionnement déclaratif
- GitOps	                |   Argo CD	           | Apache 2.0	    Déploiement continu
- Configuration	            |   Kustomize	       | Apache 2.0	    Gestion des manifests K8s
- Application	            |   Nginx	           | BSD 2-Clause	Application exemple


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

## Structure

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


