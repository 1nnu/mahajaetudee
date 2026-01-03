locals {
    project = "mahajaetud"
    domain  = "mahajaetud.ee"
    instances_settings = {
        location    = "hel1"
        datacenter  = "hel1-dc2"
        server_type = "cx23"
        os_type     = "ubuntu-24.04"
    }
    aws_settings = {
        region = "eu-west-1"
        bucket = "terraform-s3-state-viiin"
        terraform_state_key    = "my-terraform-project/terraform.tfstate"
    }
}




variable "HETZNER_API_TOKEN" {
  type        = string
  sensitive   = true
}
