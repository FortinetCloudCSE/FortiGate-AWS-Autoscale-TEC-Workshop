
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
locals {
  public_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.public_subnet_index)
}
locals {
  public_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.public_subnet_index + 3)
}
locals {
  fwaas_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.fwaas_subnet_index)
}
locals {
  fwaas_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.fwaas_subnet_index + 3)
}
locals {
  private_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.private_subnet_index)
}
locals {
  private_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.private_subnet_index + 3)
}

resource "random_string" "random" {
  length           = 5
  special          = false
}

#
# VPC Setups, route tables, route table associations
#

#
# Spoke VPC
#
module "vpc-inspection" {
  depends_on = [ module.vpc-transit-gateway.tgw_id ]
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-inspection-vpc"
  vpc_cidr                   = var.vpc_cidr_inspection
}

module "vpc-igw-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_igw"
  igw_name                   = "${var.cp}-${var.env}-inspection-igw"
  vpc_id                     = module.vpc-inspection.vpc_id
}


resource "aws_eip" "nat-gateway-inspection-az1" {
}

resource "aws_eip" "nat-gateway-inspection-az2" {
}

resource "aws_nat_gateway" "vpc-inspection-az1" {
  allocation_id     = aws_eip.nat-gateway-inspection-az1.id
  subnet_id         = module.subnet-inspection-public-az1.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-east-az1"
  }
}

resource "aws_nat_gateway" "vpc-inspection-az2" {
  allocation_id     = aws_eip.nat-gateway-inspection-az2.id
  subnet_id         = module.subnet-inspection-public-az2.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-east-az2"
  }
}

module "igw-route-table" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-igw-rt"

  vpc_id                     = module.vpc-inspection.vpc_id
}
resource "aws_route_table_association" "b" {
  gateway_id     = module.vpc-igw-inspection.igw_id
  route_table_id = module.igw-route-table.id
}

#
# AZ 1
#
module "subnet-inspection-public-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-public-az1-subnet"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.public_subnet_cidr_az1
}
resource aws_ec2_tag "subnet_public_tag_az1" {
  resource_id = module.subnet-inspection-public-az1.id
  key = "Workshop-area"
  value = "Public-Az1"
}

module "subnet-inspection-fwaas-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-fwaas-az1-subnet"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.fwaas_subnet_cidr_az1
}

resource aws_ec2_tag "subnet_fwaas_tag_az1" {
  resource_id = module.subnet-inspection-fwaas-az1.id
  key = "Workshop-area"
  value = "Fwaas-Az1"
}

module "subnet-inspection-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-private-az1-subnet"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.private_subnet_cidr_az1
}
resource aws_ec2_tag "subnet_private_tag_az1" {
  resource_id = module.subnet-inspection-private-az1.id
  key = "Workshop-area"
  value = "Private-Az1"
}
module "inspection-private-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-private-rt-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "inspection-private-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-private-az1.id
  route_table_id             = module.inspection-private-route-table-az1.id
}
module "inspection-fwaas-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-fwaas-rt-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "fwaas-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-fwaas-az1.id
  route_table_id             = module.inspection-fwaas-route-table-az1.id
}

#
# AZ 2
#
module "subnet-inspection-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-public-az2-subnet"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.public_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_public_tag_az2" {
  resource_id = module.subnet-inspection-public-az2.id
  key = "Workshop-area"
  value = "Public-Az2"
}
module "subnet-inspection-fwaas-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-fwaas-az2-subnet"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.fwaas_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_fwaas_tag_az2" {
  resource_id = module.subnet-inspection-fwaas-az2.id
  key = "Workshop-area"
  value = "Fwaas-Az2"
}
resource aws_ec2_tag "fwaas_tag_az1" {
  resource_id = module.subnet-inspection-fwaas-az1.id
  key = "fortigatecnf_subnet_type"
  value = "endpoint"
}
resource aws_ec2_tag "fwaas_tag_az2" {
  resource_id = module.subnet-inspection-fwaas-az2.id
  key = "fortigatecnf_subnet_type"
  value = "endpoint"
}
module "subnet-inspection-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-private-az2-subnet"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.private_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_inspection_private_tag_az2" {
  resource_id = module.subnet-inspection-private-az2.id
  key = "Workshop-area"
  value = "Private-Az2"
}
module "inspection-public-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-public-rt-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
}

module "inspection-public-route-table_association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-public-az1.id
  route_table_id             = module.inspection-public-route-table-az1.id
}

module "inspection-public-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-public-rt-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
}

module "inspection-public-route-table_association-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-public-az2.id
  route_table_id             = module.inspection-public-route-table-az2.id
}

module "inspection-private-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-private-rt-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
}

module "inspection-private-route-table-az2-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-private-az2.id
  route_table_id             = module.inspection-private-route-table-az2.id
}
module "inspection-fwaas-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-fwaas-rt-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "inspection-fwaas-route-table-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-fwaas-az2.id
  route_table_id             = module.inspection-fwaas-route-table-az2.id
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_inspection" {
  default_route_table_id = module.vpc-inspection.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc inspection (unused)"
  }
}

#
# Initial inspection table routes. These need to change after deploying GWLBe's
# Inspection VPC - Public Route Table
#
resource "aws_route" "inspection-public-az1-default-route-default" {
  route_table_id         = module.inspection-public-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-inspection.igw_id
}
resource "aws_route" "inspection-public-az2-default-route-default" {
  route_table_id         = module.inspection-public-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-inspection.igw_id
}
resource "aws_route" "inspection-public-route-spoke-az1" {
  depends_on             = [module.vpc-transit-gateway-attachment-inspection.tgw_attachment_id]
  route_table_id         = module.inspection-public-route-table-az1.id
  destination_cidr_block = var.vpc_cidr_spoke
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}
resource "aws_route" "inspection-public-route-spoke-az2" {
  depends_on             = [module.vpc-transit-gateway-attachment-inspection.tgw_attachment_id]
  route_table_id         = module.inspection-public-route-table-az2.id
  destination_cidr_block = var.vpc_cidr_spoke
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}

#
# Fwaas Routes
#
resource "aws_route" "inspection-fwaas-default-route-az1" {
  route_table_id         = module.inspection-fwaas-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az1.id
}
resource "aws_route" "inspection-fwaas-default-route-az2" {
  route_table_id         = module.inspection-fwaas-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az2.id
}
resource "aws_route" "inspection-fwaas-spoke-route-az1" {
  depends_on             = [module.vpc-transit-gateway-attachment-inspection.tgw_attachment_id]
  route_table_id         = module.inspection-fwaas-route-table-az1.id
  destination_cidr_block = var.vpc_cidr_spoke
  transit_gateway_id         = module.vpc-transit-gateway.tgw_id
}
resource "aws_route" "inspection-fwaas-spoke-route-az2" {
  depends_on             = [module.vpc-transit-gateway-attachment-inspection.tgw_attachment_id]
  route_table_id         = module.inspection-fwaas-route-table-az2.id
  destination_cidr_block = var.vpc_cidr_spoke
  transit_gateway_id         = module.vpc-transit-gateway.tgw_id
}

#
# Private Routes. These two tables need a more specific subnet added after the GWLBe is deployed
# to route the Jump Box subnet to the GWLBe. Can't add it here, because there isn't a "target" yet. 
#
resource "aws_route" "inspection-private-default-route-az1" {
  route_table_id         = module.inspection-private-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az1.id
}
resource "aws_route" "inspection-private-default-route-az2" {
  route_table_id         = module.inspection-private-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az1.id
}
# resource "aws_route" "inspection-private-spoke-route-az1" {
#   depends_on             = [module.vpc-transit-gateway-attachment-inspection.tgw_attachment_id]
#   route_table_id         = module.inspection-private-route-table-az1.id
#   destination_cidr_block = var.vpc_cidr_spoke
#   transit_gateway_id         = module.vpc-transit-gateway.tgw_id
# }
# resource "aws_route" "inspection-private-spoke-route-az2" {
#   depends_on             = [module.vpc-transit-gateway-attachment-inspection.tgw_attachment_id]
#   route_table_id         = module.inspection-private-route-table-az2.id
#   destination_cidr_block = var.vpc_cidr_spoke
#   transit_gateway_id         = module.vpc-transit-gateway.tgw_id
# }


