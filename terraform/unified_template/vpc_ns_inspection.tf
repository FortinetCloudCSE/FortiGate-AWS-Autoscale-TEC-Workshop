
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
  rfc1918_192 = "192.168.0.0/16"
}
locals {
  rfc1918_10 = "10.0.0.0/8"
}
locals {
  rfc1918_172 = "172.16.0.0/12"
}
locals {
  availability_zone_1 = "${var.aws_region}${var.availability_zone_1}"
}

locals {
  availability_zone_2 = "${var.aws_region}${var.availability_zone_2}"
}
resource "random_string" "random" {
  length           = 5
  special          = false
}

data "aws_ec2_transit_gateway" "tgw" {
  filter {
    name   = "tag:Name"
    values = [var.attach_to_tgw_name]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc_endpoint" "asg_endpoint_az1" {
  depends_on = [module.spk_tgw_gwlb_asg_fgt_igw]
  filter {
    name   = "tag:Name"
    values = [var.ns_endpoint_name_az1]
  }
}

data "aws_vpc_endpoint" "asg_endpoint_az2" {
  depends_on = [module.spk_tgw_gwlb_asg_fgt_igw]
  filter {
    name   = "tag:Name"
    values = [var.ns_endpoint_name_az2]
  }
}

data "aws_route_table" "management_public_route_table_az1" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-management-public-rt-az1"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_route_table" "management_public_route_table_az2" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-management-public-rt-az2"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_internet_gateway" "management_igw_id" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-management-igw"]
  }
  filter {
    name   = "state"
    values = ["attached"]
  }
}

module "vpc-ns-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_inspection_vpc"
  vpc_name                         = "${var.cp}-${var.env}-inspection"
  vpc_cidr                         = var.vpc_cidr_ns_inspection
  subnet_bits                      = var.subnet_bits
  availability_zone_1              = local.availability_zone_1
  availability_zone_2              = local.availability_zone_2
  enable_nat_gateway               = var.enable_nat_gateway
  named_tgw                        = var.attach_to_tgw_name
  enable_tgw_attachment            = var.enable_tgw_attachment
}
#
# This is a bit bruce force. Route all the rfc-1918 space to the TGW. More specific route will handle the local traffic.
#

resource "aws_route" "gwlbe-192-route-igw-az1" {
  depends_on             = [module.vpc-ns-inspection, var.enable_tgw_attachment]
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az1_id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "gwlbe-192-route-igw-az2" {
  depends_on             = [module.vpc-ns-inspection]
  count                 = var.enable_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az2_id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "gwlbe-10-route-igw-az1" {
  depends_on             = [module.vpc-ns-inspection]
  count                  = var.enable_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az1_id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "gwlbe-10-route-igw-az2" {
  depends_on             = [module.vpc-ns-inspection]
  count                 = var.enable_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az2_id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "gwlbe-172-route-igw-az1" {
  depends_on             = [module.vpc-ns-inspection]
  count                  = var.enable_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az1_id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "gwlbe-172-route-igw-az2" {
  depends_on             = [module.vpc-ns-inspection]
  count                  = var.enable_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az2_id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}

#
# Routes for the route table. If nat gateway is enabled, make the default route go to the nat gateway.
# If not, make the default route go to the internet gateway.
#
resource "aws_route" "inspection-ns-public-default-route-ngw-az1" {
  depends_on             = [module.vpc-ns-inspection]
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az1_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc-ns-inspection.aws_nat_gateway_vpc_az1_id
}
resource "aws_route" "inspection-ns-public-default-route-ngw-az2" {
  depends_on             = [module.vpc-ns-inspection]
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.vpc-ns-inspection.route_table_gwlbe_az2_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc-ns-inspection.aws_nat_gateway_vpc_az2_id
}
resource "aws_route" "inspection-ns-public-default-route-igw-az1" {
  depends_on             = [module.vpc-ns-inspection]
  route_table_id         = module.vpc-ns-inspection.route_table_public_az1_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-ns-inspection.igw_id
}
resource "aws_route" "inspection-ns-public-default-route-igw-az2" {
  depends_on             = [module.vpc-ns-inspection]
  route_table_id         = module.vpc-ns-inspection.route_table_public_az2_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-ns-inspection.igw_id
}
resource "aws_route" "inspection-ns-private-default-route-gwlbe-az1" {
  depends_on             = [module.vpc-ns-inspection]
  route_table_id         = module.vpc-ns-inspection.route_table_private_az1_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az1.id
}
resource "aws_route" "inspection-ns-private-default-route-gwlbe-az2" {
  depends_on             = [module.vpc-ns-inspection]
  route_table_id         = module.vpc-ns-inspection.route_table_private_az2_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az2.id
}

#
# Routes for the route table.
#
resource "aws_route" "management-mgmt-public-default-route-igw-az1" {
  count                  = var.enable_dedicated_management_vpc ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az1[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.management_igw_id[0].id
}
resource "aws_route" "management-mgmt-public-default-route-igw-az2" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az2[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.management_igw_id[0].id
}
resource "aws_route" "inspection-mgmt-public-192-route-tgw-az1" {
  count                  = var.enable_dedicated_management_vpc && var.enable_tgw_attachment ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az1[0].id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-mgmt-public-10-route-tgw-az1" {
  count                  = var.enable_dedicated_management_vpc && var.enable_tgw_attachment ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az1[0].id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-mgmt-public-172-route-tgw-az1" {
  count                  = var.enable_dedicated_management_vpc && var.enable_tgw_attachment ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az1[0].id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}


resource "aws_route" "inspection-mgmt-public-192-route-tgw-az2" {
  count                  = var.enable_dedicated_management_vpc && var.enable_tgw_attachment ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az2[0].id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-mgmt-public-10-route-tgw-az2" {
  count                  = var.enable_dedicated_management_vpc && var.enable_tgw_attachment ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az2[0].id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-mgmt-public-172-route-tgw-az2" {
  count                  = var.enable_dedicated_management_vpc && var.enable_tgw_attachment ? 1 : 0
  route_table_id         = data.aws_route_table.management_public_route_table_az2[0].id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
