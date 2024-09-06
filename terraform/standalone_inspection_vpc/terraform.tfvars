
aws_region                   = "us-west-2"
availability_zone_1          = "a"
availability_zone_2          = "c"

#
# Booleans to enable certain features
#

#
# Section of booleans to conditionally create a set of resources
#

#
# Allow creation of Linux instances in east/west VPCs
#
enable_jump_box                = true
enable_fortimanager            = true
enable_fortianalyzer           = true
enable_nat_gateway             = true

enable_jump_box_public_ip      = true
enable_fortimanager_public_ip  = true
enable_fortianalyzer_public_ip = true

#
# Subnet bits = number of bits used in the cidr for subnet.
# e.g. 10.0.0.0/16 cidr with 8 subnet bits means each subnet is 10.0.0.0/24, 10.0.1.0/24, etc
#
subnet_bits                 = 4

#
# index in the subnet in the cidr range.
# e.g. index 1 in 10.0.0.0/16 is 10.0.1.0/24
#
public_subnet_index         = 0
gwlbe_subnet_index          = 1
private_subnet_index        = 2

#
# Variables likely to change
#
keypair                     = "mdw-key-oregon"
my_ip                       = "76.184.215.100/32"
#
# cp (customer_prefix) and env (environment) prepended to all resources created by the template.
# Used for identification. e.g. "<customer_prefix>-<prod/test/dev>"
#
cp                          = "cse-test"
env                         = "lab"
vpc_cidr_inspection         = "10.0.0.0/24"

vpc_cidr_jump_box           = "10.0.0.0/28"

fortimanager_instance_type  = "m5.xlarge"
fortianalyzer_instance_type = "m5.xlarge"

fortimanager_os_version     = "7.4.3"
fortimanager_host_ip        = 14
fortianalyzer_os_version    = "7.4.3"
fortianalyzer_host_ip       = 13
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