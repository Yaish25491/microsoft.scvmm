# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_logical_network_definition
short_description: Manage SCVMM logical network definitions
description:
    - Manage SCVMM logical network definitions (network sites), including creating, updating, and removing them.
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the logical network definition.
        type: str
        required: true
    logical_network:
        description:
            - The name of the logical network to which this definition belongs.
            - Required when I(state=present) and creating a new definition.
        type: str
    vm_host_groups:
        description:
            - A list of host groups that can use this definition.
            - Required when I(state=present) and creating a new definition.
        type: list
        elements: str
    subnet_vlans:
        description:
            - A list of subnet and VLAN pairs.
        type: list
        elements: dict
        suboptions:
            subnet:
                description:
                    - The IP subnet (e.g., 192.168.1.0/24).
                type: str
            vlan:
                description:
                    - The VLAN ID.
                type: int
    state:
        description:
            - The desired state of the logical network definition.
        type: str
        choices: [ absent, present ]
        default: present
'''

EXAMPLES = r'''
- name: Create a logical network definition
  microsoft.scvmm.scvmm_logical_network_definition:
    name: MyLogicalNetworkDefinition
    logical_network: MyLogicalNetwork
    vm_host_groups:
      - All Hosts
    subnet_vlans:
      - subnet: 192.168.1.0/24
        vlan: 10

- name: Update a logical network definition host groups
  microsoft.scvmm.scvmm_logical_network_definition:
    name: MyLogicalNetworkDefinition
    vm_host_groups:
      - All Hosts
      - Production

- name: Remove a logical network definition
  microsoft.scvmm.scvmm_logical_network_definition:
    name: MyLogicalNetworkDefinition
    state: absent
'''

RETURN = r'''
logical_network_definition:
    description: The properties of the logical network definition.
    returned: on success and state is present
    type: dict
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
