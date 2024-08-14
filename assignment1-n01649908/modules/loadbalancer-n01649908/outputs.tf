
output "lb_name" {
  value = azurerm_lb.load_balancer.name
}

output "lb_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.lb_backend.id
}

output "load_balancer_fqdn" {
  value = azurerm_public_ip.public_ip.fqdn
  description = "The FQDN of the Load Balancer"
}
