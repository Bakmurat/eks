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

resource "aws_internet_gateway" "fp-igw" {
  vpc_id = aws_vpc.fp-vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "fp-pub-rt" {
  vpc_id = aws_vpc.fp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fp-igw.id
  }

  tags = {
    Name = "${var.project_name}-pub-rt"
  }
}

resource "aws_route_table" "fp-priv-rt" {
  vpc_id = aws_vpc.fp-vpc.id

  tags = {
    Name = "${var.project_name}-priv-rt"
  }
}

resource "aws_route_table_association" "fp-pub-subs-rt-association" {
  count          = length(var.pub_subnets_cidr)
  subnet_id      = aws_subnet.fp-pub-sunbets[count.index].id
  route_table_id = aws_route_table.fp-pub-rt.id
}

resource "aws_route_table_association" "fp-priv-subs-rt-association" {
  count          = length(var.priv_subnets_cidr)
  subnet_id      = aws_subnet.fp-priv-sunbets[count.index].id
  route_table_id = aws_route_table.fp-priv-rt.id
}