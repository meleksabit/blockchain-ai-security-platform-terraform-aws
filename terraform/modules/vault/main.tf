resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true

  set {
    name  = "server.dev.enabled"
    value = "true"
  }
  set {
    name  = "service.type"
    value = "NodePort"
  }
  set {
    name  = "service.nodePort"
    value = "32000"
  }
}

resource "null_resource" "vault_init" {
  depends_on = [helm_release.vault]

  provisioner "local-exec" {
    command = <<EOT
      kubectl port-forward -n vault svc/vault 8200:8200 --context $(kubectl config current-context) &
      sleep 5
      curl -H "X-Vault-Token: root" -X POST -d '{"data": {"api_key": "${var.infura_api_key}"}}' http://localhost:8200/v1/secret/data/infura
      pkill -f "kubectl port-forward"
    EOT
  }
}
