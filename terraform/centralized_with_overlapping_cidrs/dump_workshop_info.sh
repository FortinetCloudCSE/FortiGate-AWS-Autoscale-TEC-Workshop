#!/usr/bin/env bash

cp=`cat terraform.tfvars | grep ^cp | cut -f 2 -d '='|sed -e 's/\"//g'`
env=`cat terraform.tfvars | grep ^env | cut -f 2 -d '='|sed -e 's/\"//g'`
mytag=`echo "$cp-$env" | sed -e 's/ //g'`


#
# dump vpc id, subnet id's, gateway id, and vpc endpoint id's   for the inspection vpc
#
vpc_id=`aws ec2 describe-vpcs --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-vpc --query Vpcs[].VpcId --output text`
echo "existing_security_vpc = {"
echo "  id = \"$vpc_id\""
echo "}"

igw_id=`aws ec2 describe-internet-gateways --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-igw --query "InternetGateways[].InternetGatewayId" --output text`
echo "existing_igw = {"
echo "  id = \"$igw_id\""
echo "}"

echo "existing_tgw = {"
echo "}"

public_subnet_id_az1=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-public-az1-subnet --query "Subnets[0].SubnetId" --output text`
echo "existing_subnets = {"
echo "  fgt_login_us_west_2a = {"
echo "    id = \"$public_subnet_id_az1\""
echo "    availability_zone = \"us-west-2a\""
echo "  },"

public_subnet_id_az2=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-public-az2-subnet --query "Subnets[0].SubnetId" --output text`
echo "  fgt_login_us_west_2c = {"
echo "    id = \"$public_subnet_id_az2\""
echo "    availability_zone = \"us-west-2c\""
echo "  },"

gwlbe_subnet_id_az1=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-fwaas-az1-subnet --query "Subnets[0].SubnetId" --output text`
echo "  gwlbe_us_west_2a = {"
echo "    id = \"$gwlbe_subnet_id_az1\""
echo "    availability_zone = \"us-west-2a\""
echo "  },"

gwlbe_subnet_id_az2=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-fwaas-az2-subnet --query "Subnets[0].SubnetId" --output text`
echo "  gwlbe_us_west_2c = {"
echo "    id = \"$gwlbe_subnet_id_az2\""
echo "    availability_zone = \"us-west-2c\""
echo "  },"

internal_subnet_id_az1=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-private-az1-subnet --query "Subnets[0].SubnetId" --output text`
echo "  fgt_internal_us_west_2a = {"
echo "    id = \"$internal_subnet_id_az1\""
echo "    availability_zone = \"us-west-2a\""
echo "  },"

internal_subnet_id_az2=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=$mytag-inspection-private-az2-subnet --query "Subnets[0].SubnetId" --output text`
echo "  fgt_internal_us_west_2c = {"
echo "    id = \"$internal_subnet_id_az2\""
echo "    availability_zone = \"us-west-2c\""
echo "  }"
echo "}"
exit

#
# fwaas_subnet_id_az1=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=tec-cnf-lab-inspection-fwaas-az1-subnet --query Subnets[].SubnetId --output text`
# echo Inspection Fwaas Subnet AZ1 ID = $fwaas_subnet_id_az1
# fwaas_subnet_id_az2=`aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=tec-cnf-lab-inspection-fwaas-az2-subnet --query Subnets[].SubnetId --output text`
# echo Inspection Fwaas Subnet AZ2 ID = $fwaas_subnet_id_az2
# nat_gateway_id_az1=`aws ec2 describe-nat-gateways --region us-west-2 --filter Name=subnet-id,Values=$public_subnet_id_az1 --query 'NatGateways[*].NatGatewayId' --output text`
# echo Inspection NAT Gateway ID AZ1 = $nat_gateway_id_az1
# nat_gateway_id_az2=`aws ec2 describe-nat-gateways --region us-west-2 --filter Name=subnet-id,Values=$public_subnet_id_az2 --query 'NatGateways[*].NatGatewayId' --output text`
# echo Inspection NAT Gateway ID AZ2 = $nat_gateway_id_az2
# tfile=$(mktemp /tmp/foostack1.XXXXXXXXX)
# aws ec2 describe-vpc-endpoints --region=us-west-2 --filter Name=vpc-id,Values=$vpc_id --query 'VpcEndpoints[].VpcEndpointId' --output text > $tfile
# for i in `cat $tfile`
# do
#
#   test_subnet_id=`aws ec2 describe-vpc-endpoints --regio=us-west-2 --vpc-endpoint-ids $i --query 'VpcEndpoints[].SubnetIds' --output text`
#   if [ "$test_subnet_id" = "$fwaas_subnet_id_az1" ]
#   then
#     vpce_endpoint_az1=$i
#   elif  [ "$test_subnet_id" = "$fwaas_subnet_id_az2" ]
#   then
#     vpce_endpoint_az2=$i
#   fi
# done
# echo VPC Endpoint AZ1 = $vpce_endpoint_az1
# echo VPC Endpoint AZ2 = $vpce_endpoint_az2
# rm -f $tfile
# exit

#
# End of the script
#
