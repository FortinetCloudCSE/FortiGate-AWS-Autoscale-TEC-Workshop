
data "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-ns-inspection" {
  depends_on = [module.vpc-transit-gateway-attachment-ns-inspection.tgw_attachment_id]
  filter {
    name   = "tag:Name"
    values = ["mdw-test-lab-ns-inspection-tgw-attachment"]
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
    values = ["mdw-test-lab-NS Inspection VPC TGW Route Table"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-east" {
  filter {
    name   = "tag:Name"
    values = ["mdw-test-lab-east-tgw-attachment"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_route_table" "tgw-route-table-east" {
  filter {
    name   = "tag:Name"
    values = ["mdw-test-lab-East VPC TGW Route Table"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment-west" {
  filter {
    name   = "tag:Name"
    values = ["mdw-test-lab-west-tgw-attachment"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway_route_table" "tgw-route-table-west" {
  filter {
    name   = "tag:Name"
    values = ["mdw-test-lab-West VPC TGW Route Table"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
resource "aws_ec2_transit_gateway_route" "tgw_ns_inspection_route_to_east" {
  destination_cidr_block         = var.vpc_cidr_east
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-east.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-ns-inspection.id
}
resource "aws_ec2_transit_gateway_route" "tgw_ns_inspection_route_to_west" {
  destination_cidr_block         = var.vpc_cidr_west
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-west.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-ns-inspection.id
}
resource "aws_ec2_transit_gateway_route" "tgw_east" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-ns-inspection.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-east.id
}
resource "aws_ec2_transit_gateway_route" "tgw_west" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw-attachment-ns-inspection.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw-route-table-west.id
}
resource "aws_route" "specific_route_to_ec2" {
  route_table_id = module.inspection-public-route-table-az1.id
  destination_cidr_block = "192.168.0.11/32"
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw.id
}