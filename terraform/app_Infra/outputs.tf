# output "app_server1_public_ip" {
#   value = module.app_server1.public_ip
# }

output "alb_dns_name" {
  value = module.app_elb.alb_dns_name
}

output "alb_arn" {
  value = module.app_elb.alb_arn
}

output "target_group_arn" {
  value = module.app_elb.target_group_arn
}

output "asg_name" {
  value = module.app_asg.asg_name
}

output "launch_template_id" {
  value = module.app_asg.launch_template_id
}

output "db_instance_endpoint" {
  value = module.db_server1.db_instance_endpoint
}

output "db_port" {
  value = module.db_server1.db_port
}