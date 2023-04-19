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
}