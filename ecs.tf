# START APP 1
module "task_demo_app1" {
  source              = "app.terraform.io/RVStandard/ecs-task/aws"
  version             = "~> 2"
  name                = "${local.user}-demo_app1"
  service             = "demo_app1"
  resource_allocation = "low"
  image               = "containous/whoami:v1.4.0"
  container_port      = "80"

  # tags for CNN
  environment = "${var.workspace}"
  project     = "${var.project_name}"
  owner       = "${local.user}"
  team_name   = "${local.user}"
}

module "service_demo_app1" {
  source                 = "app.terraform.io/RVStandard/ecs-api/aws"
  version                = "~> 1"
  name                   = "${local.user}-demo_app1"
  cluster                = "sample-service-${var.workspace}"
  environment            = "${var.workspace}"
  project                = "${var.project_name}"
  lb_target_group_arn    = "${module.alb_demo_app1.target_group_arn}"
  task_definition_family = "${module.task_demo_app1.name}"
  alb_security_group_id  = "${module.alb_demo_app1.security_group_id}"
  container_port         = "80"
  desired_count          = "1"
}

module "alb_demo_app1" {
  source                = "app.terraform.io/RVStandard/alb/aws"
  version               = "~> 3"
  name                  = "${local.user}-demo-app1"
  environment           = "${var.workspace}"
  alb_access            = ["rv"]
  rv_ips                = "${module.rvips.rv_ips}"
  project               = "${var.project_name}"
  acm_certificate_arn   = "${local.acm_certificate}"
  service               = "demo_app1"
  owner                 = "${local.user}"
  alb_health_check_port = "80"
  alb_health_check_path = "/"
  container_port        = "80"
}

# START APP 2
module "task_demo_app2" {
  source              = "app.terraform.io/RVStandard/ecs-task/aws"
  version             = "~> 2"
  name                = "${local.user}-demo_app2"
  service             = "demo_app2"
  resource_allocation = "low"
  image               = "nginx:alpine"
  container_port      = "80"

  # tags for CNN
  environment = "${var.workspace}"
  project     = "${var.project_name}"
  owner       = "${local.user}"
  team_name   = "${local.user}"
}

module "service_demo_app2" {
  source                 = "app.terraform.io/RVStandard/ecs-api/aws"
  version                = "~> 1"
  name                   = "${local.user}-demo_app2"
  cluster                = "sample-service-${var.workspace}"
  environment            = "${var.workspace}"
  project                = "${var.project_name}"
  lb_target_group_arn    = "${module.alb_demo_app2.target_group_arn}"
  task_definition_family = "${module.task_demo_app2.name}"
  alb_security_group_id  = "${module.alb_demo_app2.security_group_id}"
  container_port         = "80"
  desired_count          = "1"
}

module "alb_demo_app2" {
  source                = "app.terraform.io/RVStandard/alb/aws"
  version               = "~> 3"
  name                  = "${local.user}-demo-app2"
  environment           = "${var.workspace}"
  alb_access            = ["rv"]
  rv_ips                = "${module.rvips.rv_ips}"
  project               = "${var.project_name}"
  acm_certificate_arn   = "${local.acm_certificate}"
  service               = "demo_app2"
  owner                 = "${local.user}"
  alb_health_check_port = "80"
  alb_health_check_path = "/"
  container_port        = "80"
}
