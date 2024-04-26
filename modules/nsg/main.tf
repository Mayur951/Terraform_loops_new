


data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "current" {
  name = "bicep_poc"
}



resource "azurerm_network_security_group" "nsgcreation" {
  for_each = var.subnets
    
  name = each.value["name"]
  location = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
}



resource "azurerm_subnet_network_security_group_association" "associate" {
   
    
    for_each = {
        for key,value in var.subnets : key => value 
  }
    subnet_id = var.subnetid[each.key]
   network_security_group_id = azurerm_network_security_group.nsgcreation[each.key].id
    
}

locals {
  subnets_with_nsg = flatten([
    for key, value in var.nsg : [
      for n, p in var.subnets : {
        name = join("-", [value["rule"]["access"],value["rule"]["direction"],key])
        direction = value["rule"]["direction"]
        access = value["rule"]["access"]
        priority = value["priority"]
        protocol = value["rule"]["protocol"]
        source_port_ranges = lookup(value["rule"], "source_port_ranges", null)
        source_port_range = lookup(value["rule"], "source_port_range", null)
        destination_port_ranges = lookup(value["rule"], "destination_port_ranges", null)
        destination_port_range = lookup(value["rule"], "destination_port_range", null)
        source_address_prefixes = lookup(value["rule"], "source_address_prefixes", null)
        source_address_prefix = lookup(value["rule"], "source_address_prefix", null)
        destination_address_prefixes = lookup(value["rule"], "destination_address_prefixes", null)
        destination_address_prefix = lookup(value["rule"], "destination_address_prefix", null)
        network_security_group_name = p["name"]
        

      }
    ]
   
  ])
}

resource "azurerm_network_security_rule" "nsgrules" {
  for_each = { for idx, subnet in local.subnets_with_nsg : idx => subnet }

  name                        = each.value.name
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_ranges          = each.value.source_port_ranges
  source_port_range           = each.value.source_port_range
  destination_port_ranges     = each.value.destination_port_ranges
  destination_port_range      = each.value.destination_port_range
  source_address_prefixes     = each.value.source_address_prefixes
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefixes= each.value.destination_address_prefixes
  destination_address_prefix = each.value.destination_address_prefix

  resource_group_name         = data.azurerm_resource_group.current.name
  network_security_group_name = each.value.network_security_group_name

  depends_on = [
    azurerm_network_security_group.nsgcreation
  ]
}
