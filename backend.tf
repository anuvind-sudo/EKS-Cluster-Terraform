terraform {
  backend "s3" {
    bucket = "perfectpgs3 "
    key    = "terraform/terraform.tfstate"
    region = "ap-south-1"
  }
}