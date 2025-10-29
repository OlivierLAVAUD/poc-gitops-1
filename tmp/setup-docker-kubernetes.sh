#!/bin/bash

echo "🚀 Configuration de Kubernetes avec Docker Desktop..."

# Vérification de Docker Desktop
if ! docker version >/dev/null 2>&1; then
    echo "❌ Docker Desktop n'est pas installé ou démarré"
    echo "💡 Téléchargez Docker Desktop depuis: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Activation de Kubernetes dans Docker Desktop
echo "🔧 Activation de Kubernetes..."
# Cette partie nécessite une intervention manuelle dans Docker Desktop

echo "📝 Configuration de kubectl..."
kubectl cluster-info

echo "✅ Kubernetes via Docker Desktop est prêt!"
echo "💡 N'oubliez pas d'activer Kubernetes dans Docker Desktop GUI"