variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "The IDs of the subnets to use for the EKS cluster"
  type        = list(string)
}

variable "service_ipv4_cidr" {
  description = "The CIDR block for the Kubernetes service network"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "ip_protocol" {
  description = "The IP protocol to use for security group rules"
  type        = string
}

variable "cidr_ipv4" {
  description = "The CIDR block for IPv4"
  type        = string
}

variable "cidr_ipv6" {
  description = "The CIDR block for IPv6"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EKS worker nodes"
  type        = string
  default     = "t2.small"
}

variable "asg_desired_capacity" {
  description = "The desired capacity of the Auto Scaling group"
  type        = number
}

variable "asg_max_size" {
  description = "The maximum size of the Auto Scaling group"
  type        = number
}

variable "asg_min_size" {
  description = "The minimum size of the Auto Scaling group"
  type        = number
}

variable "on_demand_base_capacity" {
  description = "The percentage of on-demand instances above the base capacity"
  type        = number
}

variable "on_demand_percentage_above_base_capacity" {
  description = "The percentage of on-demand instances above the base capacity"
  type        = number
}

variable "spot_allocation_strategy" {
  description = "The allocation strategy for spot instances"
  type        = string
}