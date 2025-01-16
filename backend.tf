terraform {
  backend "s3" {
    bucket  = "tcloud-bucket-tfstate"
    key     = "servers/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
