locals {
  dedicated_mgmt = var.enable_dedicated_management_vpc ? "-with_dedicated_mgmt" : ""
}
locals {
  fgt_config_file = "./${var.firewall_policy_mode}${local.dedicated_mgmt}-${var.base_config_file}"
}
locals {
  management_device_index = var.firewall_policy_mode == "2-arm" ? 2 : 1
}
locals {
  management_vpc = "${var.cp}-${var.env}-management-vpc"
}
locals {
  management_public_az1 = "${var.cp}-${var.env}-management-public-az1-subnet"
}
locals {
  management_public_az2 = "${var.cp}-${var.env}-management-public-az2-subnet"
}
data "aws_vpc" "management_vpc" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [local.management_vpc]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "public_subnet_az1" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [local.management_public_az1]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "public_subnet_az2" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [local.management_public_az2]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
resource "aws_security_group" "management-vpc-sg" {
  count = var.enable_dedicated_management_vpc ? 1 : 0
  description = "Security Group for ENI in the management VPC"
  vpc_id = data.aws_vpc.management_vpc[0].id
  ingress {
    description = "Allow egress ALL"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    description = "Allow egress ALL"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

module "spk_tgw_gwlb_asg_fgt_igw" {
  source = "git::https://github.com/fortinetdev/terraform-aws-cloud-modules.git//examples/spk_tgw_gwlb_asg_fgt_igw"

  ## Note: Please go through all arguments in this file and replace the content with your configuration! This file is just an example.
  ## "<YOUR-OWN-VALUE>" are parameters that you need to specify your own value.

  ## Root config
  region     = var.aws_region

  module_prefix = var.ns_module_prefix
  existing_security_vpc = {
    id = module.vpc-ns-inspection.vpc_id
  }
  existing_igw = {
    id = module.vpc-ns-inspection.igw_id
  }
  existing_tgw = {
  }
  existing_subnets = {
    fgt_login_az1 = {
      id = module.vpc-ns-inspection.subnet_public_az1_id
      availability_zone = local.availability_zone_1
    },
    fgt_login_az2 = {
      id = module.vpc-ns-inspection.subnet_public_az2_id
      availability_zone = local.availability_zone_2
    },
    gwlbe_az1 = {
      id = module.vpc-ns-inspection.subnet_gwlbe_az1_id
      availability_zone = local.availability_zone_1
    },
    gwlbe_az2 = {
     id = module.vpc-ns-inspection.subnet_gwlbe_az2_id
      availability_zone = local.availability_zone_2
    },
    fgt_internal_az1 = {
      id = module.vpc-ns-inspection.subnet_private_az1_id
      availability_zone = local.availability_zone_1
    },
    fgt_internal_az2 = {
      id = module.vpc-ns-inspection.subnet_private_az2_id
      availability_zone = local.availability_zone_2
    }
  }

  ## VPC
  security_groups = {
    secgrp1 = {
      description = "Security group by Terraform"
      ingress = {
        all_traffic = {
          from_port   = "0"
          to_port     = "0"
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
      egress = {
        all_traffic = {
          from_port   = "0"
          to_port     = "0"
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    management_secgrp1 = {
      description = "Security group by Terraform for dedicated management port"
      ingress = {
        all_traffic = {
          from_port = "0"
          to_port   = "0"
          protocol  = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
      egress = {
        all_traffic = {
          from_port = "0"
          to_port   = "0"
          protocol  = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  vpc_cidr_block     = var.vpc_cidr_ns_inspection
# spoke_cidr_list    = [var.vpc_cidr_east, var.vpc_cidr_west]
  spoke_cidr_list    = [ ]
  availability_zones = [local.availability_zone_1, local.availability_zone_2]

  ## Transit Gateway
  tgw_name        = "${var.cp}-${var.env}-tgw"
  tgw_description = "tgw for fortigate autoscale group"

  ## Auto scale group
  # This example is a hybrid license ASG
  fgt_intf_mode = var.firewall_policy_mode
  fgt_access_internet_mode = var.access_internet_mode
    asgs = {
    fgt_byol_asg = {
      extra_network_interfaces = !var.enable_dedicated_management_vpc ? {} : {
        "dedicated_port" = {
          device_index = local.management_device_index
          enable_public_ip = true
          subnet = [
            {
              id = data.aws_subnet.public_subnet_az1[0].id
              zone_name = local.availability_zone_1
            },
            {
              id = data.aws_subnet.public_subnet_az2[0].id
              zone_name = local.availability_zone_2
            }
          ]
          security_groups = [
            {
              id = aws_security_group.management-vpc-sg[0].id
            }
          ]
        }
      }
      template_name   = "fgt_asg_template"
      fgt_version     = var.fortios_version
      license_type    = "byol"
      instance_type   = var.fgt_instance_type
      fgt_password    = var.fortigate_asg_password
      keypair_name    = var.keypair
      lic_folder_path = var.ns_license_directory
      # fortiflex_refresh_token = "<YOUR-OWN-VALUE>" # e.g. "NasmPa0CXpd56n6TzJjGqpqZm9Thyw"
      # fortiflex_sn_list = "<YOUR-OWN-VALUE>" # e.g. ["FGVMMLTM00000001", "FGVMMLTM00000002"]
      # fortiflex_configid_list = "<YOUR-OWN-VALUE>" # e.g. [2343]
      enable_fgt_system_autoscale = true
      intf_security_group = {
        login_port    = "secgrp1"
        internal_port = "secgrp1"
      }

      user_conf_file_path = local.fgt_config_file
      # There are 3 options for providing user_conf data:
      # user_conf_content : FortiGate Configuration
      # user_conf_file_path : The file path of configuration file
      # user_conf_s3 : Map of AWS S3
      asg_max_size          = var.ns_byol_asg_max_size
      asg_min_size          = var.ns_byol_asg_min_size
      asg_desired_capacity  = var.ns_byol_asg_desired_size
      create_dynamodb_table = true
      dynamodb_table_name   = "fgt_asg_track_table"
    },
    fgt_on_demand_asg = {
      extra_network_interfaces = !var.enable_dedicated_management_vpc ? {} : {
        "dedicated_port" = {
          device_index = local.management_device_index
          enable_public_ip = true
          subnet = [
            {
              id = data.aws_subnet.public_subnet_az1[0].id
              zone_name = local.availability_zone_1
            },
            {
              id = data.aws_subnet.public_subnet_az2[0].id
              zone_name = local.availability_zone_2
            }
          ]
          security_groups = [
            {
              id = aws_security_group.management-vpc-sg[0].id
            }
          ]
        }
      }
      template_name               = "fgt_asg_template_on_demand"
      fgt_version                 = var.fortios_version
      license_type                = "on_demand"
      instance_type               = var.fgt_instance_type
      fgt_password                = var.fortigate_asg_password
      keypair_name                = var.keypair
      enable_fgt_system_autoscale = true
      intf_security_group = {
        login_port    = "secgrp1"
        internal_port = "secgrp1"
      }
      user_conf_file_path = local.fgt_config_file
      # There are 3 options for providing user_conf data:
      # user_conf_content : FortiGate Configuration
      # user_conf_file_path : The file path of configuration file
      # user_conf_s3 : Map of AWS S3
      asg_max_size          = var.ns_ondemand_asg_max_size
      asg_min_size          = var.ns_ondemand_asg_min_size
      asg_desired_capacity  = var.ns_ondemand_asg_desired_size
      asg_max_size = 2
      asg_min_size = 0
      # asg_desired_capacity = 0
      dynamodb_table_name = "fgt_asg_track_table"
      scale_policies = {
        byol_cpu_above_80 = {
          policy_type        = "SimpleScaling"
          adjustment_type    = "ChangeInCapacity"
          cooldown           = 60
          scaling_adjustment = 1
        },
        byol_cpu_below_30 = {
          policy_type        = "SimpleScaling"
          adjustment_type    = "ChangeInCapacity"
          cooldown           = 60
          scaling_adjustment = -1
        },
        ondemand_cpu_above_80 = {
          policy_type        = "SimpleScaling"
          adjustment_type    = "ChangeInCapacity"
          cooldown           = 60
          scaling_adjustment = 1
        },
        ondemand_cpu_below_30 = {
          policy_type        = "SimpleScaling"
          adjustment_type    = "ChangeInCapacity"
          cooldown           = 60
          scaling_adjustment = -1
        }
      }
    }
  }

  ## Cloudwatch Alarm
  cloudwatch_alarms = {
    byol_cpu_above_80 = {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 80
      dimensions = {
        AutoScalingGroupName = "fgt_byol_asg"
      }
      alarm_description   = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_byol."
      datapoints_to_alarm = 1
      alarm_asg_policies = {
        policy_name_map = {
          "fgt_on_demand_asg" = ["byol_cpu_above_80"]
        }
      }
    },
    byol_cpu_below_30 = {
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 30
      dimensions = {
        AutoScalingGroupName = "fgt_byol_asg"
      }
      alarm_description   = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_byol."
      datapoints_to_alarm = 1
      alarm_asg_policies = {
        policy_name_map = {
          "fgt_on_demand_asg" = ["byol_cpu_below_30"]
        }
      }
    },
    ondemand_cpu_above_80 = {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 80
      dimensions = {
        AutoScalingGroupName = "fgt_on_demand_asg"
      }
      alarm_description = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_ondemand."
      alarm_asg_policies = {
        policy_name_map = {
          "fgt_on_demand_asg" = ["ondemand_cpu_above_80"]
        }
      }
    },
    ondemand_cpu_below_30 = {
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 30
      dimensions = {
        AutoScalingGroupName = "fgt_on_demand_asg"
      }
      alarm_description = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_ondemand."
      alarm_asg_policies = {
        policy_name_map = {
          "fgt_on_demand_asg" = ["ondemand_cpu_below_30"]
        }
      }
    }
  }

  ## Gateway Load Balancer
  enable_cross_zone_load_balancing = var.allow_cross_zone_load_balancing

  ## Spoke VPC
  enable_east_west_inspection = true
  # "<YOUR-OWN-VALUE>" # e.g.
  # spk_vpc = {
  #   # This is optional. The module will create Transit Gateway Attachment under each subnet in argument 'subnet_ids', and also create route table to let all traffic (0.0.0.0/0) forward to the TGW attachment with the subnets associated.
  #   "spk_vpc1" = {
  #     vpc_id = "vpc-123456789",
  #     subnet_ids = [
  #       "subnet-123456789",
  #       "subnet-123456789"
  #     ]
  #   }
  # }

  ## Tag
  general_tags = {
    "purpose" = "ASG_TEST"
  }
}

