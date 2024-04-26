
output "nsg_id" {
  value = {
    for name in keys(var.subnets) : name => azurerm_network_security_group.nsgcreation[name].id
  }
}

output "nsg_creation" {
  value = azurerm_network_security_group.nsgcreation
}