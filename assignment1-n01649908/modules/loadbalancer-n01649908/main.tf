# Public IP for Load Balancer
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.humber_id}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer Configuration
resource "azurerm_lb" "load_balancer" {
  name                = "${var.humber_id}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  tags = var.tags
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name                = "backendpool"
  loadbalancer_id     = azurerm_lb.load_balancer.id
}

# Health Probe
resource "azurerm_lb_probe" "http_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.load_balancer.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancing Rule
resource "azurerm_lb_rule" "http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.load_balancer.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"

  probe_id                       = azurerm_lb_probe.http_probe.id
}

# Network Interface Configuration for each VM
resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_association" {
  count               = length(var.vm_nics)
  network_interface_id = element(var.vm_nics, count.index)
  ip_configuration_name = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id
}
