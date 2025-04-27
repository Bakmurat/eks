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

variable "main_ip_protocol" {
  description = "The IP protocol to use for security group rules"
  type        = string
  default     = "-1" # All protocols
}

variable "main_cidr_ipv4" {
  description = "The CIDR block for IPv4"
  type        = string
}

variable "main_cidr_ipv6" {
  description = "The CIDR block for IPv6"
  type        = string
}

variable "main_service_ipv4_cidr" {
  description = "The CIDR block for the Kubernetes service network"
  type        = string
}

variable "main_cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
}

variable "main_instance_type" {
  description = "The instance type for the EKS worker nodes"
  type        = string
  default     = "t2.small"
}

variable "main_asg_desired_capacity" {
  description = "The desired capacity of the Auto Scaling group"
  type        = number
}

variable "main_asg_max_size" {
  description = "The maximum size of the Auto Scaling group"
  type        = number
}

variable "main_asg_min_size" {
  description = "The minimum size of the Auto Scaling group"
  type        = number
}

variable "main_on_demand_base_capacity" {
  description = "The percentage of on-demand instances above the base capacity"
  type        = number
}

variable "main_on_demand_percentage_above_base_capacity" {
  description = "The percentage of on-demand instances above the base capacity"
  type        = number
}

variable "main_spot_allocation_strategy" {
  description = "The allocation strategy for spot instances"
  type        = string
}