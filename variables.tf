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

variable "name" {
  description = "Name of the target group. Must be unique per region per account, max 32 characters, alphanumeric or hyphens, must not begin or end with a hyphen. Conflicts with name_prefix."
  type        = string
  default     = null

  validation {
    condition     = var.name == null ? true : (length(var.name) <= 32 && can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.name)))
    error_message = "name must be at most 32 characters, alphanumeric or hyphens only, and must not begin or end with a hyphen."
  }

  validation {
    condition     = !(var.name != null && var.name_prefix != null)
    error_message = "name and name_prefix are mutually exclusive; set at most one of them."
  }
}

variable "name_prefix" {
  description = "Prefix used to generate a unique target group name. Cannot be longer than 6 characters. Conflicts with name."
  type        = string
  default     = null

  validation {
    condition     = var.name_prefix == null ? true : length(var.name_prefix) <= 6
    error_message = "name_prefix cannot be longer than 6 characters."
  }
}

variable "port" {
  description = "Port on which targets receive traffic. Required when target_type is instance, ip, or alb. Does not apply when target_type is lambda."
  type        = number
  default     = null

  validation {
    condition     = var.port == null ? true : (var.port >= 1 && var.port <= 65535)
    error_message = "port must be between 1 and 65535."
  }

  validation {
    condition     = !contains(["instance", "ip", "alb"], var.target_type) || var.port != null
    error_message = "port is required when target_type is instance, ip, or alb."
  }
}

variable "protocol" {
  description = "Protocol used for routing traffic to the targets. One of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, UDP, QUIC, or TCP_QUIC. Required when target_type is instance, ip, or alb."
  type        = string
  default     = null

  validation {
    condition     = var.protocol == null ? true : contains(["GENEVE", "HTTP", "HTTPS", "TCP", "TCP_UDP", "TLS", "UDP", "QUIC", "TCP_QUIC"], var.protocol)
    error_message = "protocol must be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, UDP, QUIC, or TCP_QUIC."
  }

  validation {
    condition     = !contains(["instance", "ip", "alb"], var.target_type) || var.protocol != null
    error_message = "protocol is required when target_type is instance, ip, or alb."
  }
}

variable "protocol_version" {
  description = "Protocol version. Only applicable when protocol is HTTP or HTTPS. One of HTTP1, HTTP2, or GRPC. Defaults to HTTP1."
  type        = string
  default     = null

  validation {
    condition     = var.protocol_version == null ? true : contains(["HTTP1", "HTTP2", "GRPC"], var.protocol_version)
    error_message = "protocol_version must be one of HTTP1, HTTP2, or GRPC."
  }
}

variable "vpc_id" {
  description = "Identifier of the VPC in which to create the target group. Required when target_type is instance, ip, or alb."
  type        = string
  default     = null

  validation {
    condition     = !contains(["instance", "ip", "alb"], var.target_type) || var.vpc_id != null
    error_message = "vpc_id is required when target_type is instance, ip, or alb."
  }
}

variable "target_type" {
  description = "Type of target. One of instance, ip, lambda, or alb. Defaults to instance."
  type        = string
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip", "lambda", "alb"], var.target_type)
    error_message = "target_type must be one of instance, ip, lambda, or alb."
  }
}

variable "ip_address_type" {
  description = "Type of IP addresses used by the target group. Only valid when target_type is ip. One of ipv4 or ipv6."
  type        = string
  default     = null

  validation {
    condition     = var.ip_address_type == null ? true : contains(["ipv4", "ipv6"], var.ip_address_type)
    error_message = "ip_address_type must be either ipv4 or ipv6."
  }
}

variable "deregistration_delay" {
  description = "Amount of time (seconds) for ELB to wait before changing a deregistering target from draining to unused. Range is 0-3600."
  type        = number
  default     = 300

  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "deregistration_delay must be between 0 and 3600 seconds."
  }
}

variable "connection_termination" {
  description = "Whether to terminate connections at the end of the deregistration timeout on Network Load Balancers."
  type        = bool
  default     = false
}

variable "slow_start" {
  description = "Amount of time (seconds) for targets to warm up before the load balancer sends them a full share of requests. Range is 30-900 seconds, or 0 to disable."
  type        = number
  default     = 0

  validation {
    condition     = var.slow_start == 0 || (var.slow_start >= 30 && var.slow_start <= 900)
    error_message = "slow_start must be 0 (disabled) or between 30 and 900 seconds."
  }
}

variable "load_balancing_algorithm_type" {
  description = "Algorithm used by an ALB target group. One of round_robin, least_outstanding_requests, or weighted_random. Defaults to round_robin."
  type        = string
  default     = null

  validation {
    condition     = var.load_balancing_algorithm_type == null ? true : contains(["round_robin", "least_outstanding_requests", "weighted_random"], var.load_balancing_algorithm_type)
    error_message = "load_balancing_algorithm_type must be one of round_robin, least_outstanding_requests, or weighted_random."
  }
}

variable "load_balancing_anomaly_mitigation" {
  description = "Whether to enable target anomaly mitigation. Only supported with the weighted_random algorithm. One of on or off. Defaults to off."
  type        = string
  default     = null

  validation {
    condition     = var.load_balancing_anomaly_mitigation == null ? true : contains(["on", "off"], var.load_balancing_anomaly_mitigation)
    error_message = "load_balancing_anomaly_mitigation must be either on or off."
  }
}

variable "load_balancing_cross_zone_enabled" {
  description = "Whether cross zone load balancing is enabled. One of true, false, or use_load_balancer_configuration. Defaults to use_load_balancer_configuration."
  type        = string
  default     = null

  validation {
    condition     = var.load_balancing_cross_zone_enabled == null ? true : contains(["true", "false", "use_load_balancer_configuration"], var.load_balancing_cross_zone_enabled)
    error_message = "load_balancing_cross_zone_enabled must be one of \"true\", \"false\", or \"use_load_balancer_configuration\"."
  }
}

variable "lambda_multi_value_headers_enabled" {
  description = "Whether request and response headers exchanged with the Lambda function include arrays of values or strings. Only applies when target_type is lambda."
  type        = bool
  default     = false
}

variable "preserve_client_ip" {
  description = "Whether client IP preservation is enabled. Defaults vary by target_type and protocol; leave null to use AWS defaults."
  type        = string
  default     = null

  validation {
    condition     = var.preserve_client_ip == null ? true : contains(["true", "false"], var.preserve_client_ip)
    error_message = "preserve_client_ip must be \"true\" or \"false\" when set."
  }
}

variable "proxy_protocol_v2" {
  description = "Whether to enable support for proxy protocol v2 on Network Load Balancers."
  type        = bool
  default     = false
}

variable "health_check" {
  description = <<-EOT
    Health check configuration block.
      enabled             = Whether health checks are enabled. Defaults to true.
      healthy_threshold   = Successes required before considering a target healthy. Range 2-10. Defaults to 3.
      unhealthy_threshold = Failures required before considering a target unhealthy. Range 2-10. Defaults to 3.
      interval            = Seconds between health checks. Range 5-300. Defaults to 30.
      timeout             = Seconds before a no-response check is considered failed. Range 2-120.
      protocol            = Protocol for health checks. One of TCP, HTTP, HTTPS. Defaults to HTTP.
      port                = Port to use for health checks. "traffic-port" or 1-65535. Defaults to traffic-port.
      path                = HTTP/HTTPS health check destination path.
      matcher             = HTTP/gRPC codes for a successful response.
  EOT
  type = object({
    enabled             = optional(bool)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    interval            = optional(number)
    timeout             = optional(number)
    protocol            = optional(string)
    port                = optional(string)
    path                = optional(string)
    matcher             = optional(string)
  })
  default = null

  validation {
    condition     = var.health_check == null ? true : (try(var.health_check.healthy_threshold, null) == null ? true : (var.health_check.healthy_threshold >= 2 && var.health_check.healthy_threshold <= 10))
    error_message = "health_check.healthy_threshold must be between 2 and 10."
  }

  validation {
    condition     = var.health_check == null ? true : (try(var.health_check.unhealthy_threshold, null) == null ? true : (var.health_check.unhealthy_threshold >= 2 && var.health_check.unhealthy_threshold <= 10))
    error_message = "health_check.unhealthy_threshold must be between 2 and 10."
  }

  validation {
    condition     = var.health_check == null ? true : (try(var.health_check.interval, null) == null ? true : (var.health_check.interval >= 5 && var.health_check.interval <= 300))
    error_message = "health_check.interval must be between 5 and 300 seconds."
  }

  validation {
    condition     = var.health_check == null ? true : (try(var.health_check.timeout, null) == null ? true : (var.health_check.timeout >= 2 && var.health_check.timeout <= 120))
    error_message = "health_check.timeout must be between 2 and 120 seconds."
  }

  validation {
    condition     = var.health_check == null ? true : (try(var.health_check.protocol, null) == null ? true : contains(["TCP", "HTTP", "HTTPS"], var.health_check.protocol))
    error_message = "health_check.protocol must be one of TCP, HTTP, or HTTPS."
  }
}

variable "stickiness" {
  description = <<-EOT
    Stickiness configuration block.
      type            = (Required when set) lb_cookie, app_cookie, source_ip, source_ip_dest_ip, or source_ip_dest_ip_proto.
      enabled         = Whether stickiness is enabled. Defaults to true.
      cookie_duration = (lb_cookie only) Seconds to retain affinity. Range 1-604800. Defaults to 86400.
      cookie_name     = (app_cookie only) Application cookie name.
  EOT
  type = object({
    type            = string
    enabled         = optional(bool)
    cookie_duration = optional(number)
    cookie_name     = optional(string)
  })
  default = null

  validation {
    condition     = var.stickiness == null ? true : contains(["lb_cookie", "app_cookie", "source_ip", "source_ip_dest_ip", "source_ip_dest_ip_proto"], var.stickiness.type)
    error_message = "stickiness.type must be one of lb_cookie, app_cookie, source_ip, source_ip_dest_ip, or source_ip_dest_ip_proto."
  }

  validation {
    condition     = var.stickiness == null ? true : (try(var.stickiness.cookie_duration, null) == null ? true : (var.stickiness.cookie_duration >= 1 && var.stickiness.cookie_duration <= 604800))
    error_message = "stickiness.cookie_duration must be between 1 and 604800 seconds."
  }
}

variable "target_failover" {
  description = <<-EOT
    Target failover configuration. Only applicable for Gateway Load Balancer target groups.
      on_deregistration = rebalance or no_rebalance. Must match on_unhealthy.
      on_unhealthy      = rebalance or no_rebalance. Must match on_deregistration.
  EOT
  type = object({
    on_deregistration = string
    on_unhealthy      = string
  })
  default = null

  validation {
    condition     = var.target_failover == null ? true : (contains(["rebalance", "no_rebalance"], var.target_failover.on_deregistration) && contains(["rebalance", "no_rebalance"], var.target_failover.on_unhealthy))
    error_message = "target_failover.on_deregistration and on_unhealthy must each be rebalance or no_rebalance."
  }

  validation {
    condition     = var.target_failover == null ? true : var.target_failover.on_deregistration == var.target_failover.on_unhealthy
    error_message = "target_failover.on_deregistration and on_unhealthy must be set to the same value."
  }
}

variable "target_health_state" {
  description = <<-EOT
    Target health state configuration. Only applicable for NLB target groups with TCP or TLS protocol.
      enable_unhealthy_connection_termination = Whether the load balancer terminates connections to unhealthy targets. Defaults to true.
      unhealthy_draining_interval             = Time to wait for in-flight requests when a target becomes unhealthy. Range 0-360000. Defaults to 0.
  EOT
  type = object({
    enable_unhealthy_connection_termination = optional(bool)
    unhealthy_draining_interval             = optional(number)
  })
  default = null

  validation {
    condition     = var.target_health_state == null ? true : (try(var.target_health_state.unhealthy_draining_interval, null) == null ? true : (var.target_health_state.unhealthy_draining_interval >= 0 && var.target_health_state.unhealthy_draining_interval <= 360000))
    error_message = "target_health_state.unhealthy_draining_interval must be between 0 and 360000 seconds."
  }
}

variable "target_group_health" {
  description = <<-EOT
    Target group health requirements. Only supported by ALB and NLB target groups.
      dns_failover.minimum_healthy_targets_count            = "off" or integer 1 to max targets.
      dns_failover.minimum_healthy_targets_percentage       = "off" or integer 1-100.
      unhealthy_state_routing.minimum_healthy_targets_count = Integer 1 to max targets. Defaults to 1.
      unhealthy_state_routing.minimum_healthy_targets_percentage = "off" or integer 1-100.
  EOT
  type = object({
    dns_failover = optional(object({
      minimum_healthy_targets_count      = optional(string)
      minimum_healthy_targets_percentage = optional(string)
    }))
    unhealthy_state_routing = optional(object({
      minimum_healthy_targets_count      = optional(string)
      minimum_healthy_targets_percentage = optional(string)
    }))
  })
  default = null

  validation {
    condition = (
      var.target_group_health == null ? true :
      try(var.target_group_health.dns_failover, null) == null ? true :
      try(var.target_group_health.dns_failover.minimum_healthy_targets_count, null) == null ? true :
      var.target_group_health.dns_failover.minimum_healthy_targets_count == "off" ? true :
      try(tonumber(var.target_group_health.dns_failover.minimum_healthy_targets_count), -1) >= 1
    )
    error_message = "target_group_health.dns_failover.minimum_healthy_targets_count must be \"off\" or a positive integer."
  }

  validation {
    condition = (
      var.target_group_health == null ? true :
      try(var.target_group_health.dns_failover, null) == null ? true :
      try(var.target_group_health.dns_failover.minimum_healthy_targets_percentage, null) == null ? true :
      var.target_group_health.dns_failover.minimum_healthy_targets_percentage == "off" ? true :
      try(tonumber(var.target_group_health.dns_failover.minimum_healthy_targets_percentage), -1) >= 1 && try(tonumber(var.target_group_health.dns_failover.minimum_healthy_targets_percentage), 101) <= 100
    )
    error_message = "target_group_health.dns_failover.minimum_healthy_targets_percentage must be \"off\" or an integer between 1 and 100."
  }

  validation {
    condition = (
      var.target_group_health == null ? true :
      try(var.target_group_health.unhealthy_state_routing, null) == null ? true :
      try(var.target_group_health.unhealthy_state_routing.minimum_healthy_targets_count, null) == null ? true :
      try(tonumber(var.target_group_health.unhealthy_state_routing.minimum_healthy_targets_count), -1) >= 1
    )
    error_message = "target_group_health.unhealthy_state_routing.minimum_healthy_targets_count must be a positive integer (\"off\" is not supported here)."
  }

  validation {
    condition = (
      var.target_group_health == null ? true :
      try(var.target_group_health.unhealthy_state_routing, null) == null ? true :
      try(var.target_group_health.unhealthy_state_routing.minimum_healthy_targets_percentage, null) == null ? true :
      var.target_group_health.unhealthy_state_routing.minimum_healthy_targets_percentage == "off" ? true :
      try(tonumber(var.target_group_health.unhealthy_state_routing.minimum_healthy_targets_percentage), -1) >= 1 && try(tonumber(var.target_group_health.unhealthy_state_routing.minimum_healthy_targets_percentage), 101) <= 100
    )
    error_message = "target_group_health.unhealthy_state_routing.minimum_healthy_targets_percentage must be \"off\" or an integer between 1 and 100."
  }
}

variable "tags" {
  description = "Map of tags to assign to the target group."
  type        = map(string)
  default     = {}
}
