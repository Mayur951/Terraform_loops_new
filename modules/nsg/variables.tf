variable subnets {
  type = map(object({
    name  = string
    rules = list(string)
  }))
  default = {}
}


variable subnetid {

 type        = map(string)

}

variable "nsg" {

  
  
}