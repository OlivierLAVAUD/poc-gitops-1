#!/bin/bash

echo "🧹 Nettoyage du POC GitOps-1 avec Docker Desktop..."

# Nettoyage des ressources Kubernetes
echo "🔍 Nettoyage des ressources Kubernetes..."
kubectl delete namespace nginx-poc --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true
kubectl delete pvc -A --all --ignore-not-found=true

# Si infrastructure existe, on tente de destroy
if [ -d "infrastructure" ]; then
    echo "🗑️ Suppression de la configuration OpenTofu..."
    cd infrastructure
    tofu destroy -auto-approve 2>/dev/null || true
    cd ..
fi

echo "✅ Nettoyage terminé !"
echo "💡 Pour désactiver Kubernetes: Docker Desktop → Settings → Kubernetes → Uncheck 'Enable Kubernetes'"