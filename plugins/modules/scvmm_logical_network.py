# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_logical_network
short_description: Manage SCVMM logical networks
description:
    - Manage SCVMM logical networks, including creating, updating, and removing them.
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the logical network.
        type: str
        required: true
    state:
        description:
            - The desired state of the logical network.
        type: str
        choices: [ absent, present ]
        default: present
    description:
        description:
            - A description for the logical network.
        type: str
    is_public:
        description:
            - Whether the logical network is public.
        type: bool
    enable_network_virtualization:
        description:
            - Whether to enable network virtualization.
        type: bool
    logical_network_definition_isolation:
        description:
            - Whether to use logical network definition isolation.
        type: bool
'''

EXAMPLES = r'''
- name: Create a logical network
  microsoft.scvmm.scvmm_logical_network:
    name: MyLogicalNetwork
    description: My logical network description
    is_public: true
    enable_network_virtualization: true

- name: Update a logical network
  microsoft.scvmm.scvmm_logical_network:
    name: MyLogicalNetwork
    description: Updated description

- name: Remove a logical network
  microsoft.scvmm.scvmm_logical_network:
    name: MyLogicalNetwork
    state: absent
'''

RETURN = r'''
logical_network:
    description: The properties of the logical network.
    returned: on success and state is present
    type: dict
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
'''
