data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "current" {
  name = var.resource_group_name
}

resource "azurerm_network_ddos_protection_plan" "ddos" {
  count = var.ddos_protection_plan ? 1 : 0

  name                = "${var.prefix["ddos_plan"]}${var.name}"
  location            = data.azurerm_resource_group.current.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix["vnet"]}${var.name}"
  location            = data.azurerm_resource_group.current.location
  resource_group_name = var.resource_group_name

  address_space         = var.address_space
  bgp_community         = var.bgp_community
  dns_servers           = var.dns_servers
  // vm_protection_enabled = var.vm_protection_enabled

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan ? [1] : []

    content {
      id     = azurerm_network_ddos_protection_plan.ddos.0.id
      enable = var.ddos_protection_plan
    }
  }

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.key # "${var.prefix["subnet"]}${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  enforce_private_link_endpoint_network_policies = lookup(each.value.options, "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies  = lookup(each.value.options, "enforce_private_link_service_network_policies", null)
  service_endpoints                              = each.value.service_endpoints
}

locals {
  subnets_with_routetable = [
    for k, v in var.subnets : k
    if lookup(v.options, "route_table", true)
  ]
}

resource "azurerm_route_table" "rt" {
  for_each = toset(local.subnets_with_routetable)

  name                          = "${var.prefix["routetable"]}${each.key}"
  location                      = data.azurerm_resource_group.current.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = lookup(var.subnets[each.key].options, "disable_bgp_route_propagation", null)

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "rt" {
  for_each = toset(local.subnets_with_routetable)

  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.rt[each.key].id
}

locals {
  subnets_with_nsg = [
    for k, v in var.subnets : k
    if lookup(v.options, "network_security_group", true)
  ]
}

resource "azurerm_network_security_group" "nsg" {
  for_each = toset(local.subnets_with_nsg)

  name                = "${var.prefix["nsg"]}${each.key}"
  location            = data.azurerm_resource_group.current.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}


