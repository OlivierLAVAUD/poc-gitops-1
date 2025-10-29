#!/bin/bash

echo "🔍 Diagnostic complet Kubernetes..."

echo "1. Vérification de Docker..."
docker version 2>/dev/null && echo "✅ Docker fonctionne" || echo "❌ Docker non accessible"

echo ""
echo "2. Fichiers de configuration kubectl:"
ls -la ~/.kube/ 2>/dev/null || echo "❌ Aucun dossier ~/.kube"
ls -la "/c/Users/$USER/.kube/" 2>/dev/null || echo "❌ Aucun dossier Windows .kube"

echo ""
echo "3. Contextes Kubernetes:"
kubectl config get-contexts 2>/dev/null || echo "❌ Impossible d'accéder aux contextes"

echo ""
echo "4. Test de connexion directe:"
kubectl get nodes 2>/dev/null && echo "✅ Cluster accessible" || echo "❌ Cluster inaccessible"

echo ""
echo "5. Variables d'environnement:"
echo "KUBECONFIG: $KUBECONFIG"
echo "PATH: $PATH"

echo ""
echo "💡 Solutions possibles:"
echo "1. Redémarrez Docker Desktop"
echo "2. Exécutez: ./scripts/setup-kubectl-config.sh"
echo "3. Vérifiez que Kubernetes est activé dans Docker Desktop Settings"