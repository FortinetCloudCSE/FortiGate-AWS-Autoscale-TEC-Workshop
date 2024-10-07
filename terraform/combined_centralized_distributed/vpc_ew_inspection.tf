locals {
  ew_public_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_ew_inspection, var.subnet_bits, var.public_subnet_index)
}
locals {
  ew_public_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_ew_inspection, var.subnet_bits, var.public_subnet_index + 3)
}
locals {
  ew_gwlbe_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_ew_inspection, var.subnet_bits, var.gwlbe_subnet_index)
}
locals {
  ew_gwlbe_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_ew_inspection, var.subnet_bits, var.gwlbe_subnet_index + 3)
}
locals {
  ew_private_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_ew_inspection, var.subnet_bits, var.private_subnet_index)
}
locals {
  ew_private_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_ew_inspection, var.subnet_bits, var.private_subnet_index + 3)
}

data "aws_vpc_endpoint" "ew_asg_endpoint_az1" {
  depends_on = [module.spk_tgw_gwlb_asg_fgt_igw_ew]
  filter {
    name   = "tag:Name"
    values = [var.ew_endpoint_name_az1]
  }
}

data "aws_vpc_endpoint" "ew_asg_endpoint_az2" {
  depends_on = [module.spk_tgw_gwlb_asg_fgt_igw_ew]
  filter {
    name   = "tag:Name"
    values = [var.ew_endpoint_name_az2]
  }
}

#
# Spoke VPC
#
module "ew-vpc-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-ew-inspection-vpc"
  vpc_cidr                   = var.vpc_cidr_ew_inspection
}

module "ew-vpc-igw-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_igw"
  igw_name                   = "${var.cp}-${var.env}-ew-inspection-igw"
  vpc_id                     = module.ew-vpc-inspection.vpc_id
}
resource "aws_eip" "ew-nat-gateway-inspection-az1" {
}

resource "aws_eip" "ew-nat-gateway-inspection-az2" {
}

resource "aws_nat_gateway" "ew-vpc-inspection-az1" {
  allocation_id     = aws_eip.ew-nat-gateway-inspection-az1.id
  subnet_id         = module.ew-subnet-inspection-public-az1.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-ew-az1"
  }
}

resource "aws_nat_gateway" "ew-vpc-inspection-az2" {
  allocation_id     = aws_eip.ew-nat-gateway-inspection-az2.id
  subnet_id         = module.ew-subnet-inspection-public-az2.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-ew-az2"
  }
}

#
# AZ 1
#
module "ew-subnet-inspection-public-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ew-inspection-public-az1-subnet"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.ew_public_subnet_cidr_az1
}

module "ew-subnet-inspection-gwlbe-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ew-inspection-gwlbe-az1-subnet"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.ew_gwlbe_subnet_cidr_az1
}


module "ew-subnet-inspection-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ew-inspection-private-az1-subnet"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.ew_private_subnet_cidr_az1
}

module "ew-inspection-private-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ew-inspection-private-rt-az1"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
}
module "ew-inspection-private-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.ew-subnet-inspection-private-az1.id
  route_table_id             = module.ew-inspection-private-route-table-az1.id
}
module "ew-inspection-gwlbe-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ew-inspection-gwlbe-rt-az1"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
}
module "ew-gwlbe-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.ew-subnet-inspection-gwlbe-az1.id
  route_table_id             = module.ew-inspection-gwlbe-route-table-az1.id
}

#
# Security VPC Transit Gateway Attachment, Route Table and Routes
#
module "ew-vpc-transit-gateway-attachment-ew-inspection" {
  source                         = "git::https://github.com/40netse/terraform-modules.git//aws_tgw_attachment"
  depends_on                     = [module.existing_resources]
  tgw_attachment_name            = "${var.cp}-${var.env}-ew-inspection-tgw-attachment"

  transit_gateway_id                              = data.aws_ec2_transit_gateway.tgw.id
  subnet_ids                                      = [module.ew-subnet-inspection-private-az1.id, module.ew-subnet-inspection-private-az2.id]
  transit_gateway_default_route_table_propogation = "true"
  appliance_mode_support                          = "enable"
  vpc_id                                          = module.ew-vpc-inspection.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "ew-inspection" {
  transit_gateway_id              = data.aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.cp}-${var.env}-EW Inspection VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "ew-inspection" {
  transit_gateway_attachment_id  = module.ew-vpc-transit-gateway-attachment-ew-inspection.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ew-inspection.id
}
#
# AZ 2
#
module "ew-subnet-inspection-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ew-inspection-public-az2-subnet"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.ew_public_subnet_cidr_az2
}

module "ew-subnet-inspection-gwlbe-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ew-inspection-gwlbe-az2-subnet"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.ew_gwlbe_subnet_cidr_az2
}

module "ew-subnet-inspection-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-ew-inspection-private-az2-subnet"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.ew_private_subnet_cidr_az2
}
module "ew-inspection-public-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ew-inspection-public-rt-az1"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
}

module "ew-inspection-public-route-table_association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.ew-subnet-inspection-public-az1.id
  route_table_id             = module.ew-inspection-public-route-table-az1.id
}

module "ew-inspection-public-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ew-inspection-public-rt-az2"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
}

module "ew-inspection-public-route-table_association-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.ew-subnet-inspection-public-az2.id
  route_table_id             = module.ew-inspection-public-route-table-az2.id
}

module "ew-inspection-private-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ew-inspection-private-rt-az2"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
}

module "ew-inspection-private-route-table-az2-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.ew-subnet-inspection-private-az2.id
  route_table_id             = module.ew-inspection-private-route-table-az2.id
}
module "ew-inspection-gwlbe-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-ew-inspection-gwlbe-rt-az2"

  vpc_id                     = module.ew-vpc-inspection.vpc_id
}
module "ew-inspection-gwlbe-route-table-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.ew-subnet-inspection-gwlbe-az2.id
  route_table_id             = module.ew-inspection-gwlbe-route-table-az2.id
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "ew_route_inspection" {
  default_route_table_id = module.ew-vpc-inspection.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc ew inspection (unused)"
  }
}
#
# Routes for the route table. If nat gateway is enabled, make the default route go to the nat gateway.
# If not, make the default route go to the internet gateway.
#
resource "aws_route" "ew-inspection-public-default-route-ngw-az1" {
  depends_on             = [module.ew-vpc-igw-inspection]
  route_table_id         = module.ew-inspection-public-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.ew-vpc-igw-inspection.igw_id
}
resource "aws_route" "ew-inspection-public-default-route-ngw-az2" {
  depends_on              = [module.ew-vpc-igw-inspection]
  route_table_id         = module.ew-inspection-public-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.ew-vpc-igw-inspection.igw_id
}
#
# gwlbe subnet routes
#
# resource "aws_route" "inspection-ew-gwlbe-default-route-igw-az1" {
#   depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
#   route_table_id         = module.ew-inspection-gwlbe-route-table-az1.id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "inspection-ew-gwlbe-default-route-igw-az2" {
#   depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
#   route_table_id         = module.ew-inspection-gwlbe-route-table-az2.id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
# }

resource "aws_route" "inspection-ew-gwlbe-192-route-igw-az1" {
  depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
  route_table_id         = module.ew-inspection-gwlbe-route-table-az1.id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ew-gwlbe-192-route-igw-az2" {
  depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
  route_table_id         = module.ew-inspection-gwlbe-route-table-az2.id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ew-gwlbe-10-route-igw-az1" {
  depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
  route_table_id         = module.ew-inspection-gwlbe-route-table-az1.id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ew-gwlbe-10-route-igw-az2" {
  depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
  route_table_id         = module.ew-inspection-gwlbe-route-table-az2.id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ew-gwlbe-172-route-igw-az1" {
  depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
  route_table_id         = module.ew-inspection-gwlbe-route-table-az1.id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "inspection-ew-gwlbe-172-route-igw-az2" {
  depends_on             = [module.existing_resources, time_sleep.wait_5_minutes]
  route_table_id         = module.ew-inspection-gwlbe-route-table-az2.id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}


resource "aws_route" "inspection-ew-tgw-default-route-endpoint-az1" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw_ew]
  route_table_id         = module.ew-inspection-private-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.ew_asg_endpoint_az1.id
}
resource "aws_route" "inspection-ew-tgw-default-route-endpoint-az2" {
  depends_on             = [module.spk_tgw_gwlb_asg_fgt_igw_ew]
  route_table_id         = module.ew-inspection-private-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.ew_asg_endpoint_az2.id
}