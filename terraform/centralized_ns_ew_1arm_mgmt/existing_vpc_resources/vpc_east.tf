
locals {
    common_tags = {
    Environment = var.env
  }
}
provider "aws" {
  region     = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

locals {
  availability_zone_1 = "${var.aws_region}${var.availability_zone_1}"
}

locals {
  availability_zone_2 = "${var.aws_region}${var.availability_zone_2}"
}
#
# east VPC
#
module "vpc-east" {
  source     = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  count      = var.enable_build_existing_subnets ? 1 : 0
  depends_on = [ module.vpc-transit-gateway.tgw_id ]
  vpc_name   = "${var.cp}-${var.env}-east-vpc"
  vpc_cidr   = var.vpc_cidr_east

}

module "subnet-east-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count  = var.enable_build_existing_subnets ? 1 : 0

  subnet_name       = "${var.cp}-${var.env}-east-private-az1-subnet"
  vpc_id            = module.vpc-east[0].vpc_id
  availability_zone = local.availability_zone_1
  subnet_cidr       = var.vpc_cidr_east_private_az1
}
module "subnet-east-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count  = var.enable_build_existing_subnets ? 1 : 0

  subnet_name                = "${var.cp}-${var.env}-east-private-az2-subnet"

  vpc_id                     = module.vpc-east[0].vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = var.vpc_cidr_east_private_az2
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_east" {
  count                  = var.enable_build_existing_subnets ? 1 : 0
  default_route_table_id = module.vpc-east[0].vpc_main_route_table_id
  tags = {
    Name = "default table for vpc east (unused)"
  }
}

module "route-table-east-private-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_build_existing_subnets ? 1 : 0
  rt_name = "${var.cp}-${var.env}-east-private-rt-az1"
  vpc_id  = module.vpc-east[0].vpc_id
}

module "route-table-association-east-private-az1" {
  source          = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count           = var.enable_build_existing_subnets ? 1 : 0
  subnet_ids      = module.subnet-east-private-az1[0].id
  route_table_id  = module.route-table-east-private-az1[0].id
}

resource "aws_route" "default-route-east-private-az1" {
  depends_on             = [module.vpc-transit-gateway-attachment-east.tgw_attachment_id]
  count                  = var.enable_build_existing_subnets ? 1 : 0
  route_table_id         = module.route-table-east-private-az1[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}

module "route-table-east-private-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_build_existing_subnets ? 1 : 0
  rt_name = "${var.cp}-${var.env}-east-private-rt-az2"

  vpc_id  = module.vpc-east[0].vpc_id
}

module "route-table-association-east-private-az2" {
  source          = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count           = var.enable_build_existing_subnets ? 1 : 0
  subnet_ids      = module.subnet-east-private-az2[0].id
  route_table_id  = module.route-table-east-private-az2[0].id
}

resource "aws_route" "default-route-east-private-az2" {
  count                  = var.enable_build_existing_subnets ? 1 : 0
  depends_on             = [module.vpc-transit-gateway-attachment-east.tgw_attachment_id]
  route_table_id         = module.route-table-east-private-az2[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}

