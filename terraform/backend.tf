terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    region  = "us-east-1"
    profile = "storagelab"
    bucket  = "storagelab2"
    key     = "terraformstatefile"
  }
}


