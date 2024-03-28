# Store the terraform state file in s3 and lock with dunamodb
terraform {
  backend "s3" {
    bucket         = "terraform-guntant2"
    key            = "terraform-guntant2/rentzone/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
  }
}