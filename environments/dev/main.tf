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

