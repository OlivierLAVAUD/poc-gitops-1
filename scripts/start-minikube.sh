#!/bin/bash
set -e

echo "🚀 Démarrage de Minikube..."

# Arrêt de Minikube existant si nécessaire
echo "🛑 Arrêt de Minikube existant..."
minikube stop 2>/dev/null || true

# Démarrage de Minikube
echo "🔧 Démarrage du cluster Minikube..."
minikube start --driver=docker --memory=4096 --cpus=2

# Configuration de l'environnement Docker
echo "📝 Configuration de l'environnement Docker..."
eval $(minikube docker-env)

echo "✅ Minikube démarré avec succès!"