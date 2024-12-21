variable "aws_region" {
  description = "The AWS region to use"
}
variable "availability_zone_1" {
  description = "Availability Zone 1 for VPC"
}
variable "availability_zone_2" {
  description = "Availability Zone 2 for VPC"
}
variable subnet_bits {
  description = "Number of bits in the network portion of the subnet CIDR"
}
variable "public_subnet_index" {
  description = "Index of the public subnet"
  default = 0
}
variable "gwlbe_subnet_index" {
  description = "Index of the management subnet"
  default = 1
}
variable "private_subnet_index" {
  description = "Index of the private subnet"
  default = 2
}
variable "natgw_subnet_index" {
  description = "Index of the NAT GW subnet"
  default = 3
}
variable "access_internet_mode" {
  description = "Variable that defines how the fortigates in the autoscale group will access the internet. 'nat_gw' or 'eip'"
  type = string
  default = "nat_gw"
}
variable "fortigate_gui_port" {
  description = "Fortigate GUI Port"
  default = 443
}
variable "firewall_policy_mode" {
  description = "Firewall Policy Mode"
  type = string
  default = "2-arm"
}
variable "keypair" {
  description = "Keypair for instances that support keypairs"
}
variable "my_ip" {
    description = "CIDR for my IP to restrict security group"
}
variable "cp" {
  description = "Customer Prefix to apply to all resources"
}
variable "env" {
  description = "The Tag Environment to differentiate prod/test/dev"
}
variable "enable_dedicated_management_vpc" {
  description = "Boolean to allow creation of dedicated management interface in management VPC"
  type        = bool
}
variable "enable_dedicated_management_eni" {
  description = "Boolean to allow creation of dedicated management subnets and ENI in the inspection VPC"
  type        = bool
}
variable "create_tgw_routes_for_existing" {
  description = "Boolean to allow creation of TGW routes for the existing_vpc_resources template"
  type        = bool
}
variable "enable_east_west_inspection" {
  description = "Boolean to allow creation of a separate autoscale group for east/west inspection"
  type        = bool
}
variable "enable_tgw_attachment" {
  description = "Allow Inspection VPC to attach to an existing TGW"
  type        = bool
}
variable "allow_cross_zone_load_balancing" {
  description = "Allow gateway load balancer to use healthy instances in a different zone"
  type        = bool
}
variable "asg_module_prefix" {
  description = "Module Prefix for East/West Autoscale Group"
  type        = string
  default     = ""
}
variable "vpc_cidr_inspection" {
    description = "CIDR for the whole NS inspection VPC"
}
variable "vpc_cidr_east" {
    description = "CIDR for the whole east VPC"
}
variable "vpc_cidr_west" {
    description = "CIDR for the whole west VPC"
}
variable "vpc_cidr_management" {
    description = "CIDR for the management VPC"
}
variable "vpc_cidr_spoke" {
    description = "Super-Net CIDR for the spoke VPC's"
}
variable "attach_to_tgw_name" {
  description = "Name of the TGW to attach to"
  type        = string
  default     = ""
}
variable "endpoint_name_az1" {
  description = "Name of the gwlb endpoint to route to in AZ1"
  type        = string
  default     = ""
}
variable "endpoint_name_az2" {
  description = "Name of the gwlb endpoint to route to in AZ2"
  type        = string
  default     = ""
}
variable "fgt_instance_type" {
  description = "Instance type for all of the Fortigates in the ASG's"
  type        = string
  default     = ""
}
variable "fortios_version" {
  description = "FortiGate OS Version of all instances in the Autoscale Groups"
  type        = string
  default     = ""
}
variable "fortigate_asg_password" {
  description = "Password for the Fortigate ASG"
}
variable "asg_license_directory" {
  description = "License Directory for North/South Autoscale Group"
  type        = string
  default     = ""
}

variable "base_config_file" {
  description = "Initial Config File for Autoscale Group"
  type        = string
  default     = ""
}
variable "asg_byol_asg_min_size" {
    description = "Minimum size for the BYOL ASG"
    type        = number
}
variable "asg_byol_asg_max_size" {
    description = "Maximum size for the BYOL ASG"
    type        = number
}
variable "asg_byol_asg_desired_size" {
    description = "Desired size for the BYOL ASG"
    type        = number
}
variable "asg_ondemand_asg_min_size" {
    description = "Minimum size for the On Demand ASG"
    type        = number
}
variable "asg_ondemand_asg_max_size" {
    description = "Maximum size for the OnDemand ASG"
    type        = number
}
variable "asg_ondemand_asg_desired_size" {
    description = "Desired size for the OnDemand ASG"
    type        = number
}
variable "acl" {
  description = "The acl for linux instances"
}
