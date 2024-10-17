
data "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-ns-inspection" {
  depends_on = [module.vpc-transit-gateway-attachment-ns-inspection.tgw_attachment_id]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-ns-inspection-tgw-attachment"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-ew-inspection" {
  depends_on = [module.vpc-transit-gateway-attachment-ew-inspection.tgw_attachment_id]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-ew-inspection-tgw-attachment"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_route_table" "tgw-route-table-ns-inspection" {
  depends_on = [module.vpc-transit-gateway-attachment-ns-inspection.tgw_attachment_id]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-NS Inspection VPC TGW Route Table"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_route_table" "tgw-route-table-ew-inspection" {
  depends_on = [module.vpc-transit-gateway-attachment-ew-inspection.tgw_attachment_id]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-EW Inspection VPC TGW Route Table"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-east" {
  count                = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-east-tgw-attachment"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_route_table" "tgw-route-table-east" {
  count                = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-East VPC TGW Route Table"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-west" {
  count                = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-west-tgw-attachment"]

  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_route_table" "tgw-route-table-west" {
  count                = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-West VPC TGW Route Table"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
resource "aws_ec2_transit_gateway_route" "tgw_ns_inspection_route_to_east" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = var.vpc_cidr_east
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-east[0].id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-ns-inspection.id
}
resource "aws_ec2_transit_gateway_route" "tgw_ns_inspection_route_to_west" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = var.vpc_cidr_west
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-west[0].id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-ns-inspection.id
}
resource "aws_ec2_transit_gateway_route" "tgw_ew_inspection_route_to_east" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = var.vpc_cidr_east
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-east[0].id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-ew-inspection.id
}
resource "aws_ec2_transit_gateway_route" "tgw_ew_inspection_route_to_west" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = var.vpc_cidr_west
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-west[0].id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-ew-inspection.id
}
resource "aws_ec2_transit_gateway_route" "tgw_east" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-ns-inspection.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-east[0].id
}
resource "aws_ec2_transit_gateway_route" "tgw_east_west" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = "192.168.1.0/24"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-ew-inspection.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-east[0].id
}
resource "aws_ec2_transit_gateway_route" "tgw_west_east" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = "192.168.0.0/24"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-ew-inspection.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-west[0].id
}
resource "aws_ec2_transit_gateway_route" "tgw_west" {
  count                          = var.enable_linux_spoke_instances ? 1 : 0
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-ns-inspection.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-west[0].id
}
