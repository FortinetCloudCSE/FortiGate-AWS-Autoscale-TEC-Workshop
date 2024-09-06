
locals {
  linux_inspection_az1_public_ip_address = cidrhost(local.public_subnet_cidr_az1, var.linux_host_ip)
}
locals {
  fortimanager_ip_address = cidrhost(local.public_subnet_cidr_az1, var.fortimanager_host_ip)
}
locals {
  fortianalyzer_ip_address = cidrhost(local.public_subnet_cidr_az1, var.fortianalyzer_host_ip)
}

resource "null_resource" "previous" {}

resource "time_sleep" "wait_5_minutes" {
  depends_on = [ module.inspection_instance_jump_box ]

  create_duration = "5m"
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
  count       = var.enable_jump_box ? 1 : 0
  template = file("./config_templates/web-userdata.tpl")
  vars = {
    region                = var.aws_region
    availability_zone     = var.availability_zone_1
  }
}

data "aws_ami" "ubuntu" {
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
# Security Groups are VPC specific, so an "ALLOW ALL" for each VPC
#
resource "aws_security_group" "ec2-linux-jump-box-sg" {
  count       = var.enable_jump_box ? 1 : 0
  description = "Security Group for Linux Jump Box"
  vpc_id = module.vpc-inspection.vpc_id
  ingress {
    description = "Allow SSH from Anywhere IPv4 (change this to My IP)"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_inspection ]
  }
  ingress {
    description = "Allow HTTP from Anywhere IPv4 (change this to My IP)"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_inspection ]
  }
  ingress {
    description = "Allow FTP from CIDRs in VPC"
    from_port = 21
    to_port = 21
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_inspection ]
  }
  ingress {
    description = "Limit PASV ports from CIDRs in VPC"
    from_port = 10090
    to_port = 10100
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr_inspection ]
  }
  ingress {
    description = "Allow ICMP from connected CIDRs"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ var.my_ip, var.vpc_cidr_inspection  ]
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
  source = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance_iam_role"
  count = var.enable_jump_box ? 1 : 0
  iam_role_name = "${var.cp}-${var.env}-${random_string.random.result}-linux-instance_role"
}

#
# East Linux Instance for Jump Box
#
module "inspection_instance_jump_box" {
  source                      = "git::https://github.com/40netse/terraform-modules.git//aws_ec2_instance"
  count                       = var.enable_jump_box ? 1 : 0
  aws_ec2_instance_name       = "${var.cp}-${var.env}-inspection-jump-box-instance"
  enable_public_ips           = var.enable_jump_box_public_ip
  availability_zone           = local.availability_zone_1
  public_subnet_id            = module.subnet-inspection-public-az1.id
  public_ip_address           = local.linux_inspection_az1_public_ip_address
  aws_ami                     = data.aws_ami.ubuntu.id
  keypair                     = var.keypair
  instance_type               = var.linux_instance_type
  security_group_public_id    = aws_security_group.ec2-linux-jump-box-sg[0].id
  acl                         = var.acl
  iam_instance_profile_id     = module.iam_profile[0].id
  userdata_rendered           = data.template_file.web_userdata_az1[0].rendered
}

#
# Fortimanager
#
data "template_file" "fmgr_userdata" {
  count       = var.enable_fortimanager ? 1 : 0
  template = file("./config_templates/fmgr-userdata.tpl")

  vars = {
    fmgr_byol_license      = file("./licenses/fmgr-license.lic")
  }
}

#
# Fortianalyzer
#
data "template_file" "faz_userdata" {
  count       = var.enable_fortianalyzer ? 1 : 0
  template = file("./config_templates/faz-userdata.tpl")

  vars = {
    faz_byol_license      = file("./licenses/faz-license.lic")
  }
}

data "aws_ami" "fortimanager" {
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
  count         = var.enable_fortimanager ? 1 : 0
  iam_role_name = "${var.cp}-${var.env}-${random_string.random.result}-fortimanager-instance-role"
}

#
# This is an "allow all" security group, but a place holder for a more strict SG
#
resource aws_security_group "fortimanager_sg" {
  count       = var.enable_fortimanager ? 1 : 0
  name        = "allow_public_subnets_fmg"
  description = "Fortimanager Allow required ports from public Subnets"
  vpc_id = module.vpc-inspection.vpc_id
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
  public_subnet_id            = module.subnet-inspection-public-az1.id
  public_ip_address           = local.fortimanager_ip_address
  aws_ami                     = data.aws_ami.fortimanager.id
  enable_public_ips           = var.enable_fortimanager_public_ip
  keypair                     = var.keypair
  security_group_public_id    = aws_security_group.fortimanager_sg[0].id
  iam_instance_profile_id     = module.iam_profile[0].id
  userdata_rendered           = data.template_file.fmgr_userdata[0].rendered
}

resource aws_security_group "fortianalyzer_sg" {
  count       = var.enable_fortianalyzer ? 1 : 0
  name        = "allow_faz_required_ports"
  description = "Fortianalyzer Allow Required Ports"
  vpc_id = module.vpc-inspection.vpc_id
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
  public_subnet_id            = module.subnet-inspection-public-az1.id
  public_ip_address           = local.fortianalyzer_ip_address
  aws_ami                     = data.aws_ami.fortianalyzer.id
  enable_public_ips           = var.enable_fortianalyzer_public_ip
  keypair                     = var.keypair
  security_group_public_id    = aws_security_group.fortianalyzer_sg[0].id
  iam_instance_profile_id     = module.iam_profile[0].id
  userdata_rendered           = data.template_file.faz_userdata[0].rendered
}
