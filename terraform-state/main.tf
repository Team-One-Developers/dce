provider "aws" {
  default_tags {
    tags = {
      project = "dce-terraform-state"
    }
  }
}

module "terraform-state" {
  source       = "./modules/terraform-state"
  project_name = "dce"
}
