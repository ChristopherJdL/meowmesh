terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Declare the global_variables module
module "global_variables" {
  source = "./global_variables"
}

module "network" {
  source = "./network"
  cluster_name = module.global_variables.cluster_name
  region       = module.global_variables.region
}

module "iam" {
  source = "./iam"
  cluster_name = module.global_variables.cluster_name
}

provider "aws" {
  profile                     = "localstack"
  region                      = module.global_variables.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    eks = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

module "eks" {
  source = "./eks"
  cluster_name = module.global_variables.cluster_name
  role_arn      = module.iam.eks_cluster_role_arn
  subnet_ids    = module.network.public_subnet_ids

  depends_on = [module.iam, module.network]
}

module "kubernetes" {
  source = "./kubernetes"
  cluster_name     = module.global_variables.cluster_name
  region           = module.global_variables.region
  docker_image     = module.global_variables.docker_image
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_ca_data

}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "service_url" {
  description = "URL to access MeowMesh service"
  value       = "http://localhost:30080"
}
