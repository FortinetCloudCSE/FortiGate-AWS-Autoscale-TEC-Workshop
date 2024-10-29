
module "vpc-transit-gateway" {
  source                          = "git::https://github.com/40netse/terraform-modules.git//aws_tgw"
  tgw_name                        = "${var.cp}-${var.env}-tgw"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "disable"
}

#
# East VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-east" {
  source                         = "git::https://github.com/40netse/terraform-modules.git//aws_tgw_attachment"
  count                          = var.enable_build_existing_subnets ? 1 : 0
  depends_on                     = [module.vpc-transit-gateway,
                                    module.subnet-east-private-az1,
                                    module.subnet-east-private-az2]
  tgw_attachment_name            = "${var.cp}-${var.env}-east-tgw-attachment"

  transit_gateway_id             = module.vpc-transit-gateway.tgw_id
  subnet_ids                     = [ module.subnet-east-private-az1[0].id, module.subnet-east-private-az2[0].id ]
  transit_gateway_default_route_table_propogation = "false"
  appliance_mode_support                          = "enable"
  vpc_id                                          = module.vpc-east[0].vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "east" {
  count                          = var.enable_build_existing_subnets ? 1 : 0
  transit_gateway_id             = module.vpc-transit-gateway.tgw_id
    tags = {
      Name = "${var.cp}-${var.env}-East VPC TGW Route Table"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "east" {
  count                          = var.enable_build_existing_subnets ? 1 : 0
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east[0].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.east[0].id
}
#
# West VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-west" {
  source               = "git::https://github.com/40netse/terraform-modules.git//aws_tgw_attachment"
  count                = var.enable_build_existing_subnets ? 1 : 0
  depends_on           = [module.vpc-transit-gateway,
                          module.subnet-west-private-az1,
                          module.subnet-west-private-az2]
  tgw_attachment_name  = "${var.cp}-${var.env}-west-tgw-attachment"

  transit_gateway_id   = module.vpc-transit-gateway.tgw_id
  subnet_ids           = [ module.subnet-west-private-az1[0].id, module.subnet-west-private-az2[0].id ]
  transit_gateway_default_route_table_propogation = "false"
  appliance_mode_support                          = "enable"
  vpc_id                                          = module.vpc-west[0].vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "west" {
  count                = var.enable_build_existing_subnets ? 1 : 0
  transit_gateway_id             = module.vpc-transit-gateway.tgw_id
  tags = {
    Name = "${var.cp}-${var.env}-West VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "west" {
  count                          = var.enable_build_existing_subnets ? 1 : 0
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west[0].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.west[0].id
}


