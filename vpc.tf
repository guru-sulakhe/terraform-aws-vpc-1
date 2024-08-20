# VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags, 
    {
        Name = local.resource_name
    }
  )
}
# IGW(Internet GateWay)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.resource_name
    }
  )
}

# Public Subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs) # first name is public[0],second name is public[1]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

# Private Subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs) # first name is private[0],second name is private[1]
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

# Database Subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs) # 2 subnets will be created
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}

# Elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id # public subnet is included for the NAT gateway 

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
        Name = "${local.resource_name}" # expense-dev
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw] # this is explicit dependency
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags =  merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.resource_name}-public" # expense-dev
    }
  )
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  tags =  merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.resource_name}-private" # expense-dev
    }
  )
}

# Database Route Table
resource "aws_route_table" "database" {
  vpc_id = "${aws_vpc.main.id}"

  tags =  merge(
    var.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.resource_name}-database" # expense-dev
    }
  )
}

# Public Route connecting to public route table with IGW connection
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

# Private Route connecting to private route table with NAT Gateway connection
resource "aws_route" "private_route_nat" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# Database Route connecting to public route table with NAT Gateway connection
resource "aws_route" "database_route_nat" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# public Route Table and Public Subnet Association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index) 
  route_table_id = aws_route_table.public.id
}

# private Route Table and Private Subnet Association
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

# database Route Table and Database Subnet Association
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

# Database subnet group
resource "aws_db_subnet_group" "default"{
  name = "${local.resource_name}"
  subnet_ids = "aws_subnet.database[*].id"
  tags = merge(
    var.common_tags,
    var.database_subnet_group_tags,
    {
      Name = "${local.resource_name}"
    }
  )
}