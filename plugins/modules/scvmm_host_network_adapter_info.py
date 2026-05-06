#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_network_adapter_info
short_description: Gather information about SCVMM Host Network Adapters
description:
    - Gather information about physical network adapters on a System Center Virtual Machine Manager (SCVMM) VM Host.
version_added: "1.0.0"
author:
    - Gemini CLI (@gemini)
options:
    vm_host:
        description:
            - The name of the VM Host to gather network adapter information from.
        type: str
        required: true
    name:
        description:
            - The name of a specific network adapter to gather information about.
        type: str
requirements:
    - VirtualMachineManager PowerShell module
'''

EXAMPLES = r'''
- name: Gather info about all network adapters on a host
  microsoft.scvmm.scvmm_host_network_adapter_info:
    vm_host: "HVHost01"

- name: Gather info about a specific network adapter by name
  microsoft.scvmm.scvmm_host_network_adapter_info:
    vm_host: "HVHost01"
    name: "Physical Adapter 1"
'''

RETURN = r'''
host_network_adapters:
    description: A list of SCVMM host network adapters.
    returned: always
    type: list
    elements: dict
    contains:
        name:
            description: The name of the network adapter.
            returned: always
            type: str
            sample: "Physical Adapter 1"
        id:
            description: The unique identifier for the network adapter.
            returned: always
            type: str
            sample: "56303030-3131-3131-3131-313131313131"
        connection_name:
            description: The connection name of the network adapter.
            returned: always
            type: str
            sample: "Ethernet"
        vm_host:
            description: The name of the host the adapter belongs to.
            returned: always
            type: str
            sample: "HVHost01"
        mac_address:
            description: The MAC address of the network adapter.
            returned: always
            type: str
            sample: "00:15:5D:01:02:03"
        vlan_enabled:
            description: Whether VLAN tagging is enabled.
            returned: always
            type: bool
            sample: true
        vlan_mode:
            description: The VLAN mode (Access or Trunk).
            returned: always
            type: str
            sample: "Access"
        vlan_id:
            description: The VLAN ID if mode is Access.
            returned: always
            type: int
            sample: 10
        vlan_trunk_ids:
            description: The list of VLAN IDs if mode is Trunk.
            returned: always
            type: list
            elements: int
        logical_networks:
            description: The list of logical networks associated with the adapter.
            returned: always
            type: list
            elements: str
        available_for_placement:
            description: Whether the adapter is available for VM placement.
            returned: always
            type: bool
            sample: true
'''
