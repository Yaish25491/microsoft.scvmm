#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_network_adapter_info
short_description: Gather information about SCVMM Virtual Network Adapters
description:
  - Gather information about Virtual Network Adapters in Microsoft System Center Virtual Machine Manager (SCVMM).
  - Can gather information for all adapters, or filter by Virtual Machine, VM Template, Hardware Profile, or ID.
author:
  - Steve Fulmer (@steve-fulmer)
options:
  vm_name:
    description:
      - Name of the Virtual Machine to gather adapters from.
    type: str
  vm_template_name:
    description:
      - Name of the VM Template to gather adapters from.
    type: str
  hardware_profile_name:
    description:
      - Name of the Hardware Profile to gather adapters from.
    type: str
  id:
    description:
      - The unique identifier (GUID) of a specific Virtual Network Adapter.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Virtual Network Adapters
  microsoft.scvmm.scvmm_network_adapter_info:

- name: Gather information about adapters for a specific Virtual Machine
  microsoft.scvmm.scvmm_network_adapter_info:
    vm_name: VM01

- name: Gather information about a specific adapter by ID
  microsoft.scvmm.scvmm_network_adapter_info:
    id: 5b11f363-039b-467a-8963-766666666666
'''

RETURN = r'''
virtual_network_adapters:
  description: List of Virtual Network Adapters and their properties.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: Name of the adapter.
      type: str
    id:
      description: Unique identifier of the adapter.
      type: str
    vm_name:
      description: Name of the VM the adapter is attached to.
      type: str
    vm_template_name:
      description: Name of the VM Template the adapter is part of.
      type: str
    hardware_profile_name:
      description: Name of the Hardware Profile the adapter is part of.
      type: str
    mac_address:
      description: The MAC address assigned to the adapter.
      type: str
    mac_address_type:
      description: The type of MAC address (Static or Dynamic).
      type: str
    ipv4_addresses:
      description: List of IPv4 addresses.
      type: list
      elements: str
    ipv6_addresses:
      description: List of IPv6 addresses.
      type: list
      elements: str
    logical_network:
      description: Name of the associated logical network.
      type: str
    vm_network:
      description: Name of the associated VM network.
      type: str
    port_classification:
      description: Port classification assigned to the adapter.
      type: str
    vlan_enabled:
      description: Whether VLAN is enabled.
      type: bool
    vlan_id:
      description: VLAN ID assigned to the adapter.
      type: int
    enable_mac_address_spoofing:
      description: Whether MAC address spoofing is enabled.
      type: bool
'''
