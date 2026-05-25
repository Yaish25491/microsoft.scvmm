# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_scsi_adapter
short_description: Manage virtual SCSI adapters on a virtual machine in SCVMM.
description:
    - Manage virtual SCSI adapters on a virtual machine in System Center Virtual Machine Manager (SCVMM).
    - Can create, modify, and remove virtual SCSI adapters.
author:
    - Steve Fulmer (@steve-fulmer)
options:
    vm:
        description:
            - The name of the virtual machine.
        type: str
        required: true
    adapter_id:
        description:
            - The ID for the SCSI adapter (0 to 3).
            - If not provided when creating, SCVMM will assign the next available ID.
        type: int
    shared:
        description:
            - Specifies whether to enable sharing for guest clustering.
            - This is supported only on VMware ESX hosts.
        type: bool
    synthetic:
        description:
            - Specifies whether to create a high-performance synthetic adapter.
            - This is primarily used for Hyper-V.
        type: bool
    state:
        description:
            - The desired state of the virtual SCSI adapter.
            - C(present) ensures the adapter exists with the specified configuration.
            - C(absent) ensures the adapter is removed.
            - An adapter cannot be removed if it has devices (like virtual hard disks) attached.
        type: str
        choices: [ present, absent ]
        default: present
'''

EXAMPLES = r'''
- name: Add a SCSI adapter to a VM
  microsoft.scvmm.scvmm_vm_scsi_adapter:
    vm: VM01
    state: present

- name: Add a shared SCSI adapter with a specific ID
  microsoft.scvmm.scvmm_vm_scsi_adapter:
    vm: VM01
    adapter_id: 1
    shared: true
    state: present

- name: Remove a SCSI adapter from a VM
  microsoft.scvmm.scvmm_vm_scsi_adapter:
    vm: VM01
    adapter_id: 1
    state: absent
'''

RETURN = r'''
scsi_adapter:
    description: Details about the virtual SCSI adapter.
    returned: always
    type: dict
    sample: {
        "adapter_id": 1,
        "shared": true,
        "synthetic": false,
        "name": "Virtual SCSI adapter",
        "id": "550e8400-e29b-41d4-a716-446655440001"
    }
'''
