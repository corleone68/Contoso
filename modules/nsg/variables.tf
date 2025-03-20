variable "workload" {
  description     = "(Optional) The workload name."
  type            = string
  default         = ""
}

variable "environment" {
  description     = "(Optional) The workload environment."
  type            = string
  default         = ""
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the resource."
  type        = string
  default     = ""
}

variable "name" {
  description = "(Required) The name of the NSG."
  type        = string
  default     = ""
}

variable "location" {
  description = "(Required) The supported Azure location where the resource exists."
  type        = string
  default     = "West Europe"
}

variable "inbound_rules" {
  description = "(Optional) List of objects that represent the configuration of each inbound rule."
  type = list(object({
    name                                       = string
    priority                                   = string
    access                                     = string
    protocol                                   = string
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string)) 
    description                                = optional(string)
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))
  default     = []
}

variable "outbound_rules" {
  description = "(Optional) List of objects that represent the configuration of each outbound rule."
  type = list(object({
    name                                       = string
    priority                                   = string
    access                                     = string
    protocol                                   = string
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string)) 
    description                                = optional(string)
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))
  default     = []
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
