# Complete example for `aws_lb_target_group`

This example creates a VPC and an Application Load Balancer target group with HTTPS routing,
health checks, stickiness, and target group health requirements.

## Usage

```hcl
data "aws_region" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = join("", split("-", data.aws_region.current.region))
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = var.use_azure_region_abbr
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = module.resource_names["vpc"].standard
  })
}

# Lock down the VPC's default security group: no ingress, no egress.
# Required by FG_R00089 (Fugue/Regula).
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${module.resource_names["vpc"].standard}-default-restricted"
  })
}

module "lb_target_group" {
  source = "../.."

  name        = var.name == null && var.name_prefix == null ? module.resource_names["target_group"].minimal_random_suffix : var.name
  name_prefix = var.name_prefix

  port             = var.port
  protocol         = var.protocol
  protocol_version = var.protocol_version
  vpc_id           = aws_vpc.vpc.id

  target_type     = var.target_type
  ip_address_type = var.ip_address_type

  deregistration_delay   = var.deregistration_delay
  connection_termination = var.connection_termination
  slow_start             = var.slow_start

  load_balancing_algorithm_type     = var.load_balancing_algorithm_type
  load_balancing_anomaly_mitigation = var.load_balancing_anomaly_mitigation
  load_balancing_cross_zone_enabled = var.load_balancing_cross_zone_enabled

  lambda_multi_value_headers_enabled = var.lambda_multi_value_headers_enabled
  preserve_client_ip                 = var.preserve_client_ip
  proxy_protocol_v2                  = var.proxy_protocol_v2

  health_check        = var.health_check
  stickiness          = var.stickiness
  target_failover     = var.target_failover
  target_health_state = var.target_health_state
  target_group_health = var.target_group_health

  tags = var.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.45.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lb_target_group"></a> [lb\_target\_group](#module\_lb\_target\_group) | ../.. | n/a |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class for the resource\_name module. | `string` | `"dev"` | no |
| <a name="input_connection_termination"></a> [connection\_termination](#input\_connection\_termination) | Whether to terminate connections at deregistration on NLBs. | `bool` | `false` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | Seconds to wait before changing a deregistering target from draining to unused. | `number` | `60` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Health check configuration block for the target group. | <pre>object({<br/>    enabled             = optional(bool)<br/>    healthy_threshold   = optional(number)<br/>    unhealthy_threshold = optional(number)<br/>    interval            = optional(number)<br/>    timeout             = optional(number)<br/>    protocol            = optional(string)<br/>    port                = optional(string)<br/>    path                = optional(string)<br/>    matcher             = optional(string)<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "healthy_threshold": 3,<br/>  "interval": 30,<br/>  "matcher": "200-299",<br/>  "path": "/",<br/>  "port": "traffic-port",<br/>  "protocol": "HTTPS",<br/>  "timeout": 10,<br/>  "unhealthy_threshold": 3<br/>}</pre> | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Instance environment number for the resource\_name module. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Instance resource number for the resource\_name module. | `number` | `0` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | IP address type for ip target type. | `string` | `"ipv4"` | no |
| <a name="input_lambda_multi_value_headers_enabled"></a> [lambda\_multi\_value\_headers\_enabled](#input\_lambda\_multi\_value\_headers\_enabled) | Multi-value headers for Lambda targets. | `bool` | `false` | no |
| <a name="input_load_balancing_algorithm_type"></a> [load\_balancing\_algorithm\_type](#input\_load\_balancing\_algorithm\_type) | ALB load balancing algorithm. | `string` | `"round_robin"` | no |
| <a name="input_load_balancing_anomaly_mitigation"></a> [load\_balancing\_anomaly\_mitigation](#input\_load\_balancing\_anomaly\_mitigation) | Target anomaly mitigation. | `string` | `"off"` | no |
| <a name="input_load_balancing_cross_zone_enabled"></a> [load\_balancing\_cross\_zone\_enabled](#input\_load\_balancing\_cross\_zone\_enabled) | Cross-zone load balancing setting. | `string` | `"use_load_balancer_configuration"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Product family for the resource\_name module. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Product service for the resource\_name module. | `string` | `"lbtg"` | no |
| <a name="input_name"></a> [name](#input\_name) | Override the generated target group name. Conflicts with name\_prefix. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Override the generated target group name prefix. Conflicts with name. | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | Port on which targets receive traffic. | `number` | `443` | no |
| <a name="input_preserve_client_ip"></a> [preserve\_client\_ip](#input\_preserve\_client\_ip) | Whether client IP preservation is enabled. | `string` | `null` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol for routing traffic to targets. | `string` | `"HTTPS"` | no |
| <a name="input_protocol_version"></a> [protocol\_version](#input\_protocol\_version) | Protocol version. HTTP1, HTTP2, or GRPC. | `string` | `"HTTP1"` | no |
| <a name="input_proxy_protocol_v2"></a> [proxy\_protocol\_v2](#input\_proxy\_protocol\_v2) | Whether to enable proxy protocol v2 on NLBs. | `bool` | `false` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource type entries used to derive standardized names. | <pre>map(object({<br/>    name       = string<br/>    max_length = optional(number, 60)<br/>  }))</pre> | <pre>{<br/>  "target_group": {<br/>    "max_length": 32,<br/>    "name": "tg1"<br/>  },<br/>  "vpc": {<br/>    "max_length": 60,<br/>    "name": "vpc1"<br/>  }<br/>}</pre> | no |
| <a name="input_slow_start"></a> [slow\_start](#input\_slow\_start) | Slow start duration in seconds. | `number` | `0` | no |
| <a name="input_stickiness"></a> [stickiness](#input\_stickiness) | Stickiness configuration block for the target group. | <pre>object({<br/>    type            = string<br/>    enabled         = optional(bool)<br/>    cookie_duration = optional(number)<br/>    cookie_name     = optional(string)<br/>  })</pre> | <pre>{<br/>  "cookie_duration": 3600,<br/>  "enabled": true,<br/>  "type": "lb_cookie"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created in the example. | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "ManagedBy": "terraform"<br/>}</pre> | no |
| <a name="input_target_failover"></a> [target\_failover](#input\_target\_failover) | Target failover block. GWLB only. | <pre>object({<br/>    on_deregistration = string<br/>    on_unhealthy      = string<br/>  })</pre> | `null` | no |
| <a name="input_target_group_health"></a> [target\_group\_health](#input\_target\_group\_health) | Target group health requirements block. | <pre>object({<br/>    dns_failover = optional(object({<br/>      minimum_healthy_targets_count      = optional(string)<br/>      minimum_healthy_targets_percentage = optional(string)<br/>    }))<br/>    unhealthy_state_routing = optional(object({<br/>      minimum_healthy_targets_count      = optional(string)<br/>      minimum_healthy_targets_percentage = optional(string)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "dns_failover": {<br/>    "minimum_healthy_targets_count": "1",<br/>    "minimum_healthy_targets_percentage": "off"<br/>  },<br/>  "unhealthy_state_routing": {<br/>    "minimum_healthy_targets_count": "1",<br/>    "minimum_healthy_targets_percentage": "off"<br/>  }<br/>}</pre> | no |
| <a name="input_target_health_state"></a> [target\_health\_state](#input\_target\_health\_state) | Target health state block. NLB only. | <pre>object({<br/>    enable_unhealthy_connection_termination = optional(bool)<br/>    unhealthy_draining_interval             = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target. | `string` | `"ip"` | no |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Unused on AWS, present for compatibility with the resource\_name module API. | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC created in this example. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the target group. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix of the target group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the target group (same as the arn). |
| <a name="output_load_balancer_arns"></a> [load\_balancer\_arns](#output\_load\_balancer\_arns) | ARNs of the load balancers associated with the target group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of all tags assigned to the target group. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC created for the target group. |
<!-- END_TF_DOCS -->
