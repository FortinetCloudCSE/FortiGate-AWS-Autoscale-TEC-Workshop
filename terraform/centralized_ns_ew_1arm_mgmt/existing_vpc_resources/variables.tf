variable "aws_region" {
  description = "The AWS region to use"
}
variable "availability_zone_1" {
  description = "Availability Zone 1 for VPC"
}
variable "availability_zone_2" {
  description = "Availability Zone 2 for VPC"
}
variable "cp" {
  description = "Customer Prefix to apply to all resources"
}
variable "env" {
  description = "The Tag Environment to differentiate prod/test/dev"
}
variable "enable_build_existing_subnets" {
  description = "Enable building the existing subnets behind the TGW"
  type        = bool
}
variable "vpc_cidr_east" {
    description = "CIDR for the whole east VPC"
}
variable "vpc_cidr_spoke" {
    description = "Super-Net CIDR for the spoke VPC's"
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

