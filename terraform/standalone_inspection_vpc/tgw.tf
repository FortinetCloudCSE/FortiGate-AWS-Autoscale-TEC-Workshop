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
#
# Security VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-inspection" {
  source                         = "git::https://github.com/40netse/terraform-modules.git//aws_tgw_attachment"
  count                          = var.enable_tgw_attachment ? 1 : 0
  tgw_attachment_name            = "${var.cp}-${var.env}-inspection-tgw-attachment"

  transit_gateway_id                              = data.aws_ec2_transit_gateway.tgw.id
  subnet_ids                                      = [ module.subnet-inspection-private-az1.id, module.subnet-inspection-private-az2.id]
  transit_gateway_default_route_table_propogation = "true"
  appliance_mode_support                          = "enable"
  vpc_id                                          = module.vpc-inspection.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.cp}-${var.env}-Inspection VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-inspection[0].tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

