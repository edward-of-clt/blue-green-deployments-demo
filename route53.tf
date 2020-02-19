data "aws_route53_zone" "primary" {
  name = "${local.default_zone}"
}

resource "aws_route53_record" "app1" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${local.user}"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 100
  }

  set_identifier = "${module.task_demo_app1.name}"
  records        = ["${module.alb_demo_app1.dns_name}"]

  # lifecycle {
  #   ignore_changes = [
  #     "weighted_routing_policy",
  #   ]
  # }
}

resource "aws_route53_record" "app2" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${local.user}"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 0
  }

  set_identifier = "${module.task_demo_app2.name}"
  records        = ["${module.alb_demo_app2.dns_name}"]

  # lifecycle {
  #   ignore_changes = [
  #     "weighted_routing_policy",
  #   ]
  # }
}
