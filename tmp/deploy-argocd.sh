#!/bin/bash
set -e

echo "🚀 Déploiement d'Argo CD..."

# Création du namespace argocd
echo "📁 Création du namespace argocd..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Installation d'Argo CD
echo "📥 Installation des composants Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attend que les pods soient prêts
echo "⏳ Attente du déploiement des pods Argo CD..."
for i in {1..30}; do
    if kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --no-headers 2>/dev/null | grep Running >/dev/null; then
        break
    fi
    echo "⏱️ Tentative $i/30..."
    sleep 10
done

# Exposition du service
echo "🔗 Exposition du service Argo CD..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}' >/dev/null 2>&1 || true

# Récupération des informations d'accès
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "password-not-available-yet")
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}' 2>/dev/null || echo "not-found")
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "✅ Argo CD déployé avec succès!"
echo "🌐 URL: https://$IP_ADDRESS:$ARGOCD_PORT"
echo "👤 Utilisateur: admin"
echo "🔑 Mot de passe: $ARGOCD_PASSWORD"
echo ""
echo "💡 Conseil: Attendez 1-2 minutes que tous les composants soient complètement initialisés"