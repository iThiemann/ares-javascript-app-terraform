
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
      api_server_address = "0.0.0.0"  # listen on all interfaces
      api_server_port    = 6443       # fixed port instead of random
    }

    # Control-plane node, port-mapped to host
    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 30080
        host_port      = 30080
        protocol       = "TCP"
      }
    }

    # Optional: add workers
    # node {
    #   role = "worker"
    # }
  }
}
