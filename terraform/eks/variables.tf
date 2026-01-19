variable "cluster_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
