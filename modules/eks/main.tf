data "aws_ssm_parameter" "eks_ami_id" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
}

# Define the assume role policy document
data "aws_iam_policy_document" "cluster-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-cluster-role" {
  name               = "${var.project_name}-eks-iam-role"
  assume_role_policy = data.aws_iam_policy_document.cluster-assume-role.json
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

data "aws_iam_policy_document" "worker-nodes-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "worker-nodes-role" {
  name               = "${var.project_name}-worker-nodes-iam-role"
  assume_role_policy = data.aws_iam_policy_document.worker-nodes-assume-role.json
}
# Attach the required policies to the worker role
resource "aws_iam_role_policy_attachment" "worker-nodes-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "cni-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "ecr-read-only-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "admin-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.worker-nodes-role.name
}

# Create a sg for the cluster
resource "aws_security_group" "eks-cluster-sg" {
  name   = "${var.project_name}-cluster-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-cluster-sg"
  }
}

# Allow all ingress traffic from anywhere (testing only)
resource "aws_vpc_security_group_ingress_rule" "allow_all_ingress_controlplane" {
  security_group_id = aws_security_group.eks-cluster-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols
}

# Allow all egress traffic to anywhere
resource "aws_vpc_security_group_egress_rule" "allow_all_egress_controlplane" {
  security_group_id = aws_security_group.eks-cluster-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols
}

# # Allow any ingress traffic within its own sg
# resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-cluster-self" {
#   security_group_id            = aws_security_group.eks-cluster-sg.id
#   referenced_security_group_id = aws_security_group.eks-cluster-sg.id
#   ip_protocol                  = var.ip_protocol
# }

# # Allow any ingress traffic from the worker nodes' sg
# resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-from-workers" {
#   security_group_id            = aws_security_group.eks-cluster-sg.id
#   referenced_security_group_id = aws_security_group.workers-sg.id
#   ip_protocol                  = var.ip_protocol
# }

# # Allow any egress traffic for ipv4
# resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv4-cluster" {
#   security_group_id = aws_security_group.eks-cluster-sg.id
#   cidr_ipv4         = var.cidr_ipv4
#   ip_protocol       = var.ip_protocol # semantically equivalent to all ports
# }

# # Allow any egress traffic for ipv6
# resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv6-cluster" {
#   security_group_id = aws_security_group.eks-cluster-sg.id
#   cidr_ipv6         = var.cidr_ipv6
#   ip_protocol       = var.ip_protocol # semantically equivalent to all ports
# }


# Define the security group for the worker nodes
resource "aws_security_group" "workers-sg" {
  name   = "${var.project_name}-workers-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-workers-sg"
  }
}

# Allow all ingress traffic from anywhere (testing only)
resource "aws_vpc_security_group_ingress_rule" "allow_all_ingress" {
  security_group_id = aws_security_group.workers-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols
}

# Allow all egress traffic to anywhere
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.workers-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols
}

# # Allow any ingress traffic within its own sg
# resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-workers-self" {
#   security_group_id            = aws_security_group.workers-sg.id
#   referenced_security_group_id = aws_security_group.workers-sg.id
#   ip_protocol                  = var.ip_protocol
# }

# # Allow any ingress traffic from the cluster's sg
# resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-from-cluster" {
#   security_group_id            = aws_security_group.workers-sg.id
#   referenced_security_group_id = aws_security_group.eks-cluster-sg.id
#   ip_protocol                  = var.ip_protocol
# }

# # Allow SSH from anywhere (for testing purposes, not for prod!)
# resource "aws_vpc_security_group_ingress_rule" "workers_ssh" {
#   security_group_id = aws_security_group.workers-sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 22
#   to_port           = 22
#   ip_protocol       = "tcp"
# }

# # Allow any egress traffic for ipv4
# resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv4-workers" {
#   security_group_id = aws_security_group.workers-sg.id
#   cidr_ipv4         = var.cidr_ipv4
#   ip_protocol       = var.ip_protocol # semantically equivalent to all ports
# }

# # Allow any egress traffic for ipv6
# resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv6-workers" {
#   security_group_id = aws_security_group.workers-sg.id
#   cidr_ipv6         = var.cidr_ipv6
#   ip_protocol       = var.ip_protocol # semantically equivalent to all ports
# }

resource "aws_eks_cluster" "fp-cluster" {
  name     = "${var.project_name}-main-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.eks-cluster-sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-role-AmazonEKSClusterPolicy
  ]

  tags = {
    Name = "${var.project_name}-main-cluster"
  }
}



resource "aws_iam_instance_profile" "workers-instance-profile" {
  name = "${var.project_name}-workers-instance-profile"
  role = aws_iam_role.worker-nodes-role.name
}

resource "aws_launch_template" "worker-nodes-lt" {
  name          = "${var.project_name}-worker-node-"
  image_id      = "ami-05c5c306e916eaf70"
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.workers-sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${aws_eks_cluster.fp-cluster.name}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-main-cluster-node"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.workers-instance-profile.name
  }

}


resource "aws_autoscaling_group" "eks_asg" {
  name                = "${var.project_name}-ASG"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                   = var.spot_allocation_strategy 
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.worker-nodes-lt.id
        version            = "$Latest"
      }
    }
  }

  capacity_rebalance = true

  tag {
    key                 = "Name"
    value               = "${var.project_name}-worker-node"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.fp-cluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }

}

resource "null_resource" "update_aws_auth" {
  depends_on = [aws_eks_cluster.fp-cluster]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name "${var.project_name}-main-cluster" --region ${data.aws_region.current.name}
      kubectl apply -f - <<EOF
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: aws-auth
        namespace: kube-system
      data:
        mapRoles: |
          - rolearn: ${aws_iam_role.worker-nodes-role.arn}
            username: system:node:{{EC2PrivateDNSName}}
            groups:
              - system:bootstrappers
              - system:nodes
          - rolearn: arn:aws:iam::123848992453:user/admin
            username: admin
            groups:
              - system:masters
      EOF
    EOT
  }
}