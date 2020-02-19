provider "aws" {
  region = "${var.aws_region}"
}

variable project_name {
  default = "rv-saas"
}

variable workspace {
  default = "sandbox"
}

variable provisioner {
  default = "Terraform"
}

variable aws_region {
  default = "us-east-1"
}

locals {
  acm_certificate = "arn:aws:acm:us-east-1:065035205697:certificate/1f08cecc-2626-4db6-b514-cee3d20723eb"
  default_zone    = "saas.redventures.io."
  user            = "${element(split(":",data.aws_caller_identity.current.user_id),1)}"
}

module "rvips" {
  source  = "app.terraform.io/RVStandard/rvips/aws"
  version = "~> 2.0"
}

data "aws_caller_identity" "current" {}
