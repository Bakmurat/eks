variable "region" {
  description = "The AWS region to deploy the EKS cluster"
  type        = string
  default     = "us-west-2"
}

variable "main_project_name" {
  description = "The name of the project"
  type        = string
  default     = "StudentGroup"
}

variable "main_vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}