resource "aws_vpc_peering_connection" "peering" {
    count = var.is_peering_required ? 1 : 0 # peering connection will be created if the variable is_peering_required is true
    peer_vpc_id = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id : var.acceptor_vpc_id# acceptor VPC
    vpc_id = aws_vpc.main.id# requestor VPC
    auto_accept = var.acceptor_vpc_id == "" ? true : false
      tags =  merge(
    var.common_tags,
    var.vpc_peering_connection_tags,
    {
        Name = "${local.resource_name}" # expense-dev
    }
  )
}

# count is useful to control when resource is required
resource "aws_route" "public_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.public.id # selecting public route table 
  destination_cidr_block    = data.aws_vpc.default.cidr_block # selecting defualt vpc CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # peering[0] must be included because we are using count and count is a list
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.private.id # selecting public route table
  destination_cidr_block    = data.aws_vpc.default.cidr_block # selecting defualt vpc CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # peering[0] must be included because we are using count and count is a list
}

resource "aws_route" "database_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.database.id # selecting public route table 
  destination_cidr_block    = data.aws_vpc.default.cidr_block # selecting defualt vpc CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # peering[0] must be included because we are using count and count is a list
}

resource "aws_route" "default_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = data.aws_route_table.main.id # selecting default vpc route table 
  destination_cidr_block    = var.vpc_cidr # selecting expense vpc CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # peering[0] must be included because we are using count and count is a list
}