
aws_region                   = "us-west-2"
availability_zone_1          = "a"
availability_zone_2          = "c"


#
# cp (customer_prefix) and env (environment) prepended to all resources created by the template.
# Used for identification. e.g. "<customer_prefix>-<prod/test/dev>"
#
cp                          = "mdw-test"
env                         = "lab"

vpc_cidr_spoke              = "192.168.0.0/16"
vpc_cidr_east               = "192.168.0.0/24"
vpc_cidr_east_private_az1   = "192.168.0.0/28"
vpc_cidr_east_private_az2   = "192.168.0.16/28"
vpc_cidr_west               = "192.168.1.0/24"
vpc_cidr_west_private_az1   = "192.168.1.0/28"
vpc_cidr_west_private_az2   = "192.168.1.16/28"
