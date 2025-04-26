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

# Attach policy for the EBS CSI add-on
resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
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

# Create a sg for the cluster
resource "aws_security_group" "eks-cluster-sg" {
  name   = "${var.project_name}-cluster-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-cluster-sg"
  }
}

# Allow any ingress traffic within its own sg
resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-cluster-self" {
  security_group_id            = aws_security_group.eks-cluster-sg.id
  referenced_security_group_id = aws_security_group.eks-cluster-sg.id
  ip_protocol                  = var.ip_protocol
}

# Allow any ingress traffic from the worker nodes' sg
resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-from-workers" {
  security_group_id            = aws_security_group.eks-cluster-sg.id
  referenced_security_group_id = aws_security_group.workers-sg.id
  ip_protocol                  = var.ip_protocol
}

# Allow any egress traffic for ipv4
resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv4-cluster" {
  security_group_id = aws_security_group.eks-cluster-sg.id
  cidr_ipv4         = var.cidr_ipv4
  ip_protocol       = var.ip_protocol # semantically equivalent to all ports
}

# Allow any egress traffic for ipv6
resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv6-cluster" {
  security_group_id = aws_security_group.eks-cluster-sg.id
  cidr_ipv6         = var.cidr_ipv6
  ip_protocol       = var.ip_protocol # semantically equivalent to all ports
}


# Define the security group for the worker nodes
resource "aws_security_group" "workers-sg" {
  name   = "${var.project_name}-workers-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-workers-sg"
  }
}

# Allow any ingress traffic within its own sg
resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-workers-self" {
  security_group_id            = aws_security_group.workers-sg.id
  referenced_security_group_id = aws_security_group.workers-sg.id
  ip_protocol                  = var.ip_protocol
}

# Allow any ingress traffic from the cluster's sg
resource "aws_vpc_security_group_ingress_rule" "allow-tls-ipv4-from-cluster" {
  security_group_id            = aws_security_group.workers-sg.id
  referenced_security_group_id = aws_security_group.eks-cluster-sg.id
  ip_protocol                  = var.ip_protocol
}

# Allow any egress traffic for ipv4
resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv4-workers" {
  security_group_id = aws_security_group.workers-sg.id
  cidr_ipv4         = var.cidr_ipv4
  ip_protocol       = var.ip_protocol # semantically equivalent to all ports
}

# Allow any egress traffic for ipv6
resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv6-workers" {
  security_group_id = aws_security_group.workers-sg.id
  cidr_ipv6         = var.cidr_ipv6
  ip_protocol       = var.ip_protocol # semantically equivalent to all ports
}

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