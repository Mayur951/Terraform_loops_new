variable prefix {
  type = map(string)
  default = {
    "vnet"       = "vnet-"
    "subnet"     = "snet-"
    "ddos_plan"  = "ddos-"
    "nsg"        = "nsg-"
    "routetable" = "rt-"
  }
}