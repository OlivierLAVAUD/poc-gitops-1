#!/bin/bash
set -e

echo "🚀 Installation de Minikube..."

# Vérification de Docker
if ! docker version >/dev/null 2>&1; then
    echo "❌ Docker n'est pas démarré"
    echo "💡 Démarrez Docker Desktop depuis Windows"
    exit 1
fi

# Installation de Minikube
if ! command -v minikube >/dev/null 2>&1; then
    echo "📥 Téléchargement de Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    echo "✅ Minikube installé"
else
    echo "✅ Minikube déjà installé"
fi

# Vérification de la version
echo "🔍 Version de Minikube:"
minikube version