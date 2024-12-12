
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

module "subnet-west-public-az1" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count                      = var.enable_build_existing_subnets ? 1 : 0
  subnet_name                = "${var.cp}-${var.env}-west-public-az1-subnet"
  vpc_id                     = module.vpc-west[0].vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_west_public_az1
}
module "subnet-west-public-az2" {
  source            = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  count             = var.enable_build_existing_subnets ? 1 : 0
  subnet_name       = "${var.cp}-${var.env}-west-public-az2-subnet"
  vpc_id            = module.vpc-west[0].vpc_id
  availability_zone = local.availability_zone_2
  subnet_cidr       = var.vpc_cidr_west_public_az2
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_west" {
  count                  = var.enable_build_existing_subnets ? 1 : 0
  default_route_table_id = module.vpc-west[0].vpc_main_route_table_id
  tags = {
    Name = "${var.cp}-${var.env}-west-vpc-main-route-table"
  }
}
resource "aws_route" "default-route-west-public" {
  depends_on             = [module.vpc-transit-gateway-attachment-west.tgw_attachment_id]
  count                  = var.enable_build_existing_subnets ? 1 : 0
  route_table_id         = module.vpc-west[0].vpc_main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}
resource "aws_route" "management-route-west-public" {
  count                  = var.enable_build_management_vpc ? 1 : 0
  route_table_id         = module.vpc-west[0].vpc_main_route_table_id
  destination_cidr_block = var.vpc_cidr_management
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}
resource "aws_ec2_transit_gateway_route" "route-west-default-tgw" {
  count                          = var.enable_build_existing_subnets ? 1 : 0
  depends_on                     = [module.vpc-transit-gateway-attachment-west]
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west[0].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.west[0].id
}
