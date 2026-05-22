# tf-aws-module_primitive-lb_target_group

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This primitive Terraform module wraps a single `aws_lb_target_group` resource. It exposes every
documented argument so the target group can be used with any combination of Application,
Network, or Gateway Load Balancers and any supported `target_type`.

## Usage

See [`examples/complete`](./examples/complete) for a fully working example that creates a VPC and
an HTTPS Application Load Balancer target group with health checks, stickiness, and target group
health requirements.

## Pre-commit hooks

Install the [pre-commit](https://pre-commit.com/) framework and run `pre-commit install` from the
repository root. The hook configuration in [.pre-commit-config.yaml](.pre-commit-config.yaml) runs:

- `terraform fmt`, `terraform validate`, and `terraform-docs` against this module.
- `golangci-lint` against the test code.
- `commitlint` against commit messages.
- `detect-secrets` against staged files using the [.secrets.baseline](.secrets.baseline) file.

## Workflows

This repository ships with a single GitHub Actions workflow,
[`pull-request-terraform-check-aws.yml`](.github/workflows/pull-request-terraform-check-aws.yml),
which delegates to the reusable AWS Terraform check workflow in `launchbynttdata/launch-workflows`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_target_group.target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connection_termination"></a> [connection\_termination](#input\_connection\_termination) | Whether to terminate connections at the end of the deregistration timeout on Network Load Balancers. | `bool` | `false` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | Amount of time (seconds) for ELB to wait before changing a deregistering target from draining to unused. Range is 0-3600. | `number` | `300` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Health check configuration block.<br/>  enabled             = Whether health checks are enabled. Defaults to true.<br/>  healthy\_threshold   = Successes required before considering a target healthy. Range 2-10. Defaults to 3.<br/>  unhealthy\_threshold = Failures required before considering a target unhealthy. Range 2-10. Defaults to 3.<br/>  interval            = Seconds between health checks. Range 5-300. Defaults to 30.<br/>  timeout             = Seconds before a no-response check is considered failed. Range 2-120.<br/>  protocol            = Protocol for health checks. One of TCP, HTTP, HTTPS. Defaults to HTTP.<br/>  port                = Port to use for health checks. "traffic-port" or 1-65535. Defaults to traffic-port.<br/>  path                = HTTP/HTTPS health check destination path.<br/>  matcher             = HTTP/gRPC codes for a successful response. | <pre>object({<br/>    enabled             = optional(bool)<br/>    healthy_threshold   = optional(number)<br/>    unhealthy_threshold = optional(number)<br/>    interval            = optional(number)<br/>    timeout             = optional(number)<br/>    protocol            = optional(string)<br/>    port                = optional(string)<br/>    path                = optional(string)<br/>    matcher             = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | Type of IP addresses used by the target group. Only valid when target\_type is ip. One of ipv4 or ipv6. | `string` | `null` | no |
| <a name="input_lambda_multi_value_headers_enabled"></a> [lambda\_multi\_value\_headers\_enabled](#input\_lambda\_multi\_value\_headers\_enabled) | Whether request and response headers exchanged with the Lambda function include arrays of values or strings. Only applies when target\_type is lambda. | `bool` | `false` | no |
| <a name="input_load_balancing_algorithm_type"></a> [load\_balancing\_algorithm\_type](#input\_load\_balancing\_algorithm\_type) | Algorithm used by an ALB target group. One of round\_robin, least\_outstanding\_requests, or weighted\_random. Defaults to round\_robin. | `string` | `null` | no |
| <a name="input_load_balancing_anomaly_mitigation"></a> [load\_balancing\_anomaly\_mitigation](#input\_load\_balancing\_anomaly\_mitigation) | Whether to enable target anomaly mitigation. Only supported with the weighted\_random algorithm. One of on or off. Defaults to off. | `string` | `null` | no |
| <a name="input_load_balancing_cross_zone_enabled"></a> [load\_balancing\_cross\_zone\_enabled](#input\_load\_balancing\_cross\_zone\_enabled) | Whether cross zone load balancing is enabled. One of true, false, or use\_load\_balancer\_configuration. Defaults to use\_load\_balancer\_configuration. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the target group. Must be unique per region per account, max 32 characters, alphanumeric or hyphens, must not begin or end with a hyphen. Conflicts with name\_prefix. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used to generate a unique target group name. Cannot be longer than 6 characters. Conflicts with name. | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | Port on which targets receive traffic. Required when target\_type is instance, ip, or alb. Does not apply when target\_type is lambda. | `number` | `null` | no |
| <a name="input_preserve_client_ip"></a> [preserve\_client\_ip](#input\_preserve\_client\_ip) | Whether client IP preservation is enabled. Defaults vary by target\_type and protocol; leave null to use AWS defaults. | `string` | `null` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol used for routing traffic to the targets. One of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, UDP, QUIC, or TCP\_QUIC. Required when target\_type is instance, ip, or alb. | `string` | `null` | no |
| <a name="input_protocol_version"></a> [protocol\_version](#input\_protocol\_version) | Protocol version. Only applicable when protocol is HTTP or HTTPS. One of HTTP1, HTTP2, or GRPC. Defaults to HTTP1. | `string` | `null` | no |
| <a name="input_proxy_protocol_v2"></a> [proxy\_protocol\_v2](#input\_proxy\_protocol\_v2) | Whether to enable support for proxy protocol v2 on Network Load Balancers. | `bool` | `false` | no |
| <a name="input_slow_start"></a> [slow\_start](#input\_slow\_start) | Amount of time (seconds) for targets to warm up before the load balancer sends them a full share of requests. Range is 30-900 seconds, or 0 to disable. | `number` | `0` | no |
| <a name="input_stickiness"></a> [stickiness](#input\_stickiness) | Stickiness configuration block.<br/>  type            = (Required when set) lb\_cookie, app\_cookie, source\_ip, source\_ip\_dest\_ip, or source\_ip\_dest\_ip\_proto.<br/>  enabled         = Whether stickiness is enabled. Defaults to true.<br/>  cookie\_duration = (lb\_cookie only) Seconds to retain affinity. Range 1-604800. Defaults to 86400.<br/>  cookie\_name     = (app\_cookie only) Application cookie name. | <pre>object({<br/>    type            = string<br/>    enabled         = optional(bool)<br/>    cookie_duration = optional(number)<br/>    cookie_name     = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the target group. | `map(string)` | `{}` | no |
| <a name="input_target_failover"></a> [target\_failover](#input\_target\_failover) | Target failover configuration. Only applicable for Gateway Load Balancer target groups.<br/>  on\_deregistration = rebalance or no\_rebalance. Must match on\_unhealthy.<br/>  on\_unhealthy      = rebalance or no\_rebalance. Must match on\_deregistration. | <pre>object({<br/>    on_deregistration = string<br/>    on_unhealthy      = string<br/>  })</pre> | `null` | no |
| <a name="input_target_group_health"></a> [target\_group\_health](#input\_target\_group\_health) | Target group health requirements. Only supported by ALB and NLB target groups.<br/>  dns\_failover.minimum\_healthy\_targets\_count            = "off" or integer 1 to max targets.<br/>  dns\_failover.minimum\_healthy\_targets\_percentage       = "off" or integer 1-100.<br/>  unhealthy\_state\_routing.minimum\_healthy\_targets\_count = Integer 1 to max targets. Defaults to 1.<br/>  unhealthy\_state\_routing.minimum\_healthy\_targets\_percentage = "off" or integer 1-100. | <pre>object({<br/>    dns_failover = optional(object({<br/>      minimum_healthy_targets_count      = optional(string)<br/>      minimum_healthy_targets_percentage = optional(string)<br/>    }))<br/>    unhealthy_state_routing = optional(object({<br/>      minimum_healthy_targets_count      = optional(string)<br/>      minimum_healthy_targets_percentage = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_target_health_state"></a> [target\_health\_state](#input\_target\_health\_state) | Target health state configuration. Only applicable for NLB target groups with TCP or TLS protocol.<br/>  enable\_unhealthy\_connection\_termination = Whether the load balancer terminates connections to unhealthy targets. Defaults to true.<br/>  unhealthy\_draining\_interval             = Time to wait for in-flight requests when a target becomes unhealthy. Range 0-360000. Defaults to 0. | <pre>object({<br/>    enable_unhealthy_connection_termination = optional(bool)<br/>    unhealthy_draining_interval             = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target. One of instance, ip, lambda, or alb. Defaults to instance. | `string` | `"instance"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Identifier of the VPC in which to create the target group. Required when target\_type is instance, ip, or alb. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the target group. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix of the target group, for use with CloudWatch Metrics. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the target group (same as the arn). |
| <a name="output_load_balancer_arns"></a> [load\_balancer\_arns](#output\_load\_balancer\_arns) | ARNs of the load balancers associated with the target group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of all tags assigned to the target group, including those inherited from provider default\_tags. |
<!-- END_TF_DOCS -->
