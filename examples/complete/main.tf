// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
