output "application_url" {
  value = "http://${module.alb["front"].lb_dns_name}/"
}
