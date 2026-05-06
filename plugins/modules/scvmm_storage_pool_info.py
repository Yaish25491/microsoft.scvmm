# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_storage_pool_info
short_description: Get information about SCVMM storage pools
description:
    - Get information about SCVMM storage pools.
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the storage pool to get information for.
        type: str
'''

EXAMPLES = r'''
- name: Get information about all storage pools
  microsoft.scvmm.scvmm_storage_pool_info:

- name: Get information about a specific storage pool
  microsoft.scvmm.scvmm_storage_pool_info:
    name: MyStoragePool
'''

RETURN = r'''
storage_pools:
    description: A list of storage pools and their properties.
    returned: always
    type: list
    elements: dict
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
