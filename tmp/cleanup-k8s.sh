#!/bin/bash

echo "🧹 Nettoyage du POC GitOps-1..."

# Nettoyage manuel des ressources Kubernetes
echo "🔍 Nettoyage des ressources Kubernetes..."
kubectl delete namespace nginx-poc --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true
kubectl delete pvc -A --all --ignore-not-found=true

# Si infrastructure existe, on tente de destroy
if [ -d "infrastructure" ]; then
    echo "🗑️ Suppression de l'infrastructure avec OpenTofu..."
    cd infrastructure
    tofu destroy -auto-approve 2>/dev/null || true
    cd ..
fi

# Réinitialisation de kubeconfig
echo "🔄 Réinitialisation de la configuration kubectl..."
rm -f ~/.kube/config

# Arrêt de K3s si installé
if command -v k3s >/dev/null 2>&1; then
    echo "🛑 Arrêt de K3s..."
    sudo k3s-uninstall.sh 2>/dev/null || true
fi

echo "✅ Nettoyage terminé !"