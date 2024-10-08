
locals {
  linux_inspection_az1_public_ip_address = cidrhost(local.public_subnet_cidr_az1, var.linux_host_ip)
}

locals {
  fortimanager_ip_address = cidrhost(local.public_subnet_cidr_az1, var.fortimanager_host_ip)
}
locals {
  fortianalyzer_ip_address = cidrhost(local.public_subnet_cidr_az1, var.fortianalyzer_host_ip)
}
locals {
  linux_east_az1_ip_address = cidrhost(var.vpc_cidr_east_private_az1, var.linux_host_ip)
}
locals {
  linux_east_az2_ip_address = cidrhost(var.vpc_cidr_east_private_az2, var.linux_host_ip)
}

locals {
  linux_west_az1_ip_address = cidrhost(var.vpc_cidr_west_private_az1, var.linux_host_ip)
}
locals {
  linux_west_az2_ip_address = cidrhost(var.vpc_cidr_west_private_az2, var.linux_host_ip)
}

resource "null_resource" "previous" {}

resource "time_sleep" "wait_5_minutes" {
  depends_on = [ module.inspection_instance_jump_box ]

  create_duration = "5m"
}

data "aws_subnet" "subnet-east-private-az1" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-east-private-az1-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "subnet-east-private-az2" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-east-private-az2-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "subnet-west-private-az1" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-west-private-az1-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "subnet-west-private-az2" {
  count = var.enable_linux_spoke_instances ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-west-private-az2-subnet"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc" "vpc-east" {
  count = var.enable_linux_spoke_instances ? 1 : 0
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
  filter {
    name   = "tag:Name"
    values = ["${var.cp}-${var.env}-west-vpc"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
# This resource will create (at least) 30 seconds after null_resource.previous
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_5_minutes]
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

module "east_instance_private_az1" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [time_sleep.wait_5_minutes]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-east-private-az1-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_1
  public_subnet_id            = data.aws_subnet.subnet-east-private-az1[0].id
  public_ip_address           = local.linux_east_az1_ip_address
  aws_ami                     = data.aws_ami.ubuntu[0].id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-east-vpc-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.linux_iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az1[0].rendered
}

module "east_instance_private_az2" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [time_sleep.wait_5_minutes]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-east-private-az2-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_2
  public_subnet_id            = data.aws_subnet.subnet-east-private-az2[0].id
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
module "west_instance_private_az1" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [time_sleep.wait_5_minutes]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-west-private-az1-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_1
  public_subnet_id            = data.aws_subnet.subnet-west-private-az1[0].id
  public_ip_address           = local.linux_west_az1_ip_address
  aws_ami                     = data.aws_ami.ubuntu[0].id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-west-vpc-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.linux_iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az1[0].rendered
}

module "west_instance_private_az2" {
  count                       = var.enable_linux_spoke_instances ? 1 : 0
  depends_on                  = [time_sleep.wait_5_minutes]
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-west-private-az2-instance"
  enable_public_ips           = false
  availability_zone           = local.availability_zone_2
  public_subnet_id            = data.aws_subnet.subnet-west-private-az2[0].id
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
  description                 = "Security Group for Linux Jump Box"
  vpc_id                      = data.aws_vpc.vpc-east[0].id
  ingress {
    description = "Allow SSH from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west ]
  }
  ingress {
    description = "Allow FTP from CIDRs in VPC"
    from_port = 21
    to_port = 21
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Limit PASV ports from CIDRs in VPC"
    from_port = 10090
    to_port = 10100
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow ICMP from connected CIDRs"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west ]
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
  description                 = "Security Group for Linux Jump Box"
  vpc_id                      = data.aws_vpc.vpc-west[0].id
  ingress {
    description = "Allow SSH from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west ]
  }
  ingress {
    description = "Allow FTP from CIDRs in VPC"
    from_port = 21
    to_port = 21
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Limit PASV ports from CIDRs in VPC"
    from_port = 10090
    to_port = 10100
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow ICMP from connected CIDRs"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west ]
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
# Security Groups are VPC specific, so an "ALLOW ALL" for each VPC
#
resource "aws_security_group" "ec2-linux-jump-box-sg" {
  count       = var.enable_jump_box ? 1 : 0
  description = "Security Group for Linux Jump Box"
  vpc_id = module.vpc-ns-inspection.vpc_id
  ingress {
    description = "Allow SSH from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west ]
  }
  ingress {
    description = "Allow FTP from CIDRs in VPC"
    from_port = 21
    to_port = 21
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Limit PASV ports from CIDRs in VPC"
    from_port = 10090
    to_port = 10100
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west]
  }
  ingress {
    description = "Allow ICMP from connected CIDRs"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_ns_inspection, var.vpc_cidr_east, var.vpc_cidr_west ]
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
  count         = var.enable_jump_box || var.enable_linux_spoke_instances ? 1 : 0
  iam_role_name = "${var.cp}-${var.env}-${random_string.random.result}-linux-instance_role"
}

#
# East Linux Instance for Jump Box
#
module "inspection_instance_jump_box" {
  count                       = var.enable_jump_box ? 1 : 0
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  aws_ec2_instance_name       = "${var.cp}-${var.env}-ns-inspection-jump-box-instance"
  enable_public_ips           = var.enable_jump_box_public_ip
  availability_zone           = local.availability_zone_1
  public_subnet_id            = module.subnet-ns-inspection-public-az1.id
  public_ip_address           = local.linux_inspection_az1_public_ip_address
  aws_ami                     = data.aws_ami.ubuntu[0].id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-jump-box-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.linux_iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az1[0].rendered
}

#
# Fortimanager
#
data "template_file" "fmgr_userdata" {
  count                = var.enable_fortimanager ? 1 : 0
  template             = file("./config_templates/fmgr-userdata.tpl")
  vars = {
    fmgr_byol_license  = var.enable_fortimanager ? ("./licenses/fmgr-license.lic") : ""
  }
}

#
# Fortianalyzer
#
data "template_file" "faz_userdata" {
  count                = var.enable_fortianalyzer ? 1 : 0
  template = file("./config_templates/faz-userdata.tpl")
  vars = {
    faz_byol_license      = var.enable_fortianalyzer ? ("./licenses/faz-license.lic") : ""
  }
}

data "aws_ami" "fortimanager" {
  count                = var.enable_fortimanager ? 1 : 0
  most_recent = true

  filter {
    name                         = "name"
    values                       = ["FortiManager*VM64-AWS *(${var.fortimanager_os_version}) GA*"]
  }

  filter {
    name                         = "virtualization-type"
    values                       = ["hvm"]
  }

  owners                         = ["679593333241"] # Canonical
}

data "aws_ami" "fortianalyzer" {
  count                = var.enable_fortianalyzer ? 1 : 0
  most_recent = true

  filter {
    name                         = "name"
    values                       = ["FortiAnalyzer*VM64-AWS *(${var.fortianalyzer_os_version}) GA*"]
  }

  filter {
    name                         = "virtualization-type"
    values                       = ["hvm"]
  }

  owners                         = ["679593333241"] # Canonical
}

module "iam_profile" {
  source        = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance_iam_role"
  count         = var.enable_fortimanager || var.enable_fortianalyzer ? 1 : 0
  iam_role_name = "${var.cp}-${var.env}-${random_string.random.result}-fortimanager-instance-role"
}

#
# This is an "allow all" security group, but a place holder for a more strict SG
#
resource aws_security_group "fortimanager_sg" {
  count       = var.enable_fortimanager ? 1 : 0
  name        = "allow_public_subnets_fmg"
  description = "Fortimanager Allow required ports from public Subnets"
  vpc_id      = module.vpc-ns-inspection.vpc_id
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ var.my_ip ]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip ]
  }
  ingress {
    description = "Allow Web Filter"
    from_port = 8900
    to_port = 8900
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Allow AV Query and GEO IP Service"
    from_port = 8902
    to_port = 8903
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Allow Cascade Mode"
    from_port = 8891
    to_port = 8891
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Allow HA Protocol"
    from_port = 5199
    to_port = 5199
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_fortimanager_required_ports"
  }
}

module "fortimanager" {
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  count                       = var.enable_fortimanager ? 1 : 0
  aws_ec2_instance_name       = "${var.cp}-${var.env}-Fortimanager"
  availability_zone           = local.availability_zone_1
  instance_type               = var.fortimanager_instance_type
  public_subnet_id            = module.subnet-ns-inspection-public-az1.id
  enable_public_ips           = var.enable_fortimanager_public_ip
  public_ip_address           = local.fortimanager_ip_address
  aws_ami                     = data.aws_ami.fortimanager[0].id
  keypair                     = var.keypair
  security_group_public_id    = aws_security_group.fortimanager_sg[0].id
  iam_instance_profile_id     = module.iam_profile[0].id
  userdata_rendered           = var.enable_fortimanager ? data.template_file.fmgr_userdata[0].rendered : ""
}

resource aws_security_group "fortianalyzer_sg" {
  count       = var.enable_fortianalyzer ? 1 : 0
  name        = "allow_faz_required_ports"
  description = "Fortianalyzer Allow Required Ports"
  vpc_id = module.vpc-ns-inspection.vpc_id
    ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ var.my_ip ]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip ]
  }
  ingress {
    description = "Allow Web Filter"
    from_port = 8900
    to_port = 8900
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Log Fetch TCP"
    from_port = 514
    to_port = 514
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Log Fetch UDP"
    from_port = 514
    to_port = 514
    protocol = "udp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow FAZ required ports"
  }
}


module "fortianalyzer" {
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  count                       = var.enable_fortianalyzer ? 1 : 0
  aws_ec2_instance_name       = "${var.cp}-${var.env}-Fortianalyzer"
  availability_zone           = local.availability_zone_1
  instance_type               = var.fortianalyzer_instance_type
  public_subnet_id            = module.subnet-ns-inspection-public-az1.id
  public_ip_address           = local.fortianalyzer_ip_address
  aws_ami                     = data.aws_ami.fortianalyzer[0].id
  enable_public_ips           = var.enable_fortianalyzer_public_ip
  keypair                     = var.keypair
  security_group_public_id    = aws_security_group.fortianalyzer_sg[0].id
  iam_instance_profile_id     = module.iam_profile[0].id
  userdata_rendered           = var.enable_fortianalyzer ? data.template_file.faz_userdata[0].rendered : ""
}
