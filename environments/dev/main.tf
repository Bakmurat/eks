provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "studentgroup-terraform-state-file"
    key    = "dev/terraform.tfstate"
    region = var.region
  }
}

locals {
  environment = "dev"
  tag = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = var.main_project_name
  }
}

module "networking" {
  source         = "../../modules/networking"
  vpc_cidr_block = var.main_vpc_cidr_block
  project_name   = var.main_project_name
  pub_subnets_cidr = var.main_pub_subnets_cidr
  priv_subnets_cidr = var.main_priv_subnets_cidr
  pub_subs_az   = var.main_pub_subs_az
  priv_subs_az  = var.main_priv_subs_az
}

module "eks" {
  source = "../../modules/eks"
  project_name = var.main_project_name

  vpc_id = module.networking.fp-vpc-id
  subnet_ids = module.networking.fp-pub-subs-ids

  ip_protocol = var.main_ip_protocol
  cidr_ipv4 = var.main_cidr_ipv4
  cidr_ipv6 = var.main_cidr_ipv6

  cluster_version = var.main_cluster_version
  service_ipv4_cidr = var.main_service_ipv4_cidr

  instance_type                            = var.main_instance_type
  asg_desired_capacity                     = var.main_asg_desired_capacity
  asg_max_size                             = var.main_asg_max_size
  asg_min_size                             = var.main_asg_min_size
  on_demand_percentage_above_base_capacity = var.main_on_demand_percentage_above_base_capacity
  spot_allocation_strategy                 = var.main_spot_allocation_strategy
  on_demand_base_capacity                  = var.main_on_demand_base_capacity
}

