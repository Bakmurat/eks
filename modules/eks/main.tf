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