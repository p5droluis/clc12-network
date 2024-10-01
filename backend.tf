terraform {
 backend "s3" {
    bucket = "clc12-network-pmachado"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
  }