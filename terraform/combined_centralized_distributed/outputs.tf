output "vpc_id" {
  value       = module.vpc-ns-inspection.vpc_id
  description = "The VPC Id of the newly created VPC."
}
output "private1_subnet_id" {
  value       = module.subnet-ns-inspection-private-az1.id
  description = "The Private Subnet ID for AZ 1"
}
output "public1_subnet_id" {
  value       = module.subnet-ns-inspection-public-az1.id
  description = "The Public Subnet ID for AZ 1"
}
output "gwlbe1_subnet_id" {
  value       = module.subnet-ns-inspection-gwlbe-az1.id
  description = "The Fwaas Subnet ID for AZ 1"
}

output "public2_subnet_id" {
  value       = module.subnet-ns-inspection-public-az2.id
  description = "The subnet ID in the Public Subnet in AZ 2"
}
output "gwlbe2_subnet_id" {
  value       = module.subnet-ns-inspection-gwlbe-az2.id
  description = "The Fwaas Subnet ID for AZ 2"
}
output "private2_subnet_id" {
  value         = module.subnet-ns-inspection-private-az2.id
  description = "The Private Subnet ID for AZ 2"
}
output "az1-nat-gateway" {
  value = var.enable_nat_gateway ? aws_nat_gateway.vpc-ns-inspection-az1[0].id : null
  description = "NAT Gateway ID for AZ1"
}
output "az2-nat-gateway" {
  value = var.enable_nat_gateway ? aws_nat_gateway.vpc-ns-inspection-az2[0].id : null
  description = "NAT Gateway ID for AZ2"
}
output "z_east_instance_jump_box_ssh" {
  value = "Jump Box linux az1 ssh: ssh -i ${var.keypair}.pem ubuntu@${element(module.inspection_instance_jump_box[0].public_eip, 0)}"
}
output "z_fortimanager_ip" {
  value = var.enable_fortimanager && var.enable_fortimanager_public_ip ? module.fortimanager[0].public_eip : null
  description = "Fortimanager IP"
}
output "z_fortianalyzer_ip" {
  value = var.enable_fortianalyzer && var.enable_fortianalyzer_public_ip ? module.fortianalyzer[0].public_eip[0] : null
  description = "Fortianalyzer IP"
}
