resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "34.0.0"
  namespace  = "traefik"
  create_namespace = true

  values = [
    file("${path.module}/values/traefik.yaml")
  ]

}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.15.2"
  namespace  = "cert-manager"
  create_namespace = true

  values = [
    file("${path.module}/values/cert-manager/cert-manager.yaml")
  ]
}



resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.14.5"
  namespace  = "external-dns"
  create_namespace = true

  values = [
    file("${path.module}/values/external-dns.yaml")
  ]
}

resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "61.3.0"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/values/prometheus.yaml")
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "8.10.0"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/values/grafana.yaml")
  ]

  depends_on = [helm_release.prometheus]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.4.1"
  namespace  = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/values/argo-cd/argo-cd.yaml")
  ]
}