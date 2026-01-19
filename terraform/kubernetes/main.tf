# Wait for cluster to be active
resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# Configure kubectl context
resource "null_resource" "configure_kubectl" {
  depends_on = [null_resource.wait_for_cluster]

  provisioner "local-exec" {
    command = "aws --profile localstack eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
  }
}

# Kubernetes provider
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "--profile",
      "localstack",
      "eks",
      "get-token",
      "--cluster-name",
      var.cluster_name,
      "--region",
      var.region
    ]
  }
}

# Kubernetes Namespace
resource "kubernetes_namespace" "meowmesh" {
  depends_on = [null_resource.configure_kubectl]
  
  metadata {
    name = "meowmesh"
  }
}

# Kubernetes Deployment
resource "kubernetes_deployment" "meowmesh_cats" {
  depends_on = [kubernetes_namespace.meowmesh]

  metadata {
    name      = "meowmesh-deployment"
    namespace = kubernetes_namespace.meowmesh.metadata[0].name
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        app = "meowmesh"
      }
    }

    template {
      metadata {
        labels = {
          app = "meowmesh"
        }
      }

      spec {
        container {
          name  = "meowcat"
          image = var.docker_image
          
          port {
            container_port = 5000
          }

          env {
            name  = "CAT_LANGUAGE"
            value = "english"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# Service to expose the deployment
resource "kubernetes_service" "meowmesh_service" {
  depends_on = [kubernetes_deployment.meowmesh_cats]

  metadata {
    name      = "meowmesh-service"
    namespace = kubernetes_namespace.meowmesh.metadata[0].name
  }

  spec {
    selector = {
      app = "meowmesh"
    }

    port {
      port        = 80
      target_port = 5000
      node_port   = 30080
    }

    type = "NodePort"
  }
}
