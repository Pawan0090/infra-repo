terraform {

  backend "s3" {}
}

module "eks" {

  source  = "terraform-aws-modules/eks/aws"

  version = "~> 20.0"

  cluster_name    = "devops-eks"

  cluster_version = "1.31"

  authentication_mode = "API_AND_CONFIG_MAP"

  enable_irsa = true

  enable_cluster_creator_admin_permissions = true

  cluster_endpoint_public_access  = true

  cluster_endpoint_private_access = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  create_kms_key = true

  cluster_encryption_config = {
    resources = ["secrets"]
  }

  cluster_addons = {

    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {

      most_recent = true

      before_compute = true

      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id = "vpc-0c21a8de97ed4c5a0"

  subnet_ids = [
    "subnet-06716ab5e2795d29e",
    "subnet-092cfc4fa2df18f02"
  ]

  eks_managed_node_group_defaults = {

    ami_type = "BOTTLEROCKET_x86_64"

    instance_types = ["t3.small"]

    iam_role_attach_cni_policy = true

    iam_role_additional_policies = {

      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
    }

    update_config = {
      max_unavailable_percentage = 50
    }

    force_update_version = true
  }

  eks_managed_node_groups = {

    devops_nodes = {

      capacity_type = "ON_DEMAND"

      min_size = 1

      max_size = 2

      desired_size = 1

      disk_size = 20

      create_security_group = true

      attach_cluster_primary_security_group = true

      labels = {
        Environment = "dev"
      }

      tags = {
        Name = "devops-node-group"
      }
    }
  }

  node_security_group_additional_rules = {

    ingress_self_all = {

      description = "Node to node communication"

      protocol = "-1"

      from_port = 0

      to_port = 0

      type = "ingress"

      self = true
    }

    
  }

  access_entries = {

    eks_admin = {

      principal_arn = "arn:aws:iam::570064632357:user/eks_admin"

      policy_associations = {

        admin_policy = {

          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {

    Environment = "dev"

    Terraform = "true"
  }
}