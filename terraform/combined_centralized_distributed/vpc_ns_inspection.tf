
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
  subnet_index_addend = var.enable_tgw_attachment_subnet ? 4 : 3
}
locals {
  availability_zone_1 = "${var.aws_region}${var.availability_zone_1}"
}

locals {
  availability_zone_2 = "${var.aws_region}${var.availability_zone_2}"
}
locals {
  public_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.public_subnet_index)
}
locals {
  public_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.public_subnet_index + local.subnet_index_addend)
}
locals {
  gwlbe_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.gwlbe_subnet_index)
}
locals {
  gwlbe_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.gwlbe_subnet_index + local.subnet_index_addend)
}
locals {
  private_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.private_subnet_index)
}
locals {
  private_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.private_subnet_index + local.subnet_index_addend)
}
locals {
  tgw_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.tgw_subnet_index)
}
locals {
  tgw_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_ns_inspection, var.subnet_bits, var.tgw_subnet_index + local.subnet_index_addend)
}
locals {
  tgw_attachment_subnet_ids = var.enable_tgw_attachment_subnet ? [ module.subnet-ns-inspection-tgw-az1[0].id, module.subnet-ns-inspection-tgw-az2[0].id] : [ module.subnet-ns-inspection-private-az1.id, module.subnet-ns-inspection-private-az2.id]
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
    values = [var.endpoint_name_az1]
  }
}

data "aws_vpc_endpoint" "asg_endpoint_az2" {
  depends_on = [module.spk_tgw_gwlb_asg_fgt_igw]
  filter {
    name   = "tag:Name"
    values = [var.endpoint_name_az2]
  }
}

#
# Spoke VPC
#
module "vpc-ns-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-ns-inspection-vpc"
  vpc_cidr                   = var.vpc_cidr_ns_inspection
}

module "vpc-igw-ns-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_igw"
  igw_name                   = "${var.cp}-${var.env}-ns-inspection-igw"
  vpc_id                     = module.vpc-ns-inspection.vpc_id
}


resource "aws_eip" "nat-gateway-ns-inspection-az1" {
  count = var.enable_nat_gateway ? 1 : 0
}

resource "aws_eip" "nat-gateway-ns-inspection-az2" {
  count = var.enable_nat_gateway ? 1 : 0
}

resource "aws_nat_gateway" "vpc-ns-inspection-az1" {
  count             = var.enable_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat-gateway-ns-inspection-az1[0].id
  subnet_id         = module.subnet-ns-inspection-public-az1.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-east-az1"
  }
}

resource "aws_nat_gateway" "vpc-ns-inspection-az2" {
  count             = var.enable_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat-gateway-ns-inspection-az2[0].id
  subnet_id         = module.subnet-ns-inspection-public-az2.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-east-az2"
  }
}

module "ns-igw-route-table" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ns-igw-rt"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}
resource "aws_route_table_association" "b" {
  gateway_id     = module.vpc-igw-ns-inspection.igw_id
  route_table_id = module.ns-igw-route-table.id
}

#
# AZ 1
#
module "subnet-ns-inspection-public-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ns-inspection-public-az1-subnet"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.public_subnet_cidr_az1
}

module "subnet-ns-inspection-gwlbe-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ns-inspection-gwlbe-az1-subnet"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.gwlbe_subnet_cidr_az1
}


module "subnet-ns-inspection-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ns-inspection-private-az1-subnet"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.private_subnet_cidr_az1
}

module "inspection-private-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ns-inspection-private-rt-az1"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}
module "inspection-private-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-ns-inspection-private-az1.id
  route_table_id             = module.inspection-private-route-table-az1.id
}
module "inspection-gwlbe-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ns-inspection-gwlbe-rt-az1"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}
module "gwlbe-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-ns-inspection-gwlbe-az1.id
  route_table_id             = module.inspection-gwlbe-route-table-az1.id
}
module "subnet-ns-inspection-tgw-az1" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_name                = "${var.cp}-${var.env}-inspection-tgw-subnet-az1"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.tgw_subnet_cidr_az1
}

module "inspection-tgw-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_tgw_attachment_subnet ? 1 : 0
  rt_name = "${var.cp}-${var.env}-ns-inspection-tgw-rt-az1"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}
module "inspection-tgw-route-table-association-az1" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_ids                 = module.subnet-ns-inspection-tgw-az1[0].id
  route_table_id             = module.inspection-tgw-route-table-az1[0].id
}

#
# Security VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-ns-inspection" {
  source                         = "git::https://github.com/40netse/terraform-modules.git//aws_tgw_attachment"
  count                          = var.enable_tgw_attachment  ? 1 : 0
  tgw_attachment_name            = "${var.cp}-${var.env}-ns-inspection-tgw-attachment"

  transit_gateway_id                              = data.aws_ec2_transit_gateway.tgw.id
  subnet_ids                                      = local.tgw_attachment_subnet_ids
  transit_gateway_default_route_table_propogation = "true"
  appliance_mode_support                          = "enable"
  vpc_id                                          = module.vpc-ns-inspection.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "inspection" {
  count                           = var.enable_tgw_attachment ? 1 : 0
  transit_gateway_id              = data.aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.cp}-${var.env}-NS Inspection VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  count                          = var.enable_tgw_attachment ? 1 : 0
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-ns-inspection[0].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection[0].id
}
#
# AZ 2
#
module "subnet-ns-inspection-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ns-inspection-public-az2-subnet"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.public_subnet_cidr_az2
}

module "subnet-ns-inspection-gwlbe-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ns-inspection-gwlbe-az2-subnet"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.gwlbe_subnet_cidr_az2
}

module "subnet-ns-inspection-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ns-inspection-private-az2-subnet"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.private_subnet_cidr_az2
}
module "inspection-public-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ns-inspection-public-rt-az1"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}

module "inspection-public-route-table_association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-ns-inspection-public-az1.id
  route_table_id             = module.inspection-public-route-table-az1.id
}

module "inspection-public-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ns-inspection-public-rt-az2"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}

module "inspection-public-route-table_association-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-ns-inspection-public-az2.id
  route_table_id             = module.inspection-public-route-table-az2.id
}

module "inspection-private-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ns-inspection-private-rt-az2"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}

module "inspection-private-route-table-az2-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-ns-inspection-private-az2.id
  route_table_id             = module.inspection-private-route-table-az2.id
}
module "inspection-gwlbe-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ns-inspection-gwlbe-rt-az2"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}
module "inspection-gwlbe-route-table-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-ns-inspection-gwlbe-az2.id
  route_table_id             = module.inspection-gwlbe-route-table-az2.id
}

module "subnet-ns-inspection-tgw-az2" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_name                = "${var.cp}-${var.env}-inspection-tgw-subnet-az2"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.tgw_subnet_cidr_az2
}

module "inspection-tgw-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_tgw_attachment_subnet ? 1 : 0
  rt_name = "${var.cp}-${var.env}-ns-inspection-tgw-rt-az2"

  vpc_id                     = module.vpc-ns-inspection.vpc_id
}
module "inspection-tgw-route-table-association-az2" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_ids                 = module.subnet-ns-inspection-tgw-az2[0].id
  route_table_id             = module.inspection-tgw-route-table-az2[0].id
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_inspection" {
  default_route_table_id = module.vpc-ns-inspection.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc inspection (unused)"
  }
}
#
# Routes for the route table. If nat gateway is enabled, make the default route go to the nat gateway.
# If not, make the default route go to the internet gateway.
#
resource "aws_route" "inspection-ns-public-default-route-ngw-az1" {
  depends_on             = [aws_nat_gateway.vpc-ns-inspection-az1]
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-public-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-ns-inspection-az1[0].id
}
resource "aws_route" "inspection-ns-public-default-route-ngw-az2" {
  depends_on              = [aws_nat_gateway.vpc-ns-inspection-az2]
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-public-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-ns-inspection-az2[0].id
}
resource "aws_route" "inspection-ns-public-default-route-igw-az1" {
  depends_on             = [module.vpc-igw-ns-inspection]
  count                  = !var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-public-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-ns-inspection.igw_id
}
resource "aws_route" "inspection-ns-public-default-route-igw-az2" {
  depends_on             = [module.vpc-igw-ns-inspection]
  count                  = !var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-public-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-ns-inspection.igw_id
}
#
# This is a bit bruce force. Route all the rfc-1918 space to the TGW. More specific route will handle the local traffic.
#
resource "aws_route" "inspection-ns-public-192-route-igw-az1" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  route_table_id         = module.inspection-public-route-table-az1.id
  destination_cidr_block = local.rfc1918_192
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az1.id
}
resource "aws_route" "inspection-ns-public-192-route-igw-az2" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  route_table_id         = module.inspection-public-route-table-az2.id
  destination_cidr_block = local.rfc1918_192
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az2.id
}
resource "aws_route" "inspection-ns-public-10-route-igw-az1" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  route_table_id         = module.inspection-public-route-table-az1.id
  destination_cidr_block = local.rfc1918_10
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az1.id
}
resource "aws_route" "inspection-ns-public-10-route-igw-az2" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  route_table_id         = module.inspection-public-route-table-az2.id
  destination_cidr_block = local.rfc1918_10
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az2.id
}
resource "aws_route" "inspection-ns-public-172-route-igw-az1" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  route_table_id         = module.inspection-public-route-table-az1.id
  destination_cidr_block = local.rfc1918_172
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az1.id
}
resource "aws_route" "inspection-ns-public-172-route-igw-az2" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  route_table_id         = module.inspection-public-route-table-az2.id
  destination_cidr_block = local.rfc1918_172
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az2.id
}

#
# gwlbe subnet routes
#
# resource "aws_route" "inspection-ns-gwlbe-default-route-igw-az1" {
#   depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
#   route_table_id         = module.inspection-gwlbe-route-table-az1.id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "inspection-ns-gwlbe-default-route-igw-az2" {
#   depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
#   route_table_id         = module.inspection-gwlbe-route-table-az2.id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
# }
resource "aws_route" "inspection-ns-gwlbe-192-route-igw-az1" {
  depends_on             = [time_sleep.wait_5_minutes]
  route_table_id         = module.inspection-gwlbe-route-table-az1.id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ns-gwlbe-192-route-igw-az2" {
  depends_on             = [time_sleep.wait_5_minutes]
  route_table_id         = module.inspection-gwlbe-route-table-az2.id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ns-gwlbe-10-route-igw-az1" {
  depends_on             = [time_sleep.wait_5_minutes]
  route_table_id         = module.inspection-gwlbe-route-table-az1.id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ns-gwlbe-10-route-igw-az2" {
  depends_on             = [time_sleep.wait_5_minutes]
  route_table_id         = module.inspection-gwlbe-route-table-az2.id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ns-gwlbe-172-route-igw-az1" {
  depends_on             = [time_sleep.wait_5_minutes]
  route_table_id         = module.inspection-gwlbe-route-table-az1.id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ns-gwlbe-172-route-igw-az2" {
  depends_on             = [time_sleep.wait_5_minutes]
  route_table_id         = module.inspection-gwlbe-route-table-az2.id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "inspection-ns-tgw-default-route-endpoint-az1" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  count                  = var.enable_tgw_attachment_subnet  ? 1 : 0
  route_table_id         = module.inspection-tgw-route-table-az1[0].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az1.id
}
resource "aws_route" "inspection-ns-tgw-default-route-endpoint-az2" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  count                  = var.enable_tgw_attachment_subnet  ? 1 : 0
  route_table_id         = module.inspection-tgw-route-table-az2[0].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az2.id
}
resource "aws_route" "inspection-ns-private-default-route-endpoint-az1" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  count                  = !var.enable_tgw_attachment_subnet  ? 1 : 0
  route_table_id         = module.inspection-private-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az1.id
}
resource "aws_route" "inspection-ns-private-default-route-endpoint-az2" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw]
  count                  = !var.enable_tgw_attachment_subnet  ? 1 : 0
  route_table_id         = module.inspection-private-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.asg_endpoint_az2.id
}