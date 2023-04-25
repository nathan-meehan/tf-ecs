# tf-ecs
Terraform project that deploys an ECS cluster behind an Application Load Balancer in a newly created VPC. 
The service is balanced across 3 different AZs.

## Requirements
- AWS Account + way to connect credentials to terraform 

## Variables
- vpc_cidr_block: cidr block to be used by VPC
- subnet_ids: subnets to deploy ecs across
- exec_role_arn: ARN of a role that the task defintion for ECS will use
- image_uri: id of an image to be used by ECS 
  see: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_image 
