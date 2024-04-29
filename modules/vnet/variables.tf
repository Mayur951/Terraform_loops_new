variable name {
  type        = string
  description = "Keyvault name"
}

variable resource_group_name {
  type        = string
  description = "Resource Group name for Keyvault"
}

variable address_space {
  type = list(string)
}

variable bgp_community {
  type    = string
  default = null
}

variable ddos_protection_plan {
  type    = bool
  default = false
}

variable disable_bgp_route_propagation {
  type    = bool
  default = false
}

variable dns_servers {
  type    = list(string)
  default = null
}

variable vm_protection_enabled {
  type    = bool
  default = null
}

variable tags {
  type        = map(string)
  description = "Tags for resource"
  default     = {}
}



variable subnets {
  type = map(object({
    address_prefixes  = list(string)
    options           = map(bool)
    service_endpoints = list(string)
  }))
  default = {}
}
