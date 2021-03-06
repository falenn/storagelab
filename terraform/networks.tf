# Create VPC in us-east-1
# When doing VPC pairing, they must have different CIDR blocks
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-k8s"
  }
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

# Get all available AZs in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

# Create subnet #1 in us-east-1
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}

# Create subnet #2 in us-east-1
resource "aws_subnet" "subnet_2" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
}

# Create the Route Table
resource "aws_route_table" "vpc_master_rt" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  tags = {
    Name = "storagelab k8s master VPC Route Table"
  }
}

# Create the Internet Access
resource "aws_route" "vpc_internet_access" {
  provider               = aws.region-master
  route_table_id         = aws_route_table.vpc_master_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "vpc_association" {
  provider       = aws.region-master
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.vpc_master_rt.id
}


