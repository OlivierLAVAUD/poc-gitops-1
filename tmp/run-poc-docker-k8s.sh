#!/bin/bash
set -e

echo "🎯 Démarrage du POC GitOps Phase 1 - poc-gitops-1 (Docker Desktop)"
echo "📦 Stack: Docker Desktop Kubernetes + OpenTofu + Argo CD"

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

# 1. Vérification de Docker Kubernetes
log_step "1. Vérification de Docker Desktop Kubernetes..."
./scripts/check-docker-k8s.sh
log_info "Docker Kubernetes vérifié"

# 2. Installation de OpenTofu
log_step "2. Installation de OpenTofu..."
if ! command -v tofu &> /dev/null; then
    curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh
    sudo mv /tmp/tofu /usr/local/bin/tofu
    log_info "OpenTofu installé"
else
    log_info "OpenTofu déjà installé"
fi

# 3. Configuration avec OpenTofu
log_step "3. Configuration avec OpenTofu..."
cd infrastructure
tofu init
tofu apply -auto-approve
log_info "Configuration terminée"

# 4. Déploiement d'Argo CD
log_step "4. Déploiement d'Argo CD..."
cd ../scripts
./deploy-argocd.sh
log_info "Argo CD déployé"

# 5. Configuration de l'application dans Argo CD
log_step "5. Configuration de l'application GitOps..."
kubectl apply -f ../gitops-repo/infrastructure/argocd-bootstrap.yaml
log_info "Application bootstrap configurée"

# 6. Vérification finale
log_step "6. Vérification du déploiement..."
echo "⏳ Attente de la synchronisation Argo CD..."
sleep 60

log_info "Ressources déployées dans poc-gitops-1:"
echo "=== Applications Argo CD ==="
kubectl get applications -n argocd 2>/dev/null || echo "Aucune application trouvée"

echo "=== Pods nginx ==="
kubectl get pods -n nginx-poc 2>/dev/null || echo "Namespace nginx-poc non trouvé"

# Affichage des informations d'accès
log_step "🎉 POC GitOps-1 terminé avec succès avec Docker Desktop!"
log_warn "📋 Informations d'accès:"
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}' 2>/dev/null || echo "not-found")
NGINX_PORT=$(kubectl get svc nginx-poc-gitops-1 -n nginx-poc -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "not-found")

echo "Argo CD UI: https://localhost:${ARGOCD_PORT}"
echo "Application nginx: http://localhost:${NGINX_PORT}"
echo "Argo CD Admin Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d 2>/dev/null || echo "non disponible")"

log_warn "🔧 Commandes utiles:"
echo "Voir les logs Argo CD: kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server"
echo "Synchroniser manuellement: argocd app sync nginx-poc-gitops-1"
echo "Dashboard Kubernetes: kubectl proxy (puis http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)"