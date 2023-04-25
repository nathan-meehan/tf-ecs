terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
    source = "./vpc"
    vpc_cidr_block = "30.0.0.0/16"
}

module "sg" {
    source = "./sg"
    vpc_id = module.vpc.vpc_tf_id
}

module "ecs" {
    source = "./ecs"
    vpc_id = module.vpc.vpc_tf_id
    sg_ids = module.sg.vpc_tf_sg_id
    subnet_ids = module.vpc.vpc_subnets
    image_uri = ""
    exec_role_arn = ""
}