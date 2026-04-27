logical_product_family  = "launch"
logical_product_service = "lbtg"
class_env               = "dev"
instance_env            = 0
instance_resource       = 0

vpc_cidr = "10.0.0.0/16"

port             = 443
protocol         = "HTTPS"
protocol_version = "HTTP1"

target_type     = "ip"
ip_address_type = "ipv4"

deregistration_delay   = 60
connection_termination = false
slow_start             = 0

load_balancing_algorithm_type     = "round_robin"
load_balancing_anomaly_mitigation = "off"
load_balancing_cross_zone_enabled = "use_load_balancer_configuration"

lambda_multi_value_headers_enabled = false
proxy_protocol_v2                  = false

health_check = {
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

stickiness = {
  type            = "lb_cookie"
  enabled         = true
  cookie_duration = 3600
}

target_group_health = {
  dns_failover = {
    minimum_healthy_targets_count      = "1"
    minimum_healthy_targets_percentage = "off"
  }
  unhealthy_state_routing = {
    minimum_healthy_targets_count      = "1"
    minimum_healthy_targets_percentage = "off"
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Module      = "tf-aws-module_primitive-lb_target_group"
}
