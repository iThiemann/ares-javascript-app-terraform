
resource "kind_cluster" "dev" {
  name           = "dev-cluster"
  wait_for_ready = true
  node_image     = "kindest/node:v1.30.0"

  # ⬇️ THIS replaces the heredoc
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Expose API server for remote use
    networking {
      api_server_address = "0.0.0.0" # listen on all interfaces
      api_server_port    = 6443      # fixed port instead of random
    }

    # Control-plane node, port-mapped to host
    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 30080
        host_port      = 30080
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 3000
        host_port      = 3000
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 8080
        host_port      = 8080
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 8443
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }
    }

    # Optional: add workers
    # node {
    #   role = "worker"
    # }
  }
}

# --- ArgoCD namespace ---
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [kind_cluster.dev]
}

# --- ArgoCD Helm release ---
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  # pick a version that exists in the repo; you can update later
  version = "6.7.18"

  # make sure Terraform waits until it's really up
  timeout = 600
  wait    = true

  # Service type for the ArgoCD server
  # Option 1: keep ClusterIP and use port-forward (what you do now)
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Option 2: uncomment to expose as NodePort (then map via kind extraPortMappings)
  # set {
  #   name  = "server.service.type"
  #   value = "NodePort"
  # }
  # set {
  #   name  = "server.service.nodePortHttps"
  #   value = "30443"
  # }

  depends_on = [kubernetes_namespace.argocd]
}
