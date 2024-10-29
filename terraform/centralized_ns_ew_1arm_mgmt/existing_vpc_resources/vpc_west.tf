
#
# west VPC
#
module "vpc-west" {
  source      = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  depends_on  = [ module.vpc-transit-gateway.tgw_id ]
  count       = var.enable_build_existing_subnets ? 1 : 0
  vpc_name                   = "${var.cp}-${var.env}-west-vpc"
  vpc_cidr                   = var.vpc_cidr_west
}

module "subnet-west-private-az1" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count                      = var.enable_build_existing_subnets ? 1 : 0
  subnet_name                = "${var.cp}-${var.env}-west-private-az1-subnet"
  vpc_id                     = module.vpc-west[0].vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_west_private_az1
}
module "subnet-west-private-az2" {
  source            = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count             = var.enable_build_existing_subnets ? 1 : 0
  subnet_name       = "${var.cp}-${var.env}-west-private-az2-subnet"
  vpc_id            = module.vpc-west[0].vpc_id
  availability_zone = local.availability_zone_2
  subnet_cidr       = var.vpc_cidr_west_private_az2
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_west" {
  count                  = var.enable_build_existing_subnets ? 1 : 0
  default_route_table_id = module.vpc-west[0].vpc_main_route_table_id
  tags = {
    Name = "default table for vpc west (unused)"
  }
}

module "route-table-west-private-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_build_existing_subnets ? 1 : 0
  rt_name = "${var.cp}-${var.env}-west-private-rt-az1"
  vpc_id  = module.vpc-west[0].vpc_id
}

module "route-table-association-west-private-az1" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count                      = var.enable_build_existing_subnets ? 1 : 0
  subnet_ids                 = module.subnet-west-private-az1[0].id
  route_table_id             = module.route-table-west-private-az1[0].id
}

resource "aws_route" "default-route-west-private-az1" {
  depends_on             = [module.vpc-transit-gateway-attachment-west.tgw_attachment_id]
  count                  = var.enable_build_existing_subnets ? 1 : 0
  route_table_id         = module.route-table-west-private-az1[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}

module "route-table-west-private-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_build_existing_subnets ? 1 : 0
  rt_name = "${var.cp}-${var.env}-west-private-rt-az2"
  vpc_id  = module.vpc-west[0].vpc_id
}

module "route-table-association-west-private-az2" {
  source          = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count           = var.enable_build_existing_subnets ? 1 : 0
  subnet_ids      = module.subnet-west-private-az2[0].id
  route_table_id  = module.route-table-west-private-az2[0].id
}

resource "aws_route" "default-route-west-private-az2" {
  depends_on             = [module.vpc-transit-gateway-attachment-west.tgw_attachment_id]
  count                  = var.enable_build_existing_subnets ? 1 : 0
  route_table_id         = module.route-table-west-private-az2[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}
