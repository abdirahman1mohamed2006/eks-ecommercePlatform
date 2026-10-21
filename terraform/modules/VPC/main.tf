data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "eks-lab-vpc"
    Environment = "sandbox"
    Project     = "eks-advanced-lab"
    Owner       = "Mo"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "eks-lab-igw"
    Environment = "sandbox"
    Project     = "eks-advanced-lab"
    Owner       = "Mo"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = local.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name                     = "eks-lab-public-1"
    Environment              = "sandbox"
    Project                  = "eks-advanced-lab"
    Owner                    = "Mo"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = local.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name                     = "eks-lab-public-2"
    Environment              = "sandbox"
    Project                  = "eks-advanced-lab"
    Owner                    = "Mo"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = local.availability_zones[2]
  map_public_ip_on_launch = false

  tags = {
    Name                     = "eks-lab-public-3"
    Environment              = "sandbox"
    Project                  = "eks-advanced-lab"
    Owner                    = "Mo"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.availability_zones[0]

  tags = {
    Name                              = "eks-lab-private-1"
    Environment                       = "sandbox"
    Project                           = "eks-advanced-lab"
    Owner                             = "Mo"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.availability_zones[1]

  tags = {
    Name                              = "eks-lab-private-2"
    Environment                       = "sandbox"
    Project                           = "eks-advanced-lab"
    Owner                             = "Mo"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = local.availability_zones[2]

  tags = {
    Name                              = "eks-lab-private-3"
    Environment                       = "sandbox"
    Project                           = "eks-advanced-lab"
    Owner                             = "Mo"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "eks-lab-nat-eip"
    Environment = "sandbox"
    Project     = "eks-advanced-lab"
    Owner       = "Mo"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name        = "eks-lab-nat"
    Environment = "sandbox"
    Project     = "eks-advanced-lab"
    Owner       = "Mo"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "eks-lab-public-rt"
    Environment = "sandbox"
    Project     = "eks-advanced-lab"
    Owner       = "Mo"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "eks-lab-private-rt"
    Environment = "sandbox"
    Project     = "eks-advanced-lab"
    Owner       = "Mo"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.private_3.id
  route_table_id = aws_route_table.private.id
}