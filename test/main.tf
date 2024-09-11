provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["t3.large"]
    min_size       = 3
    max_size       = 6
    desired_size   = 3
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = "my-rds-instance"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  multi_az          = true

  vpc_security_group_ids = [module.vpc.default_security_group_id]

  subnet_ids = module.vpc.private_subnets
}

module "dynamodb" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "my-dynamodb-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]
}

module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-app-logs"
  acl    = "log-delivery-write"
}

module "s3_website" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-static-website"
  acl    = "public-read"

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Security groups, load balancing, monitoring, CI/CD, secrets, access, etc.
# Additional resources can be added as needed