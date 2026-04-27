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

variable "logical_product_family" {
  description = "Product family for the resource_name module."
  type        = string
  default     = "launch"
}

variable "logical_product_service" {
  description = "Product service for the resource_name module."
  type        = string
  default     = "lbtg"
}

variable "class_env" {
  description = "Environment class for the resource_name module."
  type        = string
  default     = "dev"
}

variable "instance_env" {
  description = "Instance environment number for the resource_name module."
  type        = number
  default     = 0
}

variable "instance_resource" {
  description = "Instance resource number for the resource_name module."
  type        = number
  default     = 0
}

variable "resource_names_map" {
  description = "Map of resource type entries used to derive standardized names."
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))
  default = {
    target_group = {
      name       = "tg1"
      max_length = 32
    }
    vpc = {
      name       = "vpc1"
      max_length = 60
    }
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC created in this example."
  type        = string
  default     = "10.0.0.0/16"
}

variable "port" {
  description = "Port on which targets receive traffic."
  type        = number
  default     = 443
}

variable "protocol" {
  description = "Protocol for routing traffic to targets."
  type        = string
  default     = "HTTPS"
}

variable "protocol_version" {
  description = "Protocol version. HTTP1, HTTP2, or GRPC."
  type        = string
  default     = "HTTP1"
}

variable "target_type" {
  description = "Type of target."
  type        = string
  default     = "ip"
}

variable "ip_address_type" {
  description = "IP address type for ip target type."
  type        = string
  default     = "ipv4"
}

variable "deregistration_delay" {
  description = "Seconds to wait before changing a deregistering target from draining to unused."
  type        = number
  default     = 60
}

variable "connection_termination" {
  description = "Whether to terminate connections at deregistration on NLBs."
  type        = bool
  default     = false
}

variable "slow_start" {
  description = "Slow start duration in seconds."
  type        = number
  default     = 0
}

variable "load_balancing_algorithm_type" {
  description = "ALB load balancing algorithm."
  type        = string
  default     = "round_robin"
}

variable "load_balancing_anomaly_mitigation" {
  description = "Target anomaly mitigation."
  type        = string
  default     = "off"
}

variable "load_balancing_cross_zone_enabled" {
  description = "Cross-zone load balancing setting."
  type        = string
  default     = "use_load_balancer_configuration"
}

variable "lambda_multi_value_headers_enabled" {
  description = "Multi-value headers for Lambda targets."
  type        = bool
  default     = false
}

variable "preserve_client_ip" {
  description = "Whether client IP preservation is enabled."
  type        = string
  default     = null
}

variable "proxy_protocol_v2" {
  description = "Whether to enable proxy protocol v2 on NLBs."
  type        = bool
  default     = false
}

variable "name" {
  description = "Override the generated target group name. Conflicts with name_prefix."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Override the generated target group name prefix. Conflicts with name."
  type        = string
  default     = null
}

variable "health_check" {
  description = "Health check configuration block for the target group."
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
  default = {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    protocol            = "HTTPS"
    port                = "traffic-port"
    path                = "/"
    matcher             = "200-299"
  }
}

variable "stickiness" {
  description = "Stickiness configuration block for the target group."
  type = object({
    type            = string
    enabled         = optional(bool)
    cookie_duration = optional(number)
    cookie_name     = optional(string)
  })
  default = {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 3600
  }
}

variable "target_failover" {
  description = "Target failover block. GWLB only."
  type = object({
    on_deregistration = string
    on_unhealthy      = string
  })
  default = null
}

variable "target_health_state" {
  description = "Target health state block. NLB only."
  type = object({
    enable_unhealthy_connection_termination = optional(bool)
    unhealthy_draining_interval             = optional(number)
  })
  default = null
}

variable "target_group_health" {
  description = "Target group health requirements block."
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
  default = {
    dns_failover = {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }
    unhealthy_state_routing = {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }
  }
}

variable "tags" {
  description = "Tags applied to all resources created in the example."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

variable "use_azure_region_abbr" {
  description = "Unused on AWS, present for compatibility with the resource_name module API."
  type        = bool
  default     = false
}
