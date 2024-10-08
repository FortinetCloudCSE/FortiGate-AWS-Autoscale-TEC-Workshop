
module "spk_tgw_gwlb_asg_fgt_igw_ew" {
  source = "git::https://github.com/fortinetdev/terraform-aws-cloud-modules.git//examples/spk_tgw_gwlb_asg_fgt_igw"
  # source = "./aws-terraform-modules/examples/spk_tgw_gwlb_asg_fgt_igw"

  ## Note: Please go through all arguments in this file and replace the content with your configuration! This file is just an example.
  ## "<YOUR-OWN-VALUE>" are parameters that you need to specify your own value.

  ## Root config
  region     = var.aws_region

  module_prefix = var.ew_module_prefix
  existing_security_vpc = {
    id = module.ew-vpc-inspection.vpc_id
  }
  existing_igw = {
    id = module.ew-vpc-igw-inspection.igw_id
  }
  existing_tgw = {
  }
  existing_subnets = {
    fgt_login_az1 = {
      id = module.ew-subnet-inspection-public-az1.id
      availability_zone = local.availability_zone_1
    },
    fgt_login_az2 = {
      id = module.ew-subnet-inspection-public-az2.id
      availability_zone = local.availability_zone_2
    },
    gwlbe_az1 = {
      id = module.ew-subnet-inspection-gwlbe-az1.id
      availability_zone = local.availability_zone_1
    },
    gwlbe_az2 = {
      id = module.ew-subnet-inspection-gwlbe-az2.id
      availability_zone = local.availability_zone_2
    },
    fgt_internal_az1 = {
      id = module.ew-subnet-inspection-private-az1.id
      availability_zone = local.availability_zone_1
    },
    fgt_internal_az2 = {
      id = module.ew-subnet-inspection-private-az2.id
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
  }

  vpc_cidr_block     = var.vpc_cidr_ew_inspection
# spoke_cidr_list    = [var.vpc_cidr_east, var.vpc_cidr_west]
  spoke_cidr_list    = [ ]
  availability_zones = [local.availability_zone_1, local.availability_zone_2]

  ## Transit Gateway
  tgw_name        = "${var.cp}-${var.env}-tgw"
  tgw_description = "tgw for fortigate autoscale group"

  ## Auto scale group
  # This example is a hybrid license ASG
  fgt_intf_mode = "2-arm"
  asgs = {
    fgt_byol_asg = {
      template_name   = "fgt_asg_template"
      fgt_version     = "7.4.4"
      license_type    = "byol"
      fgt_password    = var.fortigate_asg_password
      keypair_name    = var.keypair
      lic_folder_path = var.ew_license_directory
      # fortiflex_refresh_token = "<YOUR-OWN-VALUE>" # e.g. "NasmPa0CXpd56n6TzJjGqpqZm9Thyw"
      # fortiflex_sn_list = "<YOUR-OWN-VALUE>" # e.g. ["FGVMMLTM00000001", "FGVMMLTM00000002"]
      # fortiflex_configid_list = "<YOUR-OWN-VALUE>" # e.g. [2343]
      enable_fgt_system_autoscale = true
      intf_security_group = {
        login_port    = "secgrp1"
        internal_port = "secgrp1"
      }
      user_conf_file_path = var.ew_fgt_config_file
      # There are 3 options for providing user_conf data:
      # user_conf_content : FortiGate Configuration
      # user_conf_file_path : The file path of configuration file
      # user_conf_s3 : Map of AWS S3

      asg_max_size = 1
      asg_min_size = 1
      asg_desired_capacity = 1
      create_dynamodb_table = true
      dynamodb_table_name   = "fgt_asg_track_table"
    },
    fgt_on_demand_asg = {
      template_name               = "fgt_asg_template_on_demand"
      fgt_version                 = "7.4.4"
      license_type                = "on_demand"
      fgt_password    = var.fortigate_asg_password
      keypair_name    = var.keypair
      enable_fgt_system_autoscale = true
      intf_security_group = {
        login_port    = "secgrp1"
        internal_port = "secgrp1"
      }
      user_conf_file_path = var.ew_fgt_config_file
      # There are 3 options for providing user_conf data:
      # user_conf_content : FortiGate Configuration
      # user_conf_file_path : The file path of configuration file
      # user_conf_s3 : Map of AWS S3
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
  enable_cross_zone_load_balancing = true

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

