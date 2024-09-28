
module "existing_resources" {
  source                    = "./existing_vpc_resources"
  count                     = var.enable_build_existing_vpc ? 1 : 0
  aws_region                = var.aws_region
  availability_zone_1       = var.availability_zone_1
  availability_zone_2       = var.availability_zone_2
  cp                        = var.cp
  env                       = var.env
  vpc_cidr_east             = var.vpc_cidr_east
  vpc_cidr_spoke            = var.vpc_cidr_spoke
  vpc_cidr_east_private_az1 = var.vpc_cidr_east_private_az1
  vpc_cidr_east_private_az2 = var.vpc_cidr_east_private_az2
  vpc_cidr_west             = var.vpc_cidr_west
  vpc_cidr_west_private_az1 = var.vpc_cidr_west_private_az1
  vpc_cidr_west_private_az2 = var.vpc_cidr_west_private_az2
}

