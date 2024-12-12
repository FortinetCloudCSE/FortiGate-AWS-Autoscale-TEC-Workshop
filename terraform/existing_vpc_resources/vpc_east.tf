
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

module "subnet-east-public-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count  = var.enable_build_existing_subnets ? 1 : 0

  subnet_name       = "${var.cp}-${var.env}-east-public-az1-subnet"
  vpc_id            = module.vpc-east[0].vpc_id
  availability_zone = local.availability_zone_1
  subnet_cidr       = var.vpc_cidr_east_public_az1
}
module "subnet-east-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count  = var.enable_build_existing_subnets ? 1 : 0

  subnet_name                = "${var.cp}-${var.env}-east-public-az2-subnet"

  vpc_id                     = module.vpc-east[0].vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = var.vpc_cidr_east_public_az2
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_east" {
  count                  = var.enable_build_existing_subnets ? 1 : 0
  default_route_table_id = module.vpc-east[0].vpc_main_route_table_id
  tags = {
    Name = "${var.cp}-${var.env}-east-vpc-main-route-table"
  }
}

resource "aws_route" "default-route-east-public" {
  depends_on             = [module.vpc-transit-gateway-attachment-east.tgw_attachment_id]
  count                  = var.enable_build_existing_subnets ? 1 : 0
  route_table_id         = module.vpc-east[0].vpc_main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}
resource "aws_route" "management-route-east-public" {
  count                  = var.enable_build_management_vpc ? 1 : 0
  route_table_id         = module.vpc-east[0].vpc_main_route_table_id
  destination_cidr_block = var.vpc_cidr_management
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}
resource "aws_ec2_transit_gateway_route" "route-east-default-tgw" {
  count                          = var.enable_build_existing_subnets ? 1 : 0
  depends_on                     = [module.vpc-transit-gateway-attachment-east]
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east[0].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.east[0].id
}


