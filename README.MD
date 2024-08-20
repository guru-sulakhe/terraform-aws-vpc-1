# Custom AWS VPC module
 This module is developed for joindevops.com

 We are creating the following resources. This module is creates resources in first 2 availability zones for HA.

 * vpc
 * internet gateway(igw)
 * internet and vpc attachment
 * 2 public subnets
 * 2 private subnets
 * 2 database subnets
 * EIP(Elastic IP)
 * nat gateway(nat)
 * public route table
 * private route table
 * database route table
 * route table associations with subnets
 * routes in all tables
 * peering if required for the user
 * routes of peering requestor and acceptor VPC
 * database sunet group


 ## Inputs ##
 * project_name(Req) : user should mention there project name. Type is string
 * environment(opt) : default value is dev and Type is string
 * common_tags(Req) : user should provide their tags related to the project. Type is map
 * vpc_cidr(Opt) : default value is 10.0.0.0/16. Type is string
 * enable_dns_hostnames(Opt) : default value is true. Type is bool
 * vpc_tags(Opt) : default value is empty. Type is map
 * igw_tags(Opt) : default value is empty. Type is map
 * public_subnet_cidrs(Req) : user has to provide 2 valid subnets CIDRS
 * public_subnet_cidrs_tags(Opt) : default value is empty. Type is map
 * private_subnet_cidrs(Req) : user has to provide 2 valid subnets CIDRS
 * private_subnet_cidrs_tags(Opt) : default value is empty. Type is map
 * database_subnet_cidrs(Req) : user has to provide 2 valid subnets CIDRS
 * database_subnet_cidrs_tags(Opt) : default value is empty. Type is map
 * database_subnet_group_tags(Opt) : default value is empty. Type is map
 * nat_gateway_tags(Opt) : default value is empty. Type is map
 * public_route_table_tags(Opt): default value is empty. Type is map
 * private_route_table_tags(Opt): default value is empty. Type is map
 * database_route_table_tags(Opt): default value is empty. Type is map
 * is_peering_required(Opt) : default value is false. Type is map
 * acceptor_vpc_id(Opt) : default value is empty, default VPC ID would be taken
 * vpc_peering_connection_tags(Opt) : defualt value is empty. Type is map

 ## Outputs ##