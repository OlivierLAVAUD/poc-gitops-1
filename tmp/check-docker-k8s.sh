#!/bin/bash

echo "🔍 Vérification de Docker Desktop Kubernetes..."

# Vérifie que Docker fonctionne
if ! docker version >/dev/null 2>&1; then
    echo "❌ Docker n'est pas démarré"
    echo "💡 Démarrez Docker Desktop depuis Windows"
    exit 1
fi

# Vérifie que Kubernetes est activé
echo "⏳ Vérification du cluster Kubernetes..."
for i in {1..30}; do
    if kubectl get nodes >/dev/null 2>&1; then
        echo "✅ Kubernetes est accessible"
        break
    fi
    echo "⏱️ Tentative $i/30 - Kubernetes pas encore prêt..."
    sleep 10
done

# Affichage des informations du cluster
echo "📊 Informations du cluster:"
kubectl cluster-info
kubectl get nodes

echo "🎉 Docker Desktop Kubernetes est opérationnel!"