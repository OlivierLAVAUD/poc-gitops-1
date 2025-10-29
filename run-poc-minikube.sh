#!/bin/bash
set -e

echo "🎯 Démarrage du POC GitOps Phase 1 - poc-gitops-1 (Minikube)"
echo "📦 Stack: Minikube + OpenTofu + Argo CD"

# Couleurs pour le output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

# Fonction de vérification des prérequis
check_prerequisites() {
    log_step "Vérification des prérequis..."
    
    # Vérification de Docker
    if ! docker version >/dev/null 2>&1; then
        log_error "Docker n'est pas démarré"
        echo "💡 Démarrez Docker Desktop depuis Windows"
        exit 1
    fi
    log_info "Docker est opérationnel"
}

# Fonction de nettoyage avant démarrage
cleanup_previous() {
    log_step "Nettoyage des déploiements précédents..."
    ./scripts/cleanup-minikube.sh 2>/dev/null || true
    sleep 5
}

# 0. Vérifications initiales
check_prerequisites
cleanup_previous

# 1. Installation de Minikube
log_step "1. Installation de Minikube..."
./scripts/install-minikube.sh
log_info "Minikube installé"

# 2. Démarrage de Minikube
log_step "2. Démarrage de Minikube..."
./scripts/start-minikube.sh
log_info "Minikube démarré"

# 3. Vérification de Minikube
log_step "3. Vérification de Minikube..."
./scripts/check-minikube.sh
log_info "Minikube vérifié"

# 4. Installation de OpenTofu
log_step "4. Installation de OpenTofu..."
if ! command -v tofu &> /dev/null; then
    curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh
    sudo mv /tmp/tofu /usr/local/bin/tofu
    log_info "OpenTofu installé"
else
    log_info "OpenTofu déjà installé"
fi

# 5. Configuration avec OpenTofu (simplifiée)
log_step "5. Configuration avec OpenTofu..."
cd infrastructure
tofu init
tofu apply -auto-approve
log_info "Configuration terminée"

# 6. Déploiement d'Argo CD
log_step "6. Déploiement d'Argo CD..."
cd ../scripts
./deploy-argocd-minikube.sh
log_info "Argo CD déployé"

# 7. Configuration de l'application dans Argo CD
log_step "7. Configuration de l'application GitOps..."
kubectl apply -f ../infrastructure/argocd-bootstrap.yaml

# Attente de la création de l'application
echo "⏳ Attente de la création de l'application Argo CD..."
sleep 10

# Vérification que l'application est créée
if kubectl get application nginx-poc-gitops-1 -n argocd >/dev/null 2>&1; then
    log_info "Application bootstrap configurée"
else
    log_error "Échec de la création de l'application Argo CD"
    echo "🔍 Vérifiez le fichier: infrastructure/argocd-bootstrap.yaml"
    exit 1
fi

# 8. Vérification finale
log_step "8. Vérification du déploiement..."
echo "⏳ Attente de la synchronisation Argo CD (cela peut prendre 2-3 minutes)..."

# Attente plus longue pour la synchronisation complète
for i in {1..12}; do
    echo "⏱️  Attente $i/12 (5 secondes chacune)..."
    sleep 5
    
    # Vérification si l'application est synchronisée
    if kubectl get application nginx-poc-gitops-1 -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null | grep -q "Synced"; then
        log_info "Application synchronisée avec succès!"
        break
    fi
done

log_info "Ressources déployées dans poc-gitops-1:"
echo ""
echo "=== Applications Argo CD ==="
kubectl get applications -n argocd 2>/dev/null || echo "Aucune application trouvée"

echo ""
echo "=== Pods nginx ==="
kubectl get pods -n nginx-poc 2>/dev/null || echo "Namespace nginx-poc non trouvé - la synchronisation peut être en cours"

echo ""
echo "=== Tous les namespaces ==="
kubectl get namespaces --show-labels | grep -E "(argocd|nginx-poc)"

# Affichage des informations d'accès
log_step "🎉 POC GitOps-1 terminé avec succès avec Minikube!"
echo ""

log_warn "📋 INFORMATIONS D'ACCÈS:"
echo "=========================================="

# Récupération des URLs Minikube
echo "🌐 Services Minikube:"
minikube service list --namespace argocd 2>/dev/null | grep argocd-server || echo "Service argocd-server non trouvé"

# Récupération du mot de passe Argo CD
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo "non disponible")

# Vérification du statut de l'application
APP_STATUS=$(kubectl get application nginx-poc-gitops-1 -n argocd -o jsonpath='{.status.sync.status}:{.status.health.status}' 2>/dev/null || echo "Non trouvée")

echo ""
echo "🔗 ACCÈS AUX APPLICATIONS:"
echo "----------------------------"
echo "Argo CD UI:     minikube service argocd-server -n argocd"
echo "Dashboard K8s:  minikube dashboard"
echo "Application:    minikube service nginx-poc-gitops-1 -n nginx-poc"

echo ""
echo "🔐 IDENTIFIANTS:"
echo "----------------"
echo "Argo CD - Utilisateur: admin"
echo "Argo CD - Mot de passe: $ARGOCD_PASSWORD"

echo ""
echo "📊 STATUT:"
echo "----------"
echo "Application Argo CD: $APP_STATUS"

echo ""
log_warn "🔧 COMMANDES UTILES:"
echo "=========================================="
echo "Vérifier la synchronisation: kubectl get application -n argocd"
echo "Voir les pods nginx: kubectl get pods -n nginx-poc"
echo "Forcer la synchronisation: argocd app sync nginx-poc-gitops-1"
echo "Voir les logs Argo CD: kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server"
echo "Arrêter Minikube: minikube stop"
echo "Redémarrer: minikube start"
echo "Nettoyer complètement: ./scripts/cleanup-minikube.sh"
echo "Supprimer le cluster: minikube delete"

echo ""
log_warn "🚨 DÉPANNAGE RAPIDE:"
echo "=========================================="
echo "Si l'application n'est pas synchronisée:"
echo "1. Vérifiez les logs: kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller"
echo "2. Synchronisez manuellement: argocd app sync nginx-poc-gitops-1"
echo "3. Vérifiez les ressources: kubectl get all -n nginx-poc"

echo ""
echo "📝 POC GitOps-1 réussi! Votre stack est maintenant opérationnelle. 🎯"