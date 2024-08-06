resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  create_namespace = false

  set {
    name  = "args"
    value = [
      "--kubelet-insecure-tls",
      "--kubelet-preferred-address-types=InternalIP"
    ]
  }

  depends_on = [module.eks_cluster]
}
