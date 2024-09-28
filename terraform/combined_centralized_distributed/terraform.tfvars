
aws_region                   = "us-west-2"
availability_zone_1          = "a"
availability_zone_2          = "c"

#
# Subnet bits = number of bits used in the cidr for subnet.
# e.g. 10.0.0.0/16 cidr with 8 subnet bits means each subnet is 10.0.0.0/24, 10.0.1.0/24, etc
#
subnet_bits                 = 7

#
# index in the subnet in the cidr range.
# e.g. index 1 in 10.0.0.0/16 is 10.0.1.0/24
#
public_subnet_index         = 0
gwlbe_subnet_index          = 1
private_subnet_index        = 2
tgw_subnet_index            = 3

#
# Variables likely to change
#
keypair                     = "mdw-key-oregon"
my_ip                       = "76.184.215.100/32"

#
# Allow creation of Linux instances in east/west VPCs
#
enable_jump_box                = true
enable_fortimanager            = false
enable_fortianalyzer           = false
enable_nat_gateway             = false
enable_build_existing_vpc      = true
enable_jump_box_public_ip      = true
enable_fortimanager_public_ip  = false
enable_fortianalyzer_public_ip = false
enable_tgw_attachment_subnet   = true
enable_tgw_attachment          = true

attach_to_tgw_name          = "mdw-test-lab-tgw"

#
# cp (customer_prefix) and env (environment) prepended to all resources created by the template.
# Used for identification. e.g. "<customer_prefix>-<prod/test/dev>"
#
cp                          = "mdw-test"
env                         = "lab"
vpc_cidr_ns_inspection      = "10.88.0.0/17"

vpc_cidr_jump_box           = "10.0.0.0/24"
vpc_cidr_spoke              = "192.168.0.0/16"

vpc_cidr_east               = "192.168.0.0/24"
vpc_cidr_east_private_az1   = "192.168.0.0/28"
vpc_cidr_east_private_az2   = "192.168.0.16/28"
vpc_cidr_west               = "192.168.1.0/24"
vpc_cidr_west_private_az1   = "192.168.1.0/28"
vpc_cidr_west_private_az2   = "192.168.1.16/28"

fortimanager_instance_type  = "m5.xlarge"
fortianalyzer_instance_type = "m5.xlarge"

fortimanager_os_version     = "7.4.3"
fortimanager_host_ip        = 14
fortianalyzer_os_version    = "7.4.3"
fortianalyzer_host_ip       = 13

fortigate_asg_password      = "Texas4me!"
#
# Fortigate Variables
# cidr_for_access goes into the inbound security group for the Fortigates. Current value is open. It may be wise to
# limit access to a jump box or specific IP/Subnet
#
cidr_for_access             = "0.0.0.0/0"
acl                         = "private"

#
# Endpoints Variables
#
linux_instance_type         = "t2.micro"
linux_host_ip               = 11

#
# variables for distributed
#
vpc_name_distributed            = "distributed"
vpc_cidr_distributed            = "10.1.0.0/16"
#
# Endpoints Variables
#
enable_nlb                      = false
use_preallocated_elastic_ip     = false
enable_public_ips               = true
ec2_sg_name_distributed         = "ec2_distributed"
linux_instance_name_distributed = "Linux Instance Distributed"
