output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "subnetid" {
  value = {
    for name in keys(var.subnets) : name => azurerm_subnet.subnet[name].id
  }
}

output "routetable" {
  value = azurerm_route_table.rt
}

output "nsg" {
  value = azurerm_network_security_group.nsg
}
