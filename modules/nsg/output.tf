output "id" {
  value       = azurerm_network_security_group.this.id
  description = "The network security group configuration ID."
}

output "name" {
  value       = azurerm_network_security_group.this.name
  description = "The name of the network security group."
}

output "resource_group_name" {
  value       = azurerm_network_security_group.this.resource_group_name
  description = "The name of the resource group in which to create the network security group."
}

output "location" {
  value       = azurerm_network_security_group.this.location
  description = "The location/region where the network security group is created."
}

output "inbound_rules" {
  value       = { for rule in azurerm_network_security_rule.inbound : rule.name => rule }
  description = "Blocks containing configuration of each inbound security rule."
}

output "outbound_rules" {
  value       = { for rule in azurerm_network_security_rule.outbound : rule.name => rule }
  description = "Blocks containing configuration of each outbound security rule."
}

output "tags" {
  value       = azurerm_network_security_group.this.tags
  description = "The tags assigned to the resource."
}
