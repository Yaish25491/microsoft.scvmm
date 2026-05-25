# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_logical_network_definition_info
short_description: Gather information about SCVMM logical network definitions
description:
    - Gather information about SCVMM logical network definitions (network sites).
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the logical network definition to gather information about.
        type: str
    logical_network:
        description:
            - The name of the logical network to filter definitions by.
        type: str
'''

EXAMPLES = r'''
- name: Gather information about all logical network definitions
  microsoft.scvmm.scvmm_logical_network_definition_info:

- name: Gather information about a specific logical network definition by name
  microsoft.scvmm.scvmm_logical_network_definition_info:
    name: MyLogicalNetworkDefinition

- name: Gather information about definitions for a specific logical network
  microsoft.scvmm.scvmm_logical_network_definition_info:
    logical_network: MyLogicalNetwork
'''

RETURN = r'''
logical_network_definitions:
    description: A list of logical network definitions and their properties.
    returned: always
    type: list
    elements: dict
    contains:
        name:
            description: The name of the logical network definition.
            returned: always
            type: str
            sample: MyLogicalNetworkDefinition
        id:
            description: The unique GUID for the logical network definition.
            returned: always
            type: str
            sample: 12345678-1234-1234-1234-123456789012
        logical_network:
            description: The name of the logical network this definition belongs to.
            returned: always
            type: str
            sample: MyLogicalNetwork
        vm_host_groups:
            description: A list of host groups that can use this definition.
            returned: always
            type: list
            sample: ["All Hosts", "Production"]
        subnet_vlans:
            description: A list of subnet and VLAN pairs.
            returned: always
            type: list
            elements: dict
            contains:
                subnet:
                    description: The IP subnet.
                    type: str
                    sample: 192.168.1.0/24
                vlan:
                    description: The VLAN ID.
                    type: int
                    sample: 10
'''
