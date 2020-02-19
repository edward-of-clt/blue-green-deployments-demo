
module "alb_demo" {
  source = "github.com/redventures/terraform-aws-alb-blue-green"

  name                  = "${local.user}-demo-app2"
  environment           = "${var.workspace}"
  alb_access            = ["rv"]
  rv_ips                = module.rvips.rv_ips
  project               = var.project_name
  acm_certificate_arn   = local.acm_certificate
  service               = "demo_green"
  owner                 = local.user
  alb_health_check_port = "80"
  alb_health_check_path = "/"
  container_port        = "80"
}
