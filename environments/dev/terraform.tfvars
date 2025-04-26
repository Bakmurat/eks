main_project_name   = "studentgroup"
region              = "us-west-2"

main_vpc_cidr_block = "10.1.0.0/16"
main_pub_subnets_cidr = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
main_priv_subnets_cidr = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
main_pub_subs_az = ["us-west-2a", "us-west-2b", "us-west-2c"]
main_priv_subs_az = ["us-west-2a", "us-west-2b", "us-west-2c"]

main_ip_protocol = "-1"
main_cidr_ipv4  = "0.0.0.0/0" # IPv4 CIDR block
main_cidr_ipv6  = "::/0" # IPv6 CIDR block

main_cluster_version = "1.31"
main_service_ipv4_cidr = "10.1.21.0/23"