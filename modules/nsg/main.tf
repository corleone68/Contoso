resource "azurerm_network_security_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_network_security_rule" "inbound" {
  for_each                                    = { for rule in var.inbound_rules : rule.name => rule }
  resource_group_name                         = azurerm_network_security_group.this.resource_group_name
  network_security_group_name                 = azurerm_network_security_group.this.name
  direction                                   = "Inbound"
  name                                        = each.value.name
  priority                                    = each.value.priority
  access                                      = each.value.access
  protocol                                    = each.value.protocol
  source_address_prefix                       = lookup(each.value, "source_address_prefix", "*")
  source_address_prefixes                     = lookup(each.value, "source_address_prefixes", "*")
  source_port_range                           = lookup(each.value, "source_port_range", "*")
  source_port_ranges                          = lookup(each.value, "source_port_ranges", "*")
  destination_address_prefix                  = lookup(each.value, "destination_address_prefix", "*")
  destination_address_prefixes                = lookup(each.value, "destination_address_prefixes", "*")
  destination_port_range                      = lookup(each.value, "destination_port_range", "*")
  destination_port_ranges                     = lookup(each.value, "destination_port_ranges", "*")
  description                                 = lookup(each.value, "description", null)
  source_application_security_group_ids       = lookup(each.value, "source_application_security_group_ids", "*")
  destination_application_security_group_ids  = lookup(each.value, "destination_application_security_group_ids", "*")
}

resource "azurerm_network_security_rule" "outbound" {
  for_each                                    = { for rule in var.outbound_rules : rule.name => rule }
  resource_group_name                         = azurerm_network_security_group.this.resource_group_name
  network_security_group_name                 = azurerm_network_security_group.this.name
  direction                                   = "Outbound"
  name                                        = each.value.name
  priority                                    = each.value.priority
  access                                      = each.value.access
  protocol                                    = each.value.protocol
  source_address_prefix                       = lookup(each.value, "source_address_prefix", "*")
  source_address_prefixes                     = lookup(each.value, "source_address_prefixes", "*")
  source_port_range                           = lookup(each.value, "source_port_range", "*")
  source_port_ranges                          = lookup(each.value, "source_port_ranges", "*")
  destination_address_prefix                  = lookup(each.value, "destination_address_prefix", "*")
  destination_address_prefixes                = lookup(each.value, "destination_address_prefixes", "*")
  destination_port_range                      = lookup(each.value, "destination_port_range", "*")
  destination_port_ranges                     = lookup(each.value, "destination_port_ranges", "*")
  description                                 = lookup(each.value, "description", null)
  source_application_security_group_ids       = lookup(each.value, "source_application_security_group_ids", "*")
  destination_application_security_group_ids  = lookup(each.value, "destination_application_security_group_ids", "*")
}
