# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_storage_pool
short_description: Manage SCVMM storage pools
description:
    - Manage SCVMM storage pools, including updating their properties.
    - Note that in SCVMM, storage pools are typically discovered via storage providers rather than created manually.
    - This module focuses on managing the properties of existing storage pools.
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the storage pool.
        type: str
        required: true
    state:
        description:
            - The desired state of the storage pool.
            - Only C(present) is currently supported for modification.
        type: str
        choices: [ present ]
        default: present
    description:
        description:
            - A description for the storage pool.
        type: str
    storage_classification:
        description:
            - The name of the storage classification to associate with the pool.
        type: str
    fault_domain_awareness:
        description:
            - The default fault domain for the storage pool.
        type: str
        choices: [ PhysicalDisk, StorageEnclosure, Node ]
'''

EXAMPLES = r'''
- name: Update storage pool classification
  microsoft.scvmm.scvmm_storage_pool:
    name: MyStoragePool
    storage_classification: Gold
    description: Updated description for Gold storage pool
'''

RETURN = r'''
storage_pool:
    description: The properties of the storage pool.
    returned: on success
    type: dict
    contains:
        name:
            description: The name of the storage pool.
            returned: always
            type: str
            sample: MyStoragePool
        id:
            description: The unique GUID for the storage pool.
            returned: always
            type: str
            sample: 12345678-1234-1234-1234-123456789012
        description:
            description: A description of the storage pool.
            returned: always
            type: str
            sample: My storage pool description
        is_managed:
            description: Whether the storage pool is managed by VMM.
            returned: always
            type: bool
            sample: true
        storage_classification:
            description: The name of the storage classification assigned to the pool.
            returned: always
            type: str
            sample: Gold
        storage_array:
            description: The name of the storage array that contains the pool.
            returned: always
            type: str
            sample: MyStorageArray
        total_capacity:
            description: The total capacity of the storage pool in bytes.
            returned: always
            type: int
            sample: 107374182400
        free_space:
            description: The amount of free space in the storage pool in bytes.
            returned: always
            type: int
            sample: 53687091200
        used_space:
            description: The amount of used space in the storage pool in bytes.
            returned: always
            type: int
            sample: 53687091200
'''
