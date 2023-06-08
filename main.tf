locals {
  yaml = yamldecode(file(var.yaml_path))
  groups = {for group, rules in local.yaml.groups: group => [
      for rule in rules: {
          name = rule.name
          action = rule.action
          priority = rule.priority
          direction = rule.direction
          protocol = rule.protocol
          source = length(rule.source_addresses) == 1 ? rule.source_addresses[0] : null
          sources = length(rule.source_addresses) > 1 ? rule.source_addresses : null
          destination = length(rule.destination_addresses) <= 1 ? rule.destination_addresses[0] : null
          destinations = length(rule.destination_addresses) > 1 ? rule.destination_addresses : null
          source_port = length(rule.source_ports) == 1 ? rule.source_ports[0] : null
          source_ports = length(rule.source_ports) > 1 ? rule.source_ports : null
          destination_port = length(rule.destination_ports) == 1 ? rule.destination_ports[0] : null
          destination_ports = length(rule.destination_ports) > 1 ? rule.destination_ports : null
  }]}
}

resource "azurerm_network_security_group" "nsg" {
  for_each = local.groups
  name                = each.key
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  dynamic "security_rule" {
      for_each = each.value
      content {
        name                         = security_rule.value.name
        priority                     = security_rule.value.priority
        direction                    = security_rule.value.direction
        access                       = security_rule.value.action
        protocol                     = security_rule.value.protocol
        source_port_range            = security_rule.value.source_port
        source_port_ranges           = security_rule.value.source_ports
        destination_port_range       = security_rule.value.destination_port
        destination_port_ranges      = security_rule.value.destination_ports
        source_address_prefix        = security_rule.value.source
        source_address_prefixes      = security_rule.value.sources
        destination_address_prefix   = security_rule.value.destination
        destination_address_prefixes = security_rule.value.destinations
      }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
