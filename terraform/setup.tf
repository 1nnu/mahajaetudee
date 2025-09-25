locals {
    project = "mahajaetud"
    domain  = "mahajaetud.ee"
    instances_settings = {
        location    = "hel1"
        datacenter  = "hel1-dc2"
        server_type = "cx22"
        os_type     = "ubuntu-24.04"
    }
    aws_settings = {
        region = "eu-west-1"
        bucket = "terraform-s3-state-viiin"
        terraform_state_key    = "my-terraform-project/terraform.tfstate"
    }
}




variable "hetzner_api_token" {
  type        = string
  sensitive   = true
}
