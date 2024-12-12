output "vpc_id" {
  value       = module.vpc-management[0].vpc_id
  description = "The VPC Id of the management VPC."
}
output "igw_id" {
  value       = module.vpc-management[0].igw_id
  description = "The IGW Id of the management VPC."
}
output "jump_box_public_ip" {
  value = var.enable_jump_box_public_ip ? module.vpc-management[0].jump_box_public_ip : null
  description = "The public IP address of the jump box."
}
output "jump_box_private_ip" {
  value = var.enable_jump_box ? module.vpc-management[0].jump_box_private_ip : null
  description = "The private IP address of the jump box."
}
output "fortimanager_public_ip" {
  value = var.enable_fortimanager_public_ip ? module.vpc-management[0].fortimanager_public_ip : null
  description = "The public IP address of the FortiManager."
}
output "fortimanager_private_ip" {
  value = var.enable_fortimanager ? module.vpc-management[0].fortimanager_private_ip : null
  description = "The private IP address of the FortiManager."
}
output "fortianalyzer_public_ip" {
  value = var.enable_fortianalyzer_public_ip ? module.vpc-management[0].fortianalyzer_public_ip : null
  description = "The public IP address of the fortianalyzer."
}
output "fortianalyzer_private_ip" {
  value = var.enable_fortianalyzer ? module.vpc-management[0].fortianalyzer_private_ip : null
  description = "The private IP address of the fortianalyzer."
}
output "east_vpc_id" {
  value = var.enable_build_existing_subnets ? module.vpc-east[0].vpc_id : null
  description = "The VPC Id of the east VPC."
}
output "west_vpc_id" {
  value = var.enable_build_existing_subnets ? module.vpc-west[0].vpc_id : null
  description = "The VPC Id of the west VPC."
}

