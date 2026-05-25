# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_storage_provider
short_description: Manage SCVMM storage providers
description:
    - Manage SCVMM storage providers, including adding, updating, and removing them.
version_added: "1.0.0"
author:
    - Steve Fulmer (@steve-fulmer)
options:
    name:
        description:
            - The name of the storage provider.
        type: str
        required: true
    state:
        description:
            - The desired state of the storage provider.
        type: str
        choices: [ absent, present ]
        default: present
    description:
        description:
            - A description for the storage provider.
        type: str
    computer_name:
        description:
            - The fully qualified domain name (FQDN) or IP address of the computer to connect to.
            - Required when adding a provider.
        type: str
    network_device_name:
        description:
            - The network name or IP address of the storage device.
        type: str
    tcp_port:
        description:
            - The TCP port to use for communication with the storage provider.
        type: int
    run_as_account:
        description:
            - The name of the Run As account to use for credentials.
        type: str
    fabric:
        description:
            - Whether the provider is part of the storage fabric.
        type: bool
    is_non_trusted_domain:
        description:
            - Whether the provider is in a non-trusted domain.
        type: bool
    provider_type:
        description:
            - The type of provider to add.
        type: str
        choices: [ smis_wmi, windows_native_wmi ]
        default: windows_native_wmi
'''

EXAMPLES = r'''
- name: Add a Windows native WMI storage provider
  microsoft.scvmm.scvmm_storage_provider:
    name: MyStorageProvider
    computer_name: storage.contoso.com
    run_as_account: StorageAdmin

- name: Remove a storage provider
  microsoft.scvmm.scvmm_storage_provider:
    name: MyStorageProvider
    state: absent
'''

RETURN = r'''
storage_provider:
    description: The properties of the storage provider.
    returned: on success and state is present
    type: dict
    contains:
        name:
            description: The name of the storage provider.
            returned: always
            type: str
            sample: MyStorageProvider
        id:
            description: The unique GUID for the storage provider.
            returned: always
            type: str
            sample: 12345678-1234-1234-1234-123456789012
        description:
            description: A description of the storage provider.
            returned: always
            type: str
            sample: My storage provider description
        type:
            description: The type of the storage provider.
            returned: always
            type: str
            sample: WMI
        network_device_name:
            description: The network name or IP address of the storage device.
            returned: always
            type: str
            sample: storage.contoso.com
        is_active:
            description: Whether the storage provider is active.
            returned: always
            type: bool
            sample: true
        state:
            description: The state of the storage provider.
            returned: always
            type: str
            sample: Online
        tcp_port:
            description: The TCP port used to connect to the provider.
            returned: always
            type: int
            sample: 5989
'''
