output "vpc_id" {
  value       = module.vpc-inspection.vpc_id
  description = "The VPC Id of the newly created VPC."
}
output "private1_subnet_id" {
  value       = module.subnet-inspection-private-az1.id
  description = "The Private Subnet ID for AZ 1"
}
output "public1_subnet_id" {
  value       = module.subnet-inspection-public-az1.id
  description = "The Public Subnet ID for AZ 1"
}
output "fwaas1_subnet_id" {
  value       = module.subnet-inspection-fwaas-az1.id
  description = "The Fwaas Subnet ID for AZ 1"
}

output "public2_subnet_id" {
  value       = module.subnet-inspection-public-az2.id
  description = "The subnet ID in the Public Subnet in AZ 2"
}
output "fwaas2_subnet_id" {
  value       = module.subnet-inspection-fwaas-az2.id
  description = "The Fwaas Subnet ID for AZ 2"
}
output "private2_subnet_id" {
  value         = module.subnet-inspection-private-az2.id
  description = "The Private Subnet ID for AZ 2"
}
output "az1-nat-gateway" {
  value = aws_nat_gateway.vpc-inspection-az1.id
  description = "NAT Gateway ID for AZ1"
}
output "az2-nat-gateway" {
  value = aws_nat_gateway.vpc-inspection-az2.id
  description = "NAT Gateway ID for AZ2"
}
output "z_east_instance_jump_box_ssh" {
  value = "Jump Box linux az1 ssh: ssh -i ${var.keypair}.pem ubuntu@${element(module.inspection_instance_jump_box.public_eip, 0)}"
}
output "z_east_instance_private_az1_ssh" {
  value = "east private linux az1 ssh: ssh -i ${var.keypair}.pem ubuntu@${local.linux_east_ip_address}"
}
output "z_west_instance_private_az1_ssh" {
  value = "west private linux az1 ssh: ssh -i ${var.keypair}.pem ubuntu@${local.linux_west_ip_address}"
}
output "z_fortimanager_ip" {
  value = "FortiManager IP = ${element(module.fortimanager.public_eip, 0)}"
  description = "Fortimanager IP"
}
output "z_fortimanager_instance_id" {
  value = "FortiManager Instance ID = ${module.fortimanager.instance_id}"
  description = "Fortimanager Instance ID"
}
output "z_fortianalyzer_ip" {
  value = "Fortianalyzer IP = ${element(module.fortianalyzer.public_eip, 0)}"
  description = "Fortianalyzer IP"
}
output "z_fortianalyzer_instance_id" {
  value = "Fortianalyzer Instance ID = ${module.fortianalyzer.instance_id}"
  description = "Fortianalyzer Instance ID"
}