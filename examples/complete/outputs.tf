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

output "id" {
  description = "The ID of the target group (same as the arn)."
  value       = module.lb_target_group.id
}

output "arn" {
  description = "The ARN of the target group."
  value       = module.lb_target_group.arn
}

output "arn_suffix" {
  description = "The ARN suffix of the target group."
  value       = module.lb_target_group.arn_suffix
}

output "name" {
  description = "The name of the target group."
  value       = module.lb_target_group.name
}

output "load_balancer_arns" {
  description = "ARNs of the load balancers associated with the target group."
  value       = module.lb_target_group.load_balancer_arns
}

output "tags_all" {
  description = "Map of all tags assigned to the target group."
  value       = module.lb_target_group.tags_all
}

output "vpc_id" {
  description = "ID of the VPC created for the target group."
  value       = aws_vpc.vpc.id
}
