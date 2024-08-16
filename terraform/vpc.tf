provider "aws" {
    region = "us-east-1"
}

variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


module "alameen-vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.8.1"

    name = "alameen-vpc"
    cidr = var.vpc_cidr_block
    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks
    azs  = slice(data.aws_availability_zones.available.names, 0, 3) 
    
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true

    tags = {
        "kubernetes.io/cluster/alameen-eks-cluster" = "shared"
    }

    public_subnet_tags = {
        "kubernetes.io/cluster/alameen-eks-cluster" = "shared"
        "kubernetes.io/role/elb" = 1 
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/alameen-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1 
    }

}
