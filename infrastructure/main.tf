terraform {
  required_version = ">= 1.0.0"

  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

resource "null_resource" "verify_minikube" {
  provisioner "local-exec" {
    command = "bash ${path.module}/../scripts/check-minikube.sh"
  }
}

resource "null_resource" "setup_complete" {
  depends_on = [null_resource.verify_minikube]

  provisioner "local-exec" {
    command = <<EOT
      echo "✅ Minikube est opérationnel!"
      echo "📋 Prêt pour le déploiement d'Argo CD"
    EOT
  }
}

output "minikube_info" {
  value = <<EOT
✅ Minikube configuré avec succès!

Commandes utiles :
- Accéder au dashboard : minikube dashboard
- Vérifier le statut : minikube status
- Arrêter Minikube : minikube stop

Prochaine étape : Déployer Argo CD
EOT
  depends_on = [null_resource.setup_complete]
}