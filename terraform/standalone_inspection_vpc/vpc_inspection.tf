
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
  subnet_index_addend = var.enable_tgw_attachment_subnet ? 4 : 3
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
  public_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.public_subnet_index + local.subnet_index_addend)
}
locals {
  gwlbe_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.gwlbe_subnet_index)
}
locals {
  gwlbe_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.gwlbe_subnet_index + local.subnet_index_addend)
}
locals {
  private_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.private_subnet_index)
}
locals {
  private_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.private_subnet_index + local.subnet_index_addend)
}
locals {
  tgw_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.tgw_subnet_index)
}
locals {
  tgw_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.tgw_subnet_index + local.subnet_index_addend)
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
  count = var.enable_nat_gateway ? 1 : 0
}

resource "aws_eip" "nat-gateway-inspection-az2" {
  count = var.enable_nat_gateway ? 1 : 0
}

resource "aws_nat_gateway" "vpc-inspection-az1" {
  count = var.enable_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat-gateway-inspection-az1[0].id
  subnet_id         = module.subnet-inspection-public-az1.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-az1-gw-east"
  }
}

resource "aws_nat_gateway" "vpc-inspection-az2" {
  count = var.enable_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat-gateway-inspection-az2[0].id
  subnet_id         = module.subnet-inspection-public-az2.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-az2-gw-east"
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
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az1-public"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.public_subnet_cidr_az1
}
resource aws_ec2_tag "subnet_public_tag_az1" {
  resource_id = module.subnet-inspection-public-az1.id
  key = "Workshop-area"
  value = "Public-Az1"
}

module "subnet-inspection-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az1-private"

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
  rt_name = "${var.cp}-${var.env}-inspection-rt-az1-private"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "inspection-private-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-private-az1.id
  route_table_id             = module.inspection-private-route-table-az1.id
}

module "subnet-inspection-gwlbe-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az1-gwlbe"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.gwlbe_subnet_cidr_az1
}

resource aws_ec2_tag "subnet_gwlbe_tag_az1" {
  resource_id = module.subnet-inspection-gwlbe-az1.id
  key = "Workshop-area"
  value = "gwlbe-Az1"
}

module "inspection-gwlbe-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-rt-az1-gwlbe"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "gwlbe-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-gwlbe-az1.id
  route_table_id             = module.inspection-gwlbe-route-table-az1.id
}

module "subnet-inspection-tgw-az1" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az1-tgw"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.tgw_subnet_cidr_az1
}
resource aws_ec2_tag "subnet_tgw_tag_az1" {
  count       = var.enable_tgw_attachment_subnet ? 1 : 0
  resource_id = module.subnet-inspection-tgw-az1[0].id
  key         = "Workshop-area"
  value       = "TGW-Az1"
}
module "inspection-tgw-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_tgw_attachment_subnet ? 1 : 0
  rt_name = "${var.cp}-${var.env}-inspection-rt-az1-tgw"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "inspection-tgw-route-table-association-az1" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_ids                 = module.subnet-inspection-tgw-az1[0].id
  route_table_id             = module.inspection-tgw-route-table-az1[0].id
}

#
# AZ 2
#
module "subnet-inspection-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az2-public"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.public_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_public_tag_az2" {
  resource_id = module.subnet-inspection-public-az2.id
  key = "Workshop-area"
  value = "Public-Az2"
}
module "subnet-inspection-gwlbe-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az2-gwlbe"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.gwlbe_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_gwlbe_tag_az2" {
  resource_id = module.subnet-inspection-gwlbe-az2.id
  key = "Workshop-area"
  value = "gwlbe-Az2"
}
resource aws_ec2_tag "gwlbe_tag_az1" {
  resource_id = module.subnet-inspection-gwlbe-az1.id
  key = "fortigatecnf_subnet_type"
  value = "endpoint"
}
resource aws_ec2_tag "gwlbe_tag_az2" {
  resource_id = module.subnet-inspection-gwlbe-az2.id
  key = "fortigatecnf_subnet_type"
  value = "endpoint"
}
module "subnet-inspection-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az2-private"

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
  rt_name = "${var.cp}-${var.env}-inspection-rt-az1-public"

  vpc_id                     = module.vpc-inspection.vpc_id
}

module "inspection-public-route-table_association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-public-az1.id
  route_table_id             = module.inspection-public-route-table-az1.id
}

module "inspection-public-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-rt-az2-public"

  vpc_id                     = module.vpc-inspection.vpc_id
}

module "inspection-public-route-table_association-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-public-az2.id
  route_table_id             = module.inspection-public-route-table-az2.id
}

module "inspection-private-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-rt-az2-private"

  vpc_id                     = module.vpc-inspection.vpc_id
}

module "inspection-private-route-table-az2-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-private-az2.id
  route_table_id             = module.inspection-private-route-table-az2.id
}
module "inspection-gwlbe-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-rt-az2-gwlbe"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "inspection-gwlbe-route-table-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-inspection-gwlbe-az2.id
  route_table_id             = module.inspection-gwlbe-route-table-az2.id
}

module "subnet-inspection-tgw-az2" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_name                = "${var.cp}-${var.env}-inspection-subnet-az2-tgw"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.tgw_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_tgw_tag_az2" {
  count       = var.enable_tgw_attachment_subnet ? 1 : 0
  resource_id = module.subnet-inspection-tgw-az2[0].id
  key         = "Workshop-area"
  value       = "TGW-Az2"
}
module "inspection-tgw-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  count   = var.enable_tgw_attachment_subnet ? 1 : 0
  rt_name = "${var.cp}-${var.env}-inspection-rt-az2-tgw"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "inspection-tgw-route-table-association-az2" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"
  count                      = var.enable_tgw_attachment_subnet ? 1 : 0
  subnet_ids                 = module.subnet-inspection-tgw-az2[0].id
  route_table_id             = module.inspection-tgw-route-table-az2[0].id
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
#
# gwlbe Routes
#
resource "aws_route" "inspection-gwlbe-default-route-az1" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-gwlbe-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az1[0].id
}
resource "aws_route" "inspection-gwlbe-default-route-az2" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-gwlbe-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az2[0].id
}

#
# Private Routes. These two tables need a more specific subnet added after the GWLBe is deployed
# to route the Jump Box subnet to the GWLBe. Can't add it here, because there isn't a "target" yet. 
#
resource "aws_route" "inspection-private-default-route-az1" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-private-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az1[0].id
}
resource "aws_route" "inspection-private-default-route-az2" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = module.inspection-private-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-inspection-az2[0].id
}

