variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "pub_subnets_cidr" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "priv_subnets_cidr" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "pub_subs_az" {
  description = "The availability zones for the public subnets"
  type        = list(string)
}

variable "priv_subs_az" {
  description = "The availability zones for the private subnets"
  type        = list(string)
}