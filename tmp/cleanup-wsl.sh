#!/bin/bash

echo "🧹 Nettoyage du POC GitOps-1 sur WSL..."

# Arrêt de K3s
echo "🛑 Arrêt de K3s..."
sudo pkill k3s 2>/dev/null || true
sleep 3

# Nettoyage manuel des ressources Kubernetes
echo "🔍 Nettoyage des ressources Kubernetes..."
kubectl delete namespace nginx-poc --ignore-not-found=true 2>/dev/null || true
kubectl delete namespace argocd --ignore-not-found=true 2>/dev/null || true

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

# Désinstallation de K3s si demandé
if [ "$1" == "--full" ]; then
    echo "🗑️ Désinstallation complète de K3s..."
    if [ -f "/usr/local/bin/k3s-uninstall.sh" ]; then
        sudo /usr/local/bin/k3s-uninstall.sh
    fi
fi

echo "✅ Nettoyage terminé !"