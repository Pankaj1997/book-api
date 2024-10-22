module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name                 = "book-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway = false

}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.29" 
  subnet_ids         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_endpoint_public_access = false  
  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3a.small"
    }
  }
  
    cluster_security_group_additional_rules = {
      ingress_bastion = {
        description       = "Allow access from Bastion Host"
        type              = "ingress"
        from_port         = 443
        to_port           = 443
        protocol          = "tcp"
        source_security_group_id = aws_security_group.allow_ssh.id
  }
    }


  access_entries = {
      jump-access = {
        principal_arn = aws_iam_role.eks_ec2_role.arn

        policy_associations = {
          this = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
      
    } 
}



output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}
