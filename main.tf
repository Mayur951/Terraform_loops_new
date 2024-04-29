terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = "xxxx"
  client_secret   = "xxxx"
  tenant_id       = "xxxx"
  subscription_id = "xxxx"
}


//variable "network_config_file" {
//  description = "Path to the JSON file containing network configuration"
//}

locals {
  network_config_file = "network.json"
  nsg_file = "nsg.json"
  nsg_rules = "nsg-rules.json"
  network_config = jsondecode(file(local.network_config_file))
  nsg_config = jsondecode(file(local.nsg_file))
  nsg_rules_config = jsondecode(file(local.nsg_rules))
  
}

module "vnet_subnet" {
  source = ".//modules/vnet"

  # Pass the decoded network configuration to the module
  resource_group_name = local.network_config["resource_group_name"]
  name               = local.network_config["name"]
  address_space      = local.network_config["address_space"]
  tags               = local.network_config["tags"]
  subnets            = local.network_config["subnets"]
  ddos_protection_plan = local.network_config["ddos_protection_plan"]

  
}

module "nsg_creation" {
  source = ".//modules/nsg"

  subnets = local.nsg_config["subnets"]
  subnetid = module.vnet_subnet.subnetid
  nsg = local.nsg_rules_config
 

}


module "nsg_association" {
 source = ".//modules/nsg"

 subnets = local.nsg_config["subnets"]
 subnetid = module.vnet_subnet.subnetid
 nsg = local.nsg_rules_config

}

module "nsgrules" {

  source = ".//modules/nsg"
  subnets = local.nsg_config["subnets"]
  subnetid = module.vnet_subnet.subnetid
  nsg = local.nsg_rules_config

}






