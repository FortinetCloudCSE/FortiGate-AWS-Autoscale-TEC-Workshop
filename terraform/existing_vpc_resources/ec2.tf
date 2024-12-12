locals {
  linux_east_az1_ip_address = cidrhost(var.vpc_cidr_east_public_az1, var.linux_host_ip)
}
locals {
  linux_east_az2_ip_address = cidrhost(var.vpc_cidr_east_public_az2, var.linux_host_ip)
}

locals {
  linux_west_az1_ip_address = cidrhost(var.vpc_cidr_west_public_az1, var.linux_host_ip)
}
locals {
  linux_west_az2_ip_address = cidrhost(var.vpc_cidr_west_public_az2, var.linux_host_ip)
}

data "aws_subnet" "subnet-east-public-az1" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  depends_on = [ module.subnet-east-public-az1 ]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-east-public-az1-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "subnet-east-public-az2" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  depends_on = [ module.subnet-east-public-az2 ]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-east-public-az2-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "subnet-west-public-az1" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  depends_on = [ module.subnet-west-public-az1 ]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-west-public-az1-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "subnet-west-public-az2" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  depends_on = [ module.subnet-west-public-az2 ]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-west-public-az2-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc" "vpc-east" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  depends_on = [ module.vpc-east ]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-east-vpc"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc" "vpc-west" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  depends_on = [ module.vpc-west ]
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-west-vpc"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

#
# Optional Linux Instances from here down
#
# Linux Instance that are added on to the East and West VPCs for testing EAST->West Traffic
#
# Endpoint AMI to use for Linux Instances. Just added this on the end, since traffic generating linux instances
# would not make it to a production template.
#
data "template_file" "web_userdata_az1" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  template = file("./config_templates/web-userdata.tpl")
  vars = {
    region                = var.aws_region
    availability_zone     = var.availability_zone_1
  }
}
data "template_file" "web_userdata_az2" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  template = file("./config_templates/web-userdata.tpl")
  vars = {
    region                = var.aws_region
    availability_zone     = var.availability_zone_2
  }
}

data "aws_ami" "ubuntu" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20240228*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

#
# EC2 Endpoint Resources
#

#
# East Linux Instance for Generating East->West Traffic
#

module "east_instance_public_az1" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [module.vpc-east, module.vpc-transit-gateway-attachment-east]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-east-public-az1-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_1
  public_subnet_id            = data.aws_subnet.subnet-east-public-az1[0].id
  public_ip_address           = local.linux_east_az1_ip_address
  aws_ami                     = data.aws_ami.ubuntu[0].id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-east-vpc-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.linux_iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az1[0].rendered
}

module "east_instance_public_az2" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [module.vpc-east, module.vpc-transit-gateway-attachment-east]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-east-public-az2-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_2
  public_subnet_id            = data.aws_subnet.subnet-east-public-az2[0].id
  public_ip_address           = local.linux_east_az2_ip_address
  aws_ami                     = data.aws_ami.ubuntu[0].id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-east-vpc-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.linux_iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az2[0].rendered
}

#
# West Linux Instance for Generating West->East Traffic
#
module "west_instance_public_az1" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [module.vpc-west, module.vpc-transit-gateway-attachment-west]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-west-public-az1-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_1
  public_subnet_id            = data.aws_subnet.subnet-west-public-az1[0].id
  public_ip_address           = local.linux_west_az1_ip_address
  aws_ami                     = data.aws_ami.ubuntu[0].id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-west-vpc-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.linux_iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az1[0].rendered
}

module "west_instance_public_az2" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [module.vpc-west, module.vpc-transit-gateway-attachment-west]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-west-public-az2-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_2
  public_subnet_id            = data.aws_subnet.subnet-west-public-az2[0].id
  public_ip_address           = local.linux_west_az2_ip_address
  aws_ami                     = data.aws_ami.ubuntu[0].id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-west-vpc-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.linux_iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az2[0].rendered
}

#
# Security Groups are VPC specific, so an "ALLOW ALL" for each VPC
#
resource "aws_security_group" "ec2-linux-east-vpc-sg" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  description                 = "Security Group for Linux Instances in the East Spoke VPC"
  vpc_id                      = data.aws_vpc.vpc-east[0].id
  ingress {
    description = "Allow SSH from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west ]
  }
  ingress {
    description = "Allow FTP from CIDRs in VPC"
    from_port = 21
    to_port = 21
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Limit PASV ports from CIDRs in VPC"
    from_port = 10090
    to_port = 10100
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow ICMP from connected CIDRs"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west ]
  }
  ingress {
    description = "Allow Syslog from anywhere IPv4"
    from_port = 514
    to_port = 514
    protocol = "udp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    description = "Allow egress ALL"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}
resource "aws_security_group" "ec2-linux-west-vpc-sg" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  description                 = "Security Group for Linux Instances in the West Spoke VPC"
  vpc_id                      = data.aws_vpc.vpc-west[0].id
  ingress {
    description = "Allow SSH from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west ]
  }
  ingress {
    description = "Allow FTP from CIDRs in VPC"
    from_port = 21
    to_port = 21
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Limit PASV ports from CIDRs in VPC"
    from_port = 10090
    to_port = 10100
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow ICMP from connected CIDRs"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_management, var.vpc_cidr_east, var.vpc_cidr_west ]
  }
  ingress {
    description = "Allow Syslog from anywhere IPv4"
    from_port = 514
    to_port = 514
    protocol = "udp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    description = "Allow egress ALL"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

#
# IAM Profile for linux instance
#
module "linux_iam_profile" {
  source        = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance_iam_role"
  count         = var.enable_linux_spoke_instances ? 1 : 0
  iam_role_name = "${var.cp}-${var.env}-${random_string.random.result}-linux-instance_role"
}
