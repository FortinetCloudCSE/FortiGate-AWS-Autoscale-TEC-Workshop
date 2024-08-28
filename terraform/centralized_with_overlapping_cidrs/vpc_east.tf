
#
# east VPC
#
module "vpc-east" {
  depends_on = [ module.vpc-transit-gateway.tgw_id ]
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-east-vpc"
  vpc_cidr                   = var.vpc_cidr_east

}
module "subnet-east-public" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-east-public-subnet"

  vpc_id                     = module.vpc-east.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_east_public
}

module "subnet-east-private" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-east-private-subnet"

  vpc_id                     = module.vpc-east.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_east_private
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_east" {
  default_route_table_id = module.vpc-east.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc east (unused)"
  }
}

module "route-table-east-private" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-east-private-rt"

  vpc_id                     = module.vpc-east.vpc_id
}

module "route-table-association-east-private" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-east-private.id
  route_table_id             = module.route-table-east-private.id
}

module "route-table-east-public" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-east-public-rt"

  vpc_id                     = module.vpc-east.vpc_id
}

module "route-table-association-east-public" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-east-public.id
  route_table_id             = module.route-table-east-public.id
}
#   transit_gateway_id     = module.vpc-transit-gateway.tgw_id
resource "aws_route" "default-route-east-private" {
  depends_on             = [module.vpc-transit-gateway-attachment-east.tgw_attachment_id]
  route_table_id         = module.route-table-east-private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}

resource "aws_nat_gateway" "vpc-east-nat-gw" {
  subnet_id         = module.subnet-east-public.id
  connectivity_type = "private"
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-east"
  }
}
