# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_storage_classification_info
short_description: Get information about SCVMM storage classifications
description:
    - Get information about SCVMM storage classifications.
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the storage classification to get information for.
        type: str
'''

EXAMPLES = r'''
- name: Get information about all storage classifications
  microsoft.scvmm.scvmm_storage_classification_info:

- name: Get information about a specific storage classification
  microsoft.scvmm.scvmm_storage_classification_info:
    name: Gold
'''

RETURN = r'''
storage_classifications:
    description: A list of storage classifications and their properties.
    returned: always
    type: list
    elements: dict
    contains:
        name:
            description: The name of the storage classification.
            returned: always
            type: str
            sample: Gold
        id:
            description: The unique GUID for the storage classification.
            returned: always
            type: str
            sample: 12345678-1234-1234-1234-123456789012
        description:
            description: A description of the storage classification.
            returned: always
            type: str
            sample: High performance storage
        is_read_only:
            description: Whether the storage classification is read-only.
            returned: always
            type: bool
            sample: false
        is_system:
            description: Whether the storage classification is a system classification.
            returned: always
            type: bool
            sample: false
'''
