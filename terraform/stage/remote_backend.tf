# Configure the S3 backend for Terraform state "state.tf"
terraform {
  backend "s3" {
    bucket       = "my-first-practice-bucket-aaa"
    key          = "statefiles/stage/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = false
  }
}
