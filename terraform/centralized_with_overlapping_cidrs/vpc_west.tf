
#
# west VPC
#
module "vpc-west" {
  depends_on = [ module.vpc-transit-gateway.tgw_id ]
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-west-vpc"
  vpc_cidr                   = var.vpc_cidr_west
}
module "vpc-igw-west" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_igw"
  igw_name                   = "${var.cp}-${var.env}-west-igw"
  vpc_id                     = module.vpc-west.vpc_id
}

module "subnet-west-private" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-west-private-subnet"

  vpc_id                     = module.vpc-west.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_west_private
}

module "subnet-west-public" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-west-public-subnet"

  vpc_id                     = module.vpc-west.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_west_public
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_west" {
  default_route_table_id = module.vpc-west.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc west (unused)"
  }
}

module "route-table-west-private" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-west-private-rt"

  vpc_id                     = module.vpc-west.vpc_id
}

module "route-table-association-west-private" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-west-private.id
  route_table_id             = module.route-table-west-private.id
}

module "route-table-west-public" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-west-public-rt"

  vpc_id                     = module.vpc-west.vpc_id
}

module "route-table-association-west-public" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-west-public.id
  route_table_id             = module.route-table-west-public.id
}

resource "aws_route" "default-route-west-private" {
  depends_on             = [module.vpc-transit-gateway-attachment-west.tgw_attachment_id]
  route_table_id         = module.route-table-west-private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id         = module.vpc-transit-gateway.tgw_id
}

resource "aws_nat_gateway" "vpc-west" {
  subnet_id         = module.subnet-west-public.id
  connectivity_type = "private"
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-west"
  }
}
