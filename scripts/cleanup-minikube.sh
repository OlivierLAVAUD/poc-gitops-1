#!/bin/bash

echo "🧹 Nettoyage du POC GitOps-1 avec Minikube..."

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

# Arrêt de Minikube
echo "🛑 Arrêt de Minikube..."
minikube stop 2>/dev/null || true

echo "✅ Nettoyage terminé !"
echo "💡 Pour supprimer complètement: minikube delete"