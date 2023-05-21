terraform {
  backend "s3" {
    bucket         = "pocproject1185"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    skip_region_validation = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    encrypt        = true
    dynamodb_table = "Statelock1185"
 
  }
}
