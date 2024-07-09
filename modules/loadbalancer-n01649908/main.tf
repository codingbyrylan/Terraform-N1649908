resource "azurerm_lb" "load_balancer" {
  name                = "${var.humber_id}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Basic"

  tags = var.tags
}

