locals {
  rfc1918_192 = "192.168.0.0/16"
}
locals {
  rfc1918_10 = "10.0.0.0/8"
}
locals {
  rfc1918_172 = "172.16.0.0/12"
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

module "vpc-management" {
  source                         = "git::https://github.com/40netse/terraform-modules.git//aws_management_vpc"
  count                          = var.enable_build_management_vpc ? 1 : 0
  depends_on                     = [ module.vpc-transit-gateway.tgw_id ]
  aws_region                     = var.aws_region
  vpc_name                       = "${var.cp}-${var.env}-management"
  vpc_cidr                       = var.vpc_cidr_management
  subnet_bits                    = var.subnet_bits
  availability_zone_1            = local.availability_zone_1
  availability_zone_2            = local.availability_zone_2
  named_tgw                      = var.attach_to_tgw_name
  enable_tgw_attachment          = var.enable_management_tgw_attachment
  acl                            = var.acl
  random_string                  = random_string.random.result
  keypair                        = var.keypair
  enable_fortianalyzer           = var.enable_fortianalyzer
  enable_fortianalyzer_public_ip = var.enable_fortianalyzer_public_ip
  enable_fortimanager            = var.enable_fortimanager
  enable_fortimanager_public_ip  = var.enable_fortianalyzer_public_ip
  enable_jump_box                = var.enable_jump_box
  enable_jump_box_public_ip      = var.enable_jump_box_public_ip
  fortianalyzer_host_ip          = var.fortianalyzer_host_ip
  fortianalyzer_instance_type    = var.fortianalyzer_instance_type
  fortianalyzer_os_version       = var.fortianalyzer_os_version
  fortimanager_host_ip           = var.fortimanager_host_ip
  fortimanager_instance_type     = var.fortimanager_instance_type
  fortimanager_os_version        = var.fortimanager_os_version
  linux_host_ip                  = var.linux_host_ip
  linux_instance_type            = var.linux_instance_type
  my_ip                          = var.my_ip
}
resource "aws_route" "management-public-default-route-igw-az1" {
  depends_on             = [module.vpc-management]
  route_table_id         = module.vpc-management[0].route_table_management_public_az1_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-management[0].igw_id
}
resource "aws_route" "management-public-default-route-igw-az2" {
  depends_on             = [module.vpc-management]
  route_table_id         = module.vpc-management[0].route_table_management_public_az2_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-management[0].igw_id
}
#
# This is a bit bruce force. Route all the rfc-1918 space to the TGW. More specific route will handle the local traffic.
#

resource "aws_route" "public-192-route-tgw-az1" {
  depends_on             = [module.vpc-management]
  route_table_id         = module.vpc-management[0].subnet_management_public_az1_id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "public-192-route-tgw-az2" {
  depends_on             = [module.vpc-management]
  count                 = var.enable_management_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-management[0].subnet_management_public_az2_id
  destination_cidr_block = local.rfc1918_192
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "public-10-route-tgw-az1" {
  depends_on             = [module.vpc-management]
  count                  = var.enable_management_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-management[0].subnet_management_public_az1_id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "public-10-route-tgw-az2" {
  depends_on             = [module.vpc-management]
  count                 = var.enable_management_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-management[0].subnet_management_public_az2_id
  destination_cidr_block = local.rfc1918_10
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "public-172-route-tgw-az1" {
  depends_on             = [module.vpc-management]
  count                  = var.enable_management_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-management[0].subnet_management_public_az1_id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_route" "public-172-route-tgw-az2" {
  depends_on             = [module.vpc-management]
  count                  = var.enable_management_tgw_attachment ? 1 : 0
  route_table_id         = module.vpc-management[0].subnet_management_public_az2_id
  destination_cidr_block = local.rfc1918_172
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}
resource "aws_ec2_transit_gateway_route" "route-to-west-tgw" {
  count                          = var.enable_build_existing_subnets ? 1 : 0
  depends_on                     = [module.vpc-management]
  destination_cidr_block         = var.vpc_cidr_west
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west[0].tgw_attachment_id
  transit_gateway_route_table_id = module.vpc-management[0].management_tgw_route_table_id
}
resource "aws_ec2_transit_gateway_route" "route-to-east-tgw" {
  count                          = var.enable_build_existing_subnets ? 1 : 0
  depends_on                     = [module.vpc-management]
  destination_cidr_block         = var.vpc_cidr_east
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east[0].tgw_attachment_id
  transit_gateway_route_table_id = module.vpc-management[0].management_tgw_route_table_id
}