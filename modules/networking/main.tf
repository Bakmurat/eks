resource "aws_vpc" "fp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "fp-pub-sunbets" {
  count             = length(var.pub_subnets_cidr)
  vpc_id            = aws_vpc.fp-vpc.id
  cidr_block        = var.pub_subnets_cidr[count.index]
  availability_zone = var.pub_subs_az[count.index]

  tags = {
    Name = "${var.project_name}-pub-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "fp-priv-sunbets" {
  count             = length(var.priv_subnets_cidr)
  vpc_id            = aws_vpc.fp-vpc.id
  cidr_block        = var.priv_subnets_cidr[count.index]
  availability_zone = var.priv_subs_az[count.index]

  tags = {
    Name = "${var.project_name}-priv-subnet-${count.index + 1}"
  }
}