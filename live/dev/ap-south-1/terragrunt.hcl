remote_state {
  backend = "s3"

  config = {
    bucket = "pawan-terraform-state"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "ap-south-1"
  }
}