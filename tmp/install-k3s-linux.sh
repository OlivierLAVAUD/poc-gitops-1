#!/bin/bash
set -e

echo "🚀 Installation de K3s..."

# Vérifie si K3s est déjà installé
if command -v k3s >/dev/null 2>&1; then
    echo "✅ K3s est déjà installé"
    sudo systemctl start k3s >/dev/null 2>&1 || true
else
    echo "📥 Téléchargement et installation de K3s..."
    curl -sfL https://get.k3s.io | sh -
fi

# Attend que le service soit actif
echo "⏳ Attente du démarrage de K3s..."
for i in {1..30}; do
    if sudo systemctl is-active k3s >/dev/null 2>&1; then
        break
    fi
    echo "⏱️ Tentative $i/30..."
    sleep 5
done

# Configure kubectl
echo "📝 Configuration de kubectl..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Met à jour l'adresse IP
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "🌐 Configuration avec l'adresse IP: $IP_ADDRESS"
sed -i "s/127.0.0.1/$IP_ADDRESS/g" ~/.kube/config
sed -i "s/localhost/$IP_ADDRESS/g" ~/.kube/config

# Vérification finale
echo "🔍 Vérification du cluster..."
kubectl get nodes

echo "✅ K3s installé et configuré avec succès"