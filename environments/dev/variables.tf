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

variable "main_pub_subnets_cidr" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "main_priv_subnets_cidr" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "main_pub_subs_az" {
  description = "The availability zones for the public subnets"
  type        = list(string)
}

variable "main_priv_subs_az" {
  description = "The availability zones for the private subnets"
  type        = list(string)
}