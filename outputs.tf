output "groups" {
  value = [for k, v in azurerm_network_security_group.nsg: v]
}

output "ids" {
  value = [for group in azurerm_network_security_group.nsg: group.id]
}
