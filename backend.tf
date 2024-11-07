terraform {
  backend "s3" {
    bucket = "terra-state-eks-cluster"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}