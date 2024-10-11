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
variable "tgw_subnet_index" {
  description = "Index of the Transit Gateway Attachment subnet"
  default = 3
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
variable "vpc_cidr_ns_inspection" {
    description = "CIDR for the whole NS inspection VPC"
}
variable "vpc_cidr_ew_inspection" {
    description = "CIDR for the whole EW inspection VPC"
}
variable "vpc_cidr_east" {
    description = "CIDR for the whole east VPC"
}
variable "vpc_cidr_spoke" {
    description = "Super-Net CIDR for the spoke VPC's"
}
variable "vpc_cidr_jump_box" {
    description = "CIDR for the jump box subnet"
}
variable "vpc_cidr_east_private_az1" {
    description = "CIDR for the AZ1 private subnet in East VPC"
}
variable "vpc_cidr_east_private_az2" {
    description = "CIDR for the AZ2 private subnet in East VPC"
}
variable "vpc_cidr_west" {
    description = "CIDR for the whole west VPC"
}
variable "vpc_cidr_west_private_az1" {
    description = "CIDR for the AZ1 private subnet in west VPC"
}
variable "vpc_cidr_west_private_az2" {
    description = "CIDR for the AZ2 private subnet in west VPC"
}
variable "attach_to_tgw_name" {
  description = "Name of the TGW to attach to"
  type        = string
  default     = ""
}
variable "ns_endpoint_name_az1" {
  description = "Name of the gwlb endpoint to route to in AZ1"
  type        = string
  default     = ""
}
variable "ns_endpoint_name_az2" {
  description = "Name of the gwlb endpoint to route to in AZ2"
  type        = string
  default     = ""
}
variable "ew_endpoint_name_az1" {
  description = "Name of the gwlb endpoint to route to in AZ1"
  type        = string
  default     = ""
}
variable "ew_endpoint_name_az2" {
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
variable "enable_tgw_attachment_subnet" {
  description = "Boolean to allow creation of TGW Attachment subnet in each AZ of Inspection VPC"
  type        = bool
}
variable "allow_cross_zone_load_balancing" {
  description = "Allow gateway load balancer to use healthy instances in a different zone"
  type        = bool
}
variable "enable_tgw_attachment" {
  description = "Allow Inspection VPC to attach to an existing TGW"
  type        = bool
}
variable "enable_jump_box" {
  description = "Boolean to allow creation of Linux Jump Box in Inspection VPC"
  type        = bool
}
variable "ew_module_prefix" {
  description = "Module Prefix for East/West Autoscale Group"
  type        = string
  default     = ""
}
variable "ns_module_prefix" {
  description = "Module Prefix for East/West Autoscale Group"
  type        = string
  default     = ""
}
variable "ew_license_directory" {
  description = "License Directory for East/West Autoscale Group"
  type        = string
  default     = ""
}
variable "ns_license_directory" {
  description = "License Directory for North/South Autoscale Group"
  type        = string
  default     = ""
}
variable "fortimanager_license_file" {
  description = "Full path for FortiManager License"
  type        = string
  default     = ""
}
variable "fortianalyzer_license_file" {
  description = "Full path for FortiAnalyzer License"
  type        = string
  default     = ""
}
variable "ew_fgt_config_file" {
  description = "Initial Config File for East/West Autoscale Group"
  type        = string
  default     = ""
}
variable "ns_fgt_config_file" {
  description = "Initial Config File for North/South Autoscale Group"
  type        = string
  default     = ""
}
variable "ns_byol_asg_min_size" {
    description = "Minimum size for the BYOL ASG"
    type        = number
}
variable "ns_byol_asg_max_size" {
    description = "Maximum size for the BYOL ASG"
    type        = number
}
variable "ns_byol_asg_desired_size" {
    description = "Desired size for the BYOL ASG"
    type        = number
}
variable "ns_ondemand_asg_min_size" {
    description = "Minimum size for the On Demand ASG"
    type        = number
}
variable "ns_ondemand_asg_max_size" {
    description = "Maximum size for the OnDemand ASG"
    type        = number
}
variable "ns_ondemand_asg_desired_size" {
    description = "Desired size for the OnDemand ASG"
    type        = number
}
variable "ew_byol_asg_min_size" {
    description = "Minimum size for the BYOL ASG"
    type        = number
}
variable "ew_byol_asg_max_size" {
    description = "Maximum size for the BYOL ASG"
    type        = number
}
variable "ew_byol_asg_desired_size" {
    description = "Desired size for the BYOL ASG"
    type        = number
}
variable "ew_ondemand_asg_min_size" {
    description = "Minimum size for the On Demand ASG"
    type        = number
}
variable "ew_ondemand_asg_max_size" {
    description = "Maximum size for the OnDemand ASG"
    type        = number
}
variable "ew_ondemand_asg_desired_size" {
    description = "Desired size for the OnDemand ASG"
    type        = number
}
#
# This boolean creates the resources a customer might have in an existing VPC. I don't have existing resources, so
# this boolean will allow the creation of a TGW, VPC east, and VPC west. For testing only.
#
variable "enable_jump_box_public_ip" {
  description = "Boolean to allow creation of Linux Jump Box public IP in Inspection VPC"
  type        = bool
}
variable "enable_nat_gateway" {
  description = "Boolean to allow creation of nat gateways in each AZ of Inspection VPC"
  type        = bool
}
variable "enable_fortimanager" {
  description = "Boolean to allow creation of FortiManager in Inspection VPC"
  type        = bool
}
variable "enable_linux_spoke_instances" {
  description = "Boolean to allow creation of Linux Spoke Instances in East and West VPCs"
  type        = bool
}
variable "enable_fortimanager_public_ip" {
  description = "Boolean to allow creation of FortiManager public IP in Inspection VPC"
  type        = bool
}
variable "fortimanager_instance_type" {
  description = "Instance type for fortimanager"
}
variable "fortimanager_os_version" {
  description = "Fortimanager OS Version for the AMI Search String"
}
variable "fortimanager_host_ip" {
  description = "Fortimanager IP Address"
}
variable "enable_fortianalyzer" {
  description = "Boolean to allow creation of FortiAnalyzer in Inspection VPC"
  type        = bool
}
variable "fortianalyzer_instance_type" {
  description = "Instance type for fortianalyzer"
}
variable "fortianalyzer_os_version" {
  description = "Fortianalyzer OS Version for the AMI Search String"
}
variable "fortianalyzer_host_ip" {
  description = "Fortianalyzer IP Address"
}
variable "enable_fortianalyzer_public_ip" {
  description = "Boolean to allow creation of FortiAnalyzer public IP in Inspection VPC"
  type        = bool
}
variable "fortigate_asg_password" {
  description = "Password for the Fortigate ASG"
}
variable "linux_instance_type" {
  description = "Linux Endpoint Instance Type"
}
variable "linux_host_ip" {
  description = "Fortigate Host IP for all subnets"
}
variable "acl" {
  description = "The acl for linux instances"
}
