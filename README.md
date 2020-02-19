# Routing Policy Demo

Example configuration for blue/green deployments using AWS Fargate and Route 53

## Under the hood

By simply utilizing a few AWS services, in conjunction with Shield, we can achieve a blue/green deployment process to help reduce outage frequency and length.

### AWS Services We're Using

- ECS Fargate
- Application Load Balancer
- Route 53 (including Traffic Policies)

### Getting started

Before you can begin, you'll need:

1. AWS account access in `rv-sandbox`
1. Terraform Atlas Token (installed in `~/.terraformrc`)
1. Terraform - `v0.11.14`

### Terraform structure

> ⚠️ These files are not to indicative of preferred file structure. These are grouped based on the simplicity of the demo.

#### `var-config.tf`

This is the standard file for variables and global configurations. This file includes all the pieces you need for getting started / tagging your resources.

#### `ecs.tf`

All your ECS configurations are contained here. You'll find two sets of Terraform code including a `ecs-task`, `ecs-api`, and an `alb` module. These will produce two distinct applications (`nginx` / `whoami`).

#### `route53.tf`

You'll find all your DNS configuration in this file.

## Creating your applications

### Plan

You can, at any point, review what your code will do by running a plan. Terraform will do its best to parse/validate your code.

> \*\*This will not run against AWS**, actual output is not guaranteed; you should **consider it simply as a syntax check.\*\*

If you have pre-existing infrastructure deployed, it will compare your code to the current state in AWS. It will show you what it would change, at that point. To run a plan you run:

```bash
# ax sandbox -- terraform plan
```

For reference, it should look something like this:

```hcl
  + module.task_demo_app2.aws_iam_role_policy.kms
      id:                                         <computed>
      name:                                       "kms-decrypt"
      policy:                                     "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Action\": \"kms:Decrypt\",\n      \"Resource\": \"arn:aws:kms:us-east-1:065035205697:key/8ba98d9f-40a7-4579-88c8-6e7bdb18efdc\"\n    }\n  ]\n}"
      role:                                       "eherbert-demo_app2-sandbox-task-role-us-east-1"

  + module.task_demo_app2.aws_iam_role_policy.paramstore
      id:                                         <computed>
      name:                                       "paramstore-get"
      policy:                                     "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"ssm:GetParametersByPath\",\n        \"ssm:GetParameters\",\n        \"ssm:GetParameter\",\n        \"ssm:DescribeParameters\"\n      ],\n      \"Resource\": [\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert/*\",\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert-sandbox/*\",\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert-eherbert-demo_app2/*\",\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert-eherbert-demo_app2-sandbox/*\"\n      ]\n    }\n  ]\n}"
      role:                                       "eherbert-demo_app2-sandbox-task-role-us-east-1"


Plan: 38 to add, 0 to change, 0 to destroy.
```

### Apply

If you're ready to apply and try out the routing policies, go ahead and apply it locally, from your machine.

```bash
# ax sandbox -- terraform apply
```

You'll be shown an output with the expected actions to be taken by Terraform. If you review it and it looks correct, you can type `yes` and it'll begin creating your applications. It'll looks something like this:

```hcl
  + module.task_demo_app2.aws_iam_role_policy.paramstore
      id:                                         <computed>
      name:                                       "paramstore-get"
      policy:                                     "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"ssm:GetParametersByPath\",\n        \"ssm:GetParameters\",\n        \"ssm:GetParameter\",\n        \"ssm:DescribeParameters\"\n      ],\n      \"Resource\": [\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert/*\",\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert-sandbox/*\",\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert-eherbert-demo_app2/*\",\n        \"arn:aws:ssm:us-east-1:065035205697:parameter/eherbert-eherbert-demo_app2-sandbox/*\"\n      ]\n    }\n  ]\n}"
      role:                                       "eherbert-demo_app2-sandbox-task-role-us-east-1"


Plan: 38 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

Enter a value:
```

## Modifying Routing Policies

By default, you'll only be routed to the `whoami` container.

If you're ready to test the weighted routing, you can modify the `weight` values in `route53.tf`.

> ℹ️ The values you enter should equal 100.

```diff
resource "aws_route53_record" "app1" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${local.user}"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
-    weight = 100
+    weight = 50
  }

  set_identifier = "${module.task_demo_app1.name}"
  records        = ["${module.alb_demo_app1.dns_name}"]
}

resource "aws_route53_record" "app2" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${local.user}"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
-    weight = 0
+    weight = 50
  }

  set_identifier = "${module.task_demo_app2.name}"
  records        = ["${module.alb_demo_app2.dns_name}"]
}
```

Once you've modified the weights, apply your Terraform code.

Refreshing your browser a few times will result in you viewing the different containers. Amazon handles all the routing so you don't have to.
