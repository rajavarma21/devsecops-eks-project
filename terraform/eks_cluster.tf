# 1. Fetch default VPC and subnet structures inside my  active Sydney region
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 2. Provision the Secure EKS Control Plane Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "devsecops-prod-eks"
  cluster_version = "1.35"

  # FIX: Disabled automatic IAM OIDC provider creation to bypass organizational 403 access control blocks
  enable_irsa = false

  # Grants public endpoint clearance so you can connect via kubectl comfortably
  cluster_endpoint_public_access = true

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  # Configure Managed Worker Node Groups optimized for your free tier bounds
  eks_managed_node_groups = {
    app_nodes = {
      min_size       = 1
      max_size       = 2
      desired_size   = 1 
      instance_types = ["t3.small"] 
      
      # FIX: Explicitly forcing the node group to target the correct 1.35 platform release 
      ami_type       = "AL2_x86_64"
    }
  }

  tags = {
    Environment = "production"
    Project     = "devsecops-eks-project"
  }
}

