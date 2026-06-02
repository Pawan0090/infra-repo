Enterprise Infrastructure as Code (Terragrunt & Terraform)

This repository contains the Infrastructure as Code (IaC) used to provision the underlying AWS network, Kubernetes clusters, and databases for the Multi-Environment SaaS Platform.

To ensure enterprise-grade scaling and state management, this project utilizes **Terragrunt** as a wrapper for Terraform, keeping the architecture DRY and managing multi-environment deployments securely.

##  Architecture & Modules
*   **Amazon EKS (`/modules/eks`):** Provisions the Kubernetes control plane and managed node groups.
*   **Amazon RDS (`/modules/rds`):** Provisions the highly available PostgreSQL databases used for the on-premise migration.
*   **AWS VPC (`/modules/vpc`):** Manages the foundational networking, subnets, and routing.

##  Live Environment Structure
The `live/` directory dictates the actual deployed state across environments, ensuring strict isolation between development, staging, and production clusters.

```text
├── live/
│   ├── dev/
│   │   └── ap-south-1/
│   │       ├── eks/            # Terragrunt execution for Dev EKS
│   │       ├── rds/            # Terragrunt execution for Dev Database
│   │       └── vpc/
│   ├── staging/
│   └── prod/
└── modules/                    # Reusable Terraform modules
    ├── eks/
    ├── rds/
    └── vpc/
