
module "vpc-transit-gateway" {
  source                          = "git::https://github.com/40netse/terraform-modules.git//aws_tgw"
  tgw_name                        = "${var.cp}-${var.env}-tgw"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "disable"
}

resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
  tags = {
    Name = "${var.cp}-${var.env}-Inspection VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route" "tgw_route_inspection_cidr_east" {
  destination_cidr_block         = var.vpc_cidr_east
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east.tgw_attachment_id
}
resource "aws_ec2_transit_gateway_route" "tgw_route_inspection_cidr_west" {
  destination_cidr_block         = var.vpc_cidr_west
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west.tgw_attachment_id
}

#
# East VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-east" {
  depends_on                     = [module.subnet-east-private-az2]
  source                         = "git::https://github.com/40netse/terraform-modules.git//aws_tgw_attachment"
  tgw_attachment_name            = "${var.cp}-${var.env}-east-tgw-attachment"

  transit_gateway_id             = module.vpc-transit-gateway.tgw_id
  subnet_ids                     = [ module.subnet-east-private-az1.id, module.subnet-east-private-az2.id ]
  transit_gateway_default_route_table_propogation = "false"
  appliance_mode_support                          = "enable"
  vpc_id                                          = module.vpc-east.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "east" {
  transit_gateway_id             = module.vpc-transit-gateway.tgw_id
    tags = {
      Name = "${var.cp}-${var.env}-East VPC TGW Route Table"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "east" {
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.east.id
}

#
# West VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-west" {
  depends_on           = [module.subnet-west-private-az2]
  source               = "git::https://github.com/40netse/terraform-modules.git//aws_tgw_attachment"
  tgw_attachment_name  = "${var.cp}-${var.env}-west-tgw-attachment"

  transit_gateway_id   = module.vpc-transit-gateway.tgw_id
  subnet_ids           = [ module.subnet-west-private-az1.id, module.subnet-west-private-az2.id ]
  transit_gateway_default_route_table_propogation = "false"
  appliance_mode_support                          = "enable"
  vpc_id                                          = module.vpc-west.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "west" {
  transit_gateway_id             = module.vpc-transit-gateway.tgw_id
  tags = {
    Name = "${var.cp}-${var.env}-West VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "west" {
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.west.id
}

