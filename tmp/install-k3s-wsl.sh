#!/bin/bash
set -e

echo "🚀 Installation de K3s pour WSL..."

# Vérifie si K3s est déjà installé
if command -v k3s >/dev/null 2>&1; then
    echo "✅ K3s est déjà installé"
else
    echo "📥 Téléchargement et installation de K3s..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=servicelb --disable=local-storage" sh -
fi

# Démarrage manuel de K3s (sans systemd)
echo "🔧 Démarrage manuel de K3s..."
sudo nohup k3s server --disable=traefik --disable=servicelb --disable=local-storage > /var/log/k3s.log 2>&1 &

# Attend que K3s soit prêt
echo "⏳ Attente du démarrage de K3s..."
for i in {1..30}; do
    if sudo k3s kubectl get nodes >/dev/null 2>&1; then
        break
    fi
    echo "⏱️ Tentative $i/30..."
    sleep 5
done

# Configure kubectl pour l'utilisateur
echo "📝 Configuration de kubectl..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Remplace localhost par l'adresse IP pour WSL
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "🌐 Configuration avec l'adresse IP: $IP_ADDRESS"
sed -i "s/127.0.0.1/$IP_ADDRESS/g" ~/.kube/config
sed -i "s/localhost/$IP_ADDRESS/g" ~/.kube/config

# Utilise k3s kubectl au lieu de kubectl directement pour la vérification
echo "🔍 Vérification du cluster..."
sudo k3s kubectl get nodes

echo "✅ K3s installé et configuré avec succès sur WSL"