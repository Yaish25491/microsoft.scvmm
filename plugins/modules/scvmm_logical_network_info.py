# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_logical_network_info
short_description: Gather information about SCVMM logical networks
description:
    - Gather information about SCVMM logical networks.
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the logical network to gather information about.
            - If not specified, information for all logical networks will be returned.
        type: str
'''

EXAMPLES = r'''
- name: Gather information about all logical networks
  microsoft.scvmm.scvmm_logical_network_info:

- name: Gather information about a specific logical network
  microsoft.scvmm.scvmm_logical_network_info:
    name: MyLogicalNetwork
'''

RETURN = r'''
logical_networks:
    description: A list of logical networks and their properties.
    returned: always
    type: list
    elements: dict
    contains:
        name:
            description: The name of the logical network.
            returned: always
            type: str
            sample: MyLogicalNetwork
        id:
            description: The unique GUID for the logical network.
            returned: always
            type: str
            sample: 12345678-1234-1234-1234-123456789012
        description:
            description: A text description of the network.
            returned: always
            type: str
            sample: My logical network description
        enable_network_virtualization:
            description: Whether network virtualization is enabled.
            returned: always
            type: bool
            sample: true
        logical_network_definition_isolation:
            description: Whether isolation is performed at the definition level.
            returned: always
            type: bool
            sample: false
        is_public:
            description: Whether the network is marked as public.
            returned: always
            type: bool
            sample: true
        network_manager:
            description: The network manager associated with this network.
            returned: always
            type: str
            sample: NetworkController
'''
