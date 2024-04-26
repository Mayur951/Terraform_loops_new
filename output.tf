output subnet_id {
    value = module.vnet_subnet.subnetid
}

output nsg_id {
  value = module.nsg_creation
}