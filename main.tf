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

resource "aws_lb_target_group" "target_group" {
  name        = var.name
  name_prefix = var.name_prefix

  port             = var.port
  protocol         = var.protocol
  protocol_version = var.protocol_version
  vpc_id           = var.vpc_id

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

  dynamic "health_check" {
    for_each = var.health_check != null ? [var.health_check] : []
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      interval            = health_check.value.interval
      timeout             = health_check.value.timeout
      protocol            = health_check.value.protocol
      port                = health_check.value.port
      path                = health_check.value.path
      matcher             = health_check.value.matcher
    }
  }

  dynamic "stickiness" {
    for_each = var.stickiness != null ? [var.stickiness] : []
    content {
      type            = stickiness.value.type
      enabled         = stickiness.value.enabled
      cookie_duration = stickiness.value.cookie_duration
      cookie_name     = stickiness.value.cookie_name
    }
  }

  dynamic "target_failover" {
    for_each = var.target_failover != null ? [var.target_failover] : []
    content {
      on_deregistration = target_failover.value.on_deregistration
      on_unhealthy      = target_failover.value.on_unhealthy
    }
  }

  dynamic "target_health_state" {
    for_each = var.target_health_state != null ? [var.target_health_state] : []
    content {
      enable_unhealthy_connection_termination = target_health_state.value.enable_unhealthy_connection_termination
      unhealthy_draining_interval             = target_health_state.value.unhealthy_draining_interval
    }
  }

  dynamic "target_group_health" {
    for_each = var.target_group_health != null ? [var.target_group_health] : []
    content {
      dynamic "dns_failover" {
        for_each = target_group_health.value.dns_failover != null ? [target_group_health.value.dns_failover] : []
        content {
          minimum_healthy_targets_count      = dns_failover.value.minimum_healthy_targets_count
          minimum_healthy_targets_percentage = dns_failover.value.minimum_healthy_targets_percentage
        }
      }
      dynamic "unhealthy_state_routing" {
        for_each = target_group_health.value.unhealthy_state_routing != null ? [target_group_health.value.unhealthy_state_routing] : []
        content {
          minimum_healthy_targets_count      = unhealthy_state_routing.value.minimum_healthy_targets_count
          minimum_healthy_targets_percentage = unhealthy_state_routing.value.minimum_healthy_targets_percentage
        }
      }
    }
  }

  tags = var.tags
}
