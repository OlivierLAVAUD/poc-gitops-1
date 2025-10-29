#!/bin/bash

echo "🔍 Vérification de Minikube..."

# Vérification du statut
echo "📊 Statut de Minikube:"
minikube status

# Vérification du cluster Kubernetes
echo "🔍 Vérification du cluster Kubernetes..."
kubectl cluster-info
kubectl get nodes

# Vérification des pods système
echo "🔍 Pods système:"
kubectl get pods -A

echo "✅ Minikube est opérationnel!"