include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/eks"
}

inputs = {

  vpc_id = "YOUR_VPC_ID"

  private_subnet_1 = "YOUR_PRIVATE_SUBNET_1"

  private_subnet_2 = "YOUR_PRIVATE_SUBNET_2"
}